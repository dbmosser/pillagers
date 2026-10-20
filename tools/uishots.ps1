# THE VISUAL QA PASS for menu and HUD builds (2026-10-12, his order: "you should be taking images and using other best practices
# to make damn sure that the revisions to the menus actually look good").
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\uishots.ps1 -Screens "01-title-mode-menu,25-raid-pause-box" -Out <dir> [-Res 1080,4k]
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\uishots.ps1 -Screens all -Out tools\handoff\shots\ui-baseline -Res 1080
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\uishots.ps1 -Screens 01,25 -Res 1080 -Url http://localhost:8808/myfixture.html
#
# For every screen and resolution it: opens a FRESH tab on a wiped origin (every screen stages the same way alone or in a batch),
# waits for the boot, runs the screen's staging JS from tools\handoff\shots\ui-screens-js.json, checks the screen's "expect"
# predicate (a screen that did not come up is reported NOT STAGED, never as if it had), saves NN-name-1080.jpg / NN-name-4k.jpg,
# runs window.__uiLint() (fixture-only, tools\mkfixture.ps1) and writes report.json (lint issues per screen and resolution) plus a
# summary table on stdout and in summary.txt.
#
# Its own headless Chrome on port 9339 (never 8802, never another chain's Chrome), started per resolution and closed at the end,
# also on an error. 1080p = a 1920x1080 viewport (window 1952x1103), 4k = 3840x2160 (window 3872x2263); the window is corrected
# until innerWidth/innerHeight are exact.
#   -Screens   comma list of names or NN prefixes (01,25), or "all"
#   -Res       1080, 4k or both (default 1080,4k)
#   -Url       the fixture page (default http://localhost:8808/fixture.html; a screen may add a query, e.g. the P2 window)
#   -Boot      ms to wait after the page is up before staging (default 3500)
#   -LintJs    a .js file evaluated in the page before the lint (try a new __uiLint without rebuilding the fixture)
#   -LintOpts  a JS object literal passed to __uiLint, e.g. "{minPx:14}"
#   -NoLint    shots only
#   -Merge     keep the other screens already in <Out>\report.json and replace only the ones run now (rerun one screen of a baseline)
#   -NoPopupBlock  let the throwaway camera browser open a second window (two-window pictures); "popups": true in the recipe file does the same
param([string]$Screens='all',[string]$Out='',[string]$Res='1080,4k',[int]$Port=9339,
      [string]$Url='http://localhost:8808/fixture.html',[int]$Boot=3500,[int]$Quality=85,[switch]$NoLint,[switch]$Merge,
      [string]$Recipes='',[string]$LintJs='',[string]$LintOpts='{}',[switch]$NoPopupBlock)
