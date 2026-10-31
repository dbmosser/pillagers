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

if ($s.Contains("  {v:'36.95',what:")) { throw "check 36.95 is in the fixture already" }

SubRx @'
  {v:'36.94',what:
'@ @'
  {v:'36.95',what:'cw-urgclamp: an inbound ship whose countdown is longer than the extract wait still draws the frame (the beacon glow radius never goes negative); check 34.89 staged 40 against a wait of 20 and threw an arc radius of -10',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof __frame!=='function') return 'SKIP: no raid staging in this fixture';
     var err=null, g, z;
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1);
     try{
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       z=g&&g.zones&&g.zones[0];
       if(!z) return 'SKIP: no zone to call a ship to';
       g.active=z; z.open=true; z.beaconT=CFG.extractWait*2; g.beaconT=CFG.extractWait*2;
       for(var q=0;q<4;q++) __frame(0.016);
     }catch(e){ err='the frame threw with the countdown at twice the extract wait: '+(e&&e.message||e); }
     finally{ try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
     return err; }},
  {v:'36.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
