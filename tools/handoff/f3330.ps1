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

if ($s.Contains("  {v:'33.30',what:")) { throw "check 33.30 is in the fixture already" }

SubRx @'
  {v:'33.29',what:
'@ @'
  {v:'33.30',what:'aiming breaks a sprint at once even with Shift still held, and the sprint comes back when aim lets go (his order 10-20)',
   run:function(){
     if(typeof updatePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build cannot step the player';
     var bad=[], k0=null, p=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; k0=keys; keys={};
       CFG.sprintTgl=0; G.sprintOn=false; G.shWas=false; G.crouchTog=false;
       p.stam=100; p.stamLock=false; p.stamRelease=0; p.downed=false; p.ads=false;
       keys['KeyD']=true; keys['ShiftLeft']=true;
       updatePlayer(0.016); updatePlayer(0.016);
       if(!G.sprinting) return 'SKIP: staging: Shift with a move key did not start a sprint';
       p.ads=true; PAD.adsTog=true;
       updatePlayer(0.016);
       if(!p.ads) bad.push('aim was dropped while Shift was held');
       if(G.sprinting) bad.push('still sprinting one frame after aim began with Shift held');
       p.ads=false;
       updatePlayer(0.016); updatePlayer(0.016);
       if(!G.sprinting) bad.push('aim let go with Shift still held did not bring the sprint back');
     } finally { try{ keys=k0||{}; if(p) p.ads=false; PAD.adsTog=false; PAD.adsT=0; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'33.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