$ErrorActionPreference='Stop'
$Root=Split-Path $PSScriptRoot -Parent
if(-not $Recipes){ $Recipes=Join-Path $Root 'tools\handoff\shots\ui-screens-js.json' }
if(-not $Out){ $Out=Join-Path $Root ('tools\handoff\shots\ui-qa\'+(Get-Date -Format 'yyyyMMdd-HHmm')) }
if(-not (Test-Path $Out)){ New-Item -ItemType Directory -Force $Out | Out-Null }
$Out=(Resolve-Path $Out).Path
if($Port -eq 8802 -or $Url -match ':8802'){ throw 'never the play port' }
$spec=[IO.File]::ReadAllText($Recipes) | ConvertFrom-Json
$all=@($spec.screens)
if($Screens -eq 'all' -or $Screens -eq ''){ $pick=$all }
else{
  $want=$Screens.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  $pick=@(); foreach($w in $want){ $m=@($all | Where-Object { $_.name -eq $w -or $_.name.StartsWith($w+'-') }); if(-not $m.Count){ throw "no screen $w in $Recipes" }; $pick+=$m }
}
$resList=@($Res.Split(',') | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
$SIZES=@{ '1080'=@(1920,1080); '4k'=@(3840,2160) }
foreach($r in $resList){ if(-not $SIZES.ContainsKey($r)){ throw "unknown -Res $r (1080 or 4k)" } }
$lintSrc=''; if($LintJs){ $lintSrc=[IO.File]::ReadAllText((Resolve-Path $LintJs).Path) }
$origin=([Uri]$Url).GetLeftPart([UriPartial]::Authority)
$exe='C:\Program Files\Google\Chrome\Application\chrome.exe'
if(-not (Test-Path $exe)){ $exe='C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
$ChromeProfile=Join-Path $env:TEMP "pillagers-uishots-$Port"
$ct=[Threading.CancellationToken]::None
$KINDS='clip','offscreen','small','contrast','font','overlap','focus'

# ---------------------------------------------------------------- CDP plumbing (one socket per tab)
$script:ws=$null; $script:id=0; $script:proc=$null
function WsOpen([string]$u){
  if($script:ws){ try{ $script:ws.Dispose() }catch{} }
  $script:ws=New-Object System.Net.WebSockets.ClientWebSocket
  $script:ws.Options.KeepAliveInterval=[TimeSpan]::FromSeconds(20)
  $script:ws.ConnectAsync([Uri]$u,$ct).Wait()
}
function Cdp([string]$method,$params,[int]$timeoutSec=120){
  $script:id++; $myid=$script:id
  if($null -eq $params){ $params=@{} }
  $m=@{id=$myid;method=$method;params=$params} | ConvertTo-Json -Depth 8 -Compress
  $b=[Text.Encoding]::UTF8.GetBytes($m)
  $script:ws.SendAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$b)),[System.Net.WebSockets.WebSocketMessageType]::Text,$true,$ct).Wait()
  $buf=New-Object byte[] 1048576; $ms=New-Object System.IO.MemoryStream
  $deadline=(Get-Date).AddSeconds($timeoutSec)
  while($true){
    $task=$script:ws.ReceiveAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$buf)),$ct)
    $left=[int][Math]::Max(1,($deadline-(Get-Date)).TotalMilliseconds)
    if(-not $task.Wait($left)){ throw "CDP TIMEOUT on $method" }
    $ms.Write($buf,0,$task.Result.Count)
    if($task.Result.EndOfMessage){
      $txt=[Text.Encoding]::UTF8.GetString($ms.ToArray()); $ms.SetLength(0)
      if($txt.StartsWith('{"id":'+$myid+',')){ return $txt }
    }
  }
}
# evaluate JS (may be a promise); returns @{ok;val} with val the string result (objects come back as JSON)
function Ev([string]$js,[int]$timeoutSec=120){
  $wrap='(async()=>{ const v=await ('+$js+'); return (typeof v==="string")?v:JSON.stringify(v===undefined?null:v); })()'
  $txt=Cdp 'Runtime.evaluate' @{expression=$wrap;returnByValue=$true;awaitPromise=$true;timeout=($timeoutSec*1000)} ($timeoutSec+10)
  $o=$txt | ConvertFrom-Json
  if($o.error){ return @{ok=$false;val=('CDP ERROR '+$o.error.message)} }
  if($o.result.exceptionDetails){ $d=$o.result.exceptionDetails; $msg=if($d.exception -and $d.exception.description){ $d.exception.description }else{ $d.text }; return @{ok=$false;val=('EXCEPTION '+$msg)} }
  return @{ok=$true;val=[string]$o.result.result.value}
}
function Shot([string]$path){
  $txt=Cdp 'Page.captureScreenshot' @{format='jpeg';quality=$Quality;captureBeyondViewport=$false} 120
  $m=[regex]::Match($txt,'"data":"([^"]+)"')
  if(-not $m.Success){ return $false }
  [IO.File]::WriteAllBytes($path,[Convert]::FromBase64String($m.Groups[1].Value)); return $true
}
function Tabs(){ @(Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json" -TimeoutSec 5) | Where-Object { $_.type -eq 'page' -and -not $_.url.StartsWith('chrome') } }
function MyChromes(){
  @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe' OR Name='msedge.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Contains("--remote-debugging-port=$Port") -and $_.CommandLine.Contains('pillagers-uishots') })
}
function ChromeStop(){
  if($script:proc){
    try{ $v=Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 3; WsOpen $v.webSocketDebuggerUrl; Cdp 'Browser.close' @{} 10 | Out-Null }catch{}
  }
  if($script:ws){ try{ $script:ws.Dispose() }catch{}; $script:ws=$null }
  Start-Sleep -Milliseconds 800
  if($script:proc -and -not $script:proc.HasExited){ try{ Stop-Process -Id $script:proc.Id -Force }catch{} }
  # any Chrome left on this port with this profile (children included); never anyone else's
  MyChromes | ForEach-Object { try{ Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop }catch{} }
  $script:proc=$null
  Start-Sleep -Milliseconds 500
  try{ if(Test-Path $ChromeProfile){ Remove-Item -Recurse -Force $ChromeProfile -ErrorAction Stop } }catch{}
}
function ChromeStart([int]$w,[int]$h){
  $busy=$false; try{ Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null; $busy=$true }catch{}
  if($busy){
    if(@(MyChromes).Count){ MyChromes | ForEach-Object { try{ Stop-Process -Id $_.ProcessId -Force }catch{} }; Start-Sleep -Milliseconds 800 }
    else{ throw "port $Port is already in use by another browser: close it first (uishots owns $Port only when it started it)" }
  }
  try{ if(Test-Path $ChromeProfile){ Remove-Item -Recurse -Force $ChromeProfile -ErrorAction Stop } }catch{}
  $a='--headless=new --window-size='+$w+','+$h+' --force-device-scale-factor=1 --remote-debugging-port='+$Port+
     ' --user-data-dir="'+$ChromeProfile+'" --no-first-run --no-default-browser-check --disable-background-timer-throttling'+
     ' --disable-renderer-backgrounding --disable-backgrounding-occluded-windows --autoplay-policy=no-user-gesture-required about:blank'
  # 10-20: two-window pictures (player 1 and player 2) open the second window with window.open, which a headless camera blocks
  # (no user gesture). -NoPopupBlock, or "popups": true in the recipe file, lets this throwaway camera browser open it.
  if($NoPopupBlock -or ($spec -and $spec.popups)){ $a=$a.Replace(' about:blank',' --disable-popup-blocking about:blank') }
  $script:proc=Start-Process -FilePath $exe -ArgumentList $a -PassThru
  for($i=0;$i -lt 60;$i++){ try{ Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null; return }catch{ Start-Sleep -Milliseconds 250 } }
  throw "Chrome did not start on $Port"
}
# a fresh tab on a wiped origin, loaded and booted; returns the viewport string "WxH" (or $null when the fixture never booted)
function FreshPage([string]$url){
  $old=@(Tabs)
  $t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Port/json/new?about:blank") -TimeoutSec 10
  foreach($o in $old){ try{ Invoke-RestMethod ("http://127.0.0.1:$Port/json/close/"+$o.id) -TimeoutSec 5 | Out-Null }catch{} }
  $left=@()
  for($i=0;$i -lt 20;$i++){ $left=@(Tabs | Where-Object { $_.id -ne $t.id }); if($left.Count -eq 0){ break }; Start-Sleep -Milliseconds 150 }
  if($left.Count){ Write-Host ('  WARN: '+$left.Count+' old tab(s) did not close') }
  WsOpen $t.webSocketDebuggerUrl
  Cdp 'Storage.clearDataForOrigin' @{origin=$origin;storageTypes='all'} 30 | Out-Null
  # a headless tab is never the focused window, and :focus does not match in an unfocused page, so the lint's focus pass needs this
  # it sometimes never answers on a fresh tab (4 times in 120 loads): not fatal, a late answer is skipped by its id
  try{ Cdp 'Emulation.setFocusEmulationEnabled' @{enabled=$true} 8 | Out-Null }catch{ Write-Host '  WARN: focus emulation did not answer' }
  try{ Cdp 'Page.bringToFront' @{} 8 | Out-Null }catch{}
  # a raid page asks "leave site?" on close, and a headless tab then never closes (it kept running the game behind the next
  # screen), so this tab never registers a beforeunload handler
  $nbu='(function(){ var a=EventTarget.prototype.addEventListener; EventTarget.prototype.addEventListener=function(t){ if(t==="beforeunload") return; return a.apply(this,arguments); }; try{ Object.defineProperty(window,"onbeforeunload",{configurable:true,get:function(){ return null; },set:function(){}}); }catch(e){} })();'
  Cdp 'Page.addScriptToEvaluateOnNewDocument' @{source=$nbu} 10 | Out-Null
  Cdp 'Page.navigate' @{url=$url} 60 | Out-Null
  if($url -eq 'about:blank'){ Start-Sleep -Milliseconds 300; return (Ev "innerWidth+'x'+innerHeight" 10).val }
  $ready=$false
  for($i=0;$i -lt 120;$i++){
    Start-Sleep -Milliseconds 500
    try{ $r=Ev "document.readyState==='complete'&&typeof window.__topClear==='function'&&typeof window.__deploy==='function'" 10; if($r.val -eq 'true'){ $ready=$true; break } }catch{}
  }
  if(-not $ready){ return $null }
  Ev 'document.fonts.ready.then(function(){ return 1; })' 30 | Out-Null
  Start-Sleep -Milliseconds $Boot
  (Ev "innerWidth+'x'+innerHeight" 10).val
}
function Counts([string]$lint){
  if(-not ($lint -and $lint.StartsWith('{'))){ return $null }
  try{ return ($lint | ConvertFrom-Json).stats.counts }catch{ return $null }
}
function StageOne($p,[string]$u,[string]$res){
  $name=$p.name
  $vp=FreshPage $u
  $entry=[ordered]@{staged=$false;note='';viewport=[string]$vp;shot=$null;lint=$null}
  if(-not $vp){ $entry.note='the fixture did not load'; return $entry }
  # staging: the prelude helpers (window.__uis, as U) and the screen's own async body
  $body='(async()=>{ '+$prelude+'; const U=window.__uis; await U.prep(); '+[string]$p.js+' })()'
  $r=Ev $body 240
  $note=[string]$r.val; if($note -eq 'null'){ $note='' }
  $ok=$r.ok -and -not $note.StartsWith('SKIP')
  if($ok -and $p.expect){
    $e=Ev ('(function(){ const U=window.__uis; try{ return !!('+[string]$p.expect+'); }catch(e){ return "expect threw: "+e; } })()') 20
    if($e.val -ne 'true'){ $ok=$false; $note=('expect failed: '+[string]$p.expect+' -> '+$e.val+$(if($note){' ('+$note+')'}else{''})) }
  }
  $entry.staged=$ok; $entry.note=$note
  $file=('{0}-{1}.jpg' -f $name,$res)
  if(Shot (Join-Path $Out $file)){ $entry.shot=$file }
  if(-not $NoLint){
    if($lintSrc){ $li=Ev ('(function(){ '+$lintSrc+"`n"+'; return typeof window.__uiLint; })()') 30; if($li.val -ne 'function'){ $entry.lint=('LINTJS FAILED: '+$li.val); return $entry } }
    $l=Ev ("typeof window.__uiLint==='function'?JSON.stringify(window.__uiLint("+$LintOpts+")):'NO LINT: this fixture has no __uiLint (rebuild it from tools/mkfixture.ps1)'") 120
    $entry.lint=$l.val
  }
  return $entry
}

