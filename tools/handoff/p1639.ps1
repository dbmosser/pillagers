$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# BLOTTER GENTLER, AND THE MENUS FEEL IT (his notes).

SubRx @'
  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length) return;
'@ @'
  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length){ buzzMenuFx(0,0); return; }
'@

SubRx @'
  var dr=8.5*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*(1-Math.exp(-buzzLevel('lsd')*1.8/7));
'@ @'
  var _lsd=buzzLevel('lsd');
  var dr=8.5*(1-Math.exp(-buzzLevel('drunk')*1.8/7)), ac=8.5*(1-Math.exp(-_lsd*1.8/7))*Math.min(1,0.5*_lsd+0.5*Math.max(0,_lsd-1));   // v16.39, his note: one hit of Blotter is half as strong; two or more hits are as before
  buzzMenuFx(dr,ac);   // v16.39, his note: Liquor and Blotter reach the menu screens too
'@

SubRx @'
function drawBuzzFx(){
'@ @'
// v16.39, HIS NOTE: blotter and liquor should affect the menu screens too. The open panels (every .modal that is on, and the
// pause box) sway and blur with Liquor and shift colour with Blotter, at the strength the world has, gentler so text stays
// readable. Written only when it changes; cleared when the buzz is gone.
var BUZZMENU='';
function buzzMenuFx(dr,ac){
  var f='', tr='', t=BUZZT*0.4, els, i, key;
  if(dr>0.05){ f+='blur('+Math.min(dr*0.18,1.4).toFixed(2)+'px) '; tr='translate('+(Math.sin(t*0.7)*dr*1.6).toFixed(1)+'px,'+(Math.cos(t*0.5)*dr*1.0).toFixed(1)+'px) rotate('+(Math.sin(t*0.3)*dr*0.18).toFixed(2)+'deg)'; }
  if(ac>0.05){ f+='hue-rotate('+Math.round(Math.sin(t*0.6)*ac*14)+'deg) saturate('+(1+ac*0.10).toFixed(2)+')'; if(!tr) tr='skewX('+(Math.sin(t*0.8)*ac*0.35).toFixed(2)+'deg)'; }
  key=f+'|'+tr;
  if(key===BUZZMENU&&!f) return;
  BUZZMENU=key;
  try{
    els=document.querySelectorAll('.modal.on > *, .pausebox');
    for(i=0;i<els.length;i++){ els[i].style.filter=f; els[i].style.transform=tr; }
    if(!f){ els=document.querySelectorAll('.modal > *'); for(i=0;i<els.length;i++) if(els[i].style.filter||els[i].style.transform){ els[i].style.filter=''; els[i].style.transform=''; } }
  }catch(_bm){}
}
function drawBuzzFx(){
'@

SubRx @'
var VER='16.38';
'@ @'
var VER='16.39';
'@

$pat = "(?m)^  now:'v16\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.39: BLOTTER GENTLER, AND THE MENUS FEEL IT. His notes: one hit of Blotter should be less intense, and Blotter and Liquor should affect the menu screens too. One hit now draws at half strength; two or more hits are as before. The open panels (stash, sector page, stations, pause box) sway and blur with Liquor and shift colour with Blotter, gentler than the world so text stays readable. Check 16.39 fails on v16.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
