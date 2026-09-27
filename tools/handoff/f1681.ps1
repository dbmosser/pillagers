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

if ($s.Contains("  {v:'16.81',what:")) { throw "check 16.81 is in the fixture already" }

SubRx @'
  {v:'16.80',what:
'@ @'
  {v:'16.81',what:'a sprint takes you out of focus aim: holding sprint while moving in focus aim drops it and lets go of the pad toggle, while focus aim standing still with sprint held stays',
   run:function(){
     if(typeof updatePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build cannot step the player';
     var bad=[], k0=null, p=null;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; k0=keys; keys={};
       p.stam=100; p.stamLock=false; p.stamRelease=0; p.downed=false; p.ads=true; PAD.adsTog=true;
       keys['ShiftLeft']=true;
       updatePlayer(0.016);
       if(!p.ads) return 'SKIP: staging: focus aim dropped with sprint held and no movement, so this cannot tell a sprint from something else';
       keys['KeyW']=true; p.ads=true; PAD.adsTog=true;
       updatePlayer(0.016);
       if(p.ads) bad.push('holding sprint while moving left focus aim on');
       if(PAD.adsTog) bad.push('holding sprint while moving left the pad focus aim toggle on');
     } finally { try{ keys=k0||{}; if(p) p.ads=false; PAD.adsTog=false; PAD.adsT=0; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.80',what:
'@

# v16.81: sprint wins over focus aim, so the aiming arm of 12.71 no longer describes a man who is not sprinting.
SubRx @'
       else if(A.mine>0) bad.push('holding the sprint key while AIMING laid '+A.mine+' scent marks over '+Math.round(A.ran)+' units, and everything on patrol within 170 units follows that scent, so he is hunted along a trail he never made at the speed he is slowest');
'@ @'
       else if(false&&A.mine>0) bad.push('holding the sprint key while AIMING laid '+A.mine+' scent marks over '+Math.round(A.ran)+' units, and everything on patrol within 170 units follows that scent, so he is hunted along a trail he never made at the speed he is slowest');   // v16.81 his order: sprint takes you out of focus aim, so sprint held while aiming IS a sprint and lays scent
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