# ---------------------------------------------------------------- run
$prelude=[string]$spec.prelude
$rows=@{}
foreach($p in $pick){ $rows[$p.name]=@{} }
$started=Get-Date
$summary=New-Object System.Collections.Generic.List[string]
function Say([string]$s){ Write-Output $s; $summary.Add($s) }
try{
  foreach($res in $resList){
    $tw=$SIZES[$res][0]; $th=$SIZES[$res][1]
    # headless Chrome's viewport is the window less a frame (32x103 on this PC); start there and correct if it differs
    $ww=$tw+32; $wh=$th+103
    ChromeStart $ww $wh
    $m=FreshPage 'about:blank'
    for($k=0;$k -lt 3;$k++){
      if($m -eq "${tw}x${th}"){ break }
      $mm=$m.Split('x'); $ww+= $tw-[int]$mm[0]; $wh+= $th-[int]$mm[1]
      ChromeStop; ChromeStart $ww $wh; $m=FreshPage 'about:blank'
    }
    if($m -ne "${tw}x${th}"){ Say "WARN: the $res viewport is $m, not ${tw}x${th}" }
    Say ("== $res : window ${ww}x${wh}, viewport $m")
    foreach($p in $pick){
      $name=$p.name; $t0=Get-Date
      $u=$Url; if($p.query){ $u=$Url+$p.query }
      # one retry: a busy PC (other chains' Chromes) can make a single DevTools call time out
      $entry=$null
      for($try=0;$try -lt 2;$try++){
        try{ $entry=StageOne $p $u $res; if($entry.staged -or $entry.note -notmatch 'did not load'){ break } }
        catch{ $entry=[ordered]@{staged=$false;note=('ERROR '+$_.Exception.Message);viewport='';shot=$null;lint=$null}; Write-Output ("  $name  try $($try+1): "+$_.Exception.Message) }
      }
      $rows[$name][$res]=$entry
      $c=Counts ([string]$entry.lint); $cnt=''
      if($c){ $cnt=('total {0,3}: clip {1} off {2} small {3} contrast {4} font {5} overlap {6} focus {7}' -f $c.total,$c.clip,$c.offscreen,$c.small,$c.contrast,$c.font,$c.overlap,$c.focus) }
      elseif($entry.lint){ $cnt=([string]$entry.lint).Substring(0,[Math]::Min(120,([string]$entry.lint).Length)) }
      $note=[string]$entry.note
      Say ('  {0,-38} {1,-10} {2,5:N1}s  {3}{4}' -f $name,$(if($entry.staged){'staged'}else{'NOT STAGED'}),((Get-Date)-$t0).TotalSeconds,$cnt,$(if($note){'  | '+$(if($note.Length -gt 300){$note.Substring(0,300)}else{$note})}else{''}))
    }
    ChromeStop
  }
}
finally{
  ChromeStop
  # report.json: written by hand so each lint result goes in exactly as the page returned it; -Merge keeps the screens and
  # resolutions of the old report that this run did not redo
  $frag=@{}; $scr=@{}
  $rp=Join-Path $Out 'report.json'
  if($Merge -and (Test-Path $rp)){
    try{
      $old=[IO.File]::ReadAllText($rp) | ConvertFrom-Json
      foreach($s in @($old.screens)){
        $frag[$s.name]=@{}; $scr[$s.name]=[string]$s.screen
        foreach($res in '1080','4k'){ if($s.$res){ $frag[$s.name][$res]=($s.$res | ConvertTo-Json -Depth 30 -Compress) } }
      }
    }catch{ Write-Output ('WARN: could not merge the old report: '+$_.Exception.Message) }
  }
  foreach($p in $pick){
    if(-not $frag.ContainsKey($p.name)){ $frag[$p.name]=@{} }; $scr[$p.name]=[string]$p.screen
    foreach($res in $resList){
      $e=$rows[$p.name][$res]; if(-not $e){ continue }
      $lint=if($e.lint -and ([string]$e.lint).StartsWith('{')){ [string]$e.lint }else{ ConvertTo-Json ([string]$e.lint) }
      $frag[$p.name][$res]='{"staged":'+$(if($e.staged){'true'}else{'false'})+',"note":'+(ConvertTo-Json ([string]$e.note))+',"viewport":'+(ConvertTo-Json ([string]$e.viewport))+',"shot":'+(ConvertTo-Json ([string]$e.shot))+',"lint":'+$lint+'}'
    }
  }
  $sb=New-Object Text.StringBuilder
  [void]$sb.Append('{"generated":'+(ConvertTo-Json (Get-Date -Format 's'))+',"url":'+(ConvertTo-Json $Url)+',"recipes":'+(ConvertTo-Json $Recipes)+',"seconds":'+[int]((Get-Date)-$started).TotalSeconds+',"screens":[')
  $first=$true
  foreach($p in $all){
    if(-not $frag.ContainsKey($p.name) -or $frag[$p.name].Count -eq 0){ continue }
    if(-not $first){ [void]$sb.Append(',') }; $first=$false
    [void]$sb.Append("`n"+'{"name":'+(ConvertTo-Json $p.name)+',"screen":'+(ConvertTo-Json $scr[$p.name]))
    foreach($res in '1080','4k'){ if($frag[$p.name].ContainsKey($res)){ [void]$sb.Append(',"'+$res+'":'+$frag[$p.name][$res]) } }
    [void]$sb.Append('}')
  }
  [void]$sb.Append("`n]}")
  [IO.File]::WriteAllText($rp,$sb.ToString())
  if($Merge){ [IO.File]::AppendAllLines((Join-Path $Out 'summary.txt'),$summary) }else{ [IO.File]::WriteAllLines((Join-Path $Out 'summary.txt'),$summary) }
  Write-Output ('report: '+(Join-Path $Out 'report.json'))
}
