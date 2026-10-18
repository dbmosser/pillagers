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

if ($s.Contains("  {v:'30.46',what:")) { throw "check 30.46 is in the fixture already" }

SubRx @'
  {v:'30.45',what:
'@ @'
  {v:'30.46',what:'a Crawler in its hit flash is shoved 8 px away from the player (up from 5), half that at half the flash, and a raider still 5 px (his Q5 enemy feel)',
   run:function(){
     if(typeof animHitShift!=='function') return 'SKIP: no animHitShift';
     var g=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var px=g.player.x, py=g.player.y;
       var c=animHitShift({kind:'crawler',x:px+100,y:py,hitT:0.16});
       var h=animHitShift({kind:'crawler',x:px+100,y:py,hitT:0.08});
       var r=animHitShift({kind:'raider',x:px+100,y:py,hitT:0.16});
       if(!c||Math.abs(c.x-8)>0.01||Math.abs(c.y)>0.01) return 'a Crawler hit shove is '+JSON.stringify(c)+', not 8 px';
       if(!h||Math.abs(h.x-4)>0.01) return 'a Crawler at half the flash is shoved '+(h&&h.x)+', not 4 px';
       if(!r||Math.abs(r.x-5)>0.01) return 'a raider hit shove is '+(r&&r.x)+', not 5 px';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
