$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'34.98',what:")) { throw "check 34.98 is in the fixture already" }

SubRx @'
  {v:'34.97',what:
'@ @'
  {v:'34.98',what:'a frozen redraw (dt 0) does not feed the auto resolution window, so two redraws of a frozen frame stay identical on a slow PC',
   run:function(){
     if(typeof DRS==='undefined'||typeof drsTick!=='function') return 'SKIP: no auto resolution';
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     for(var f=0;f<3;f++) __loop(performance.now()+f*16.7);
     if(document.hidden) return 'SKIP: page hidden, the auto resolution does not tick';
     DRS.win=[]; DRS.slowT=0; DRS.fastT=0; DRS.frameGap=40; DRS.frameStart=performance.now();
     for(f=0;f<8;f++) __frame(0);
     var n=DRS.win?DRS.win.length:0;
     if(n||DRS.slowT>0) return 'frozen redraws fed the auto resolution window ('+n+' samples, slow time '+DRS.slowT.toFixed(0)+')';
     return null; }},
  {v:'34.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
