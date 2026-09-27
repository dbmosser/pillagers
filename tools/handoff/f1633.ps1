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

if ($s.Contains("  {v:'16.33',what:")) { throw "check 16.33 is in the fixture already" }

SubRx @'
  {v:'16.32',what:
'@ @'
  {v:'16.33',what:'the what is new card catches up on co-op: split speakers, teammate health on the HUD, your heals on a teammate, pause when every player has paused, the host watching until the party is out',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], t=String((wn.lines||[])[1]||'').toUpperCase();
     ['LEFT SPEAKER','HEALTH AND ARMOUR','ON A TEAMMATE','EVERY PLAYER HAS PAUSED','THE HOST WATCHES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the co-op line does not say '+w.toLowerCase()); });
     if(t.indexOf('ONE OF THE TWO')>=0) bad.push('the co-op line still says world sound plays from one window');
     return bad.length?bad.join('; '):null; }},
  {v:'16.32',what:
'@


SubRx @'
     if(all.indexOf('SOUND PLAYS FROM ONE OF THE TWO')<0) bad.push('the card does not say world sound plays from one window');
'@ @'
     if(all.indexOf('LEFT SPEAKER')<0) bad.push('the card does not say where each player sound plays');   // v16.33: split speakers are the default since v16.29
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
