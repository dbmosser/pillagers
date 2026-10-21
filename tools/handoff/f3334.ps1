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

if ($s.Contains("  {v:'33.34',what:")) { throw "check 33.34 is in the fixture already" }

SubRx @'
  {v:'33.33',what:
'@ @'
  {v:'33.34',what:'the Howler walks on its own short pneumatic step (the only walking machine that was on the pillager scuff), on the machine bus and the footsteps volume, the other machines unchanged',
   run:function(){
     if(typeof SPK_GEN!=='object'||typeof SPK_GEN.stepHowl!=='function') return 'there is no Howler step (no stepHowl)';
     var bad=[], k, ks=['sentry','warden','bulwark','crawler','raider','snitch','listener','choir'], want=['stepHeavy','stepHeavy','stepHeavy','step','step','step','step','step'], OFF, fr, src, i;
     if(stepSoundFor('howler')!=='stepHowl') bad.push('the Howler is not on its own step');
     for(i=0;i<ks.length;i++){ if(stepSoundFor(ks[i])!==want[i]) bad.push(ks[i]+' step changed to '+stepSoundFor(ks[i])); }
     if(SPK_CAT.stepHowl!=='mach') bad.push('the Howler step is not on the machine bus');
     if(typeof OfflineAudioContext==='function'){
       OFF=new OfflineAudioContext(1,22050,22050);
       try{ SPK.at.stepHowl=-9; fr=SPK_GEN.stepHowl(OFF,OFF.destination,1,0); if(!fr||!fr.g) bad.push('the Howler step made no sound'); }catch(e){ bad.push('the Howler step threw '+e); }
     }
     src=String((typeof _realBlip==='function')?_realBlip:blip);
     if(src.indexOf('step'+'Howl')<0) bad.push('the footsteps volume row does not cover the Howler step');
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
