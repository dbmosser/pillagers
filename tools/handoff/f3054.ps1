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

if ($s.Contains("  {v:'30.54',what:")) { throw "check 30.54 is in the fixture already" }

SubRx @'
  {v:'30.53',what:
'@ @'
  {v:'30.54',what:'a Sentry in its hit flash is shoved only 3 px away from the player (down from 5), the raider 6.5, the Crawler 8 and an unnamed body 5 (his Q5 enemy feel)',
   run:function(){
     if(typeof animHitShift!=='function') return 'SKIP: no animHitShift';
     var g=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var px=g.player.x, py=g.player.y;
       var s=animHitShift({kind:'sentry',x:px+100,y:py,hitT:0.16});
       var sh=animHitShift({kind:'sentry',x:px+100,y:py,hitT:0.08});
       var r=animHitShift({kind:'raider',x:px+100,y:py,hitT:0.16});
       var c=animHitShift({kind:'crawler',x:px+100,y:py,hitT:0.16});
       var o=animHitShift({kind:'warden',x:px+100,y:py,hitT:0.16});
       if(!s||Math.abs(s.x-3)>0.01||Math.abs(s.y)>0.01) return 'a Sentry hit shove is '+JSON.stringify(s)+', not 3 px';
       if(!sh||Math.abs(sh.x-1.5)>0.01) return 'a Sentry at half the flash is shoved '+(sh&&sh.x)+', not 1.5 px';
       if(!r||Math.abs(r.x-6.5)>0.01) return 'a raider hit shove is '+(r&&r.x)+', not 6.5 px';
       if(!c||Math.abs(c.x-8)>0.01) return 'a Crawler hit shove is '+(c&&c.x)+', not 8 px';
       if(!o||Math.abs(o.x-5)>0.01) return 'an unnamed body hit shove is '+(o&&o.x)+', not 5 px';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
