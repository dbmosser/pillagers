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

if ($s.Contains("  {v:'31.34',what:")) { throw "check 31.34 is in the fixture already" }

SubRx @'
  {v:'31.33',what:
'@ @'
  {v:'31.34',what:'the downed timer has its own centred row under the word down, and the plate is 480 wide with room for it (critic on screen 34: one centred column)',
   run:function(){
     if(typeof downPlateRect!=='function') return 'no downPlateRect';
     var r=downPlateRect(960,500,39,19,false,false,false,null,true), g, p, i, d0;
     if(r.w!==480) return 'the plate is '+r.w+' wide, not 480';
     if(r.h<170) return 'the plate leaves no row for a centred timer ('+r.h+' tall, wants 170 or more)';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; g.ents.length=0; p.hp=0; p.downed=true; p.downT=60; p.revived=1; p.iv=99; p.pendKiller=null;
       if(typeof __vpAlive==='function'&&!__vpAlive()) return null;
       d0=DP_DRAWS; for(i=0;i<3;i++) __loop(performance.now()+i*17);
       if(DP_DRAWS<=d0) return 'a downed frame drew no plate';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
