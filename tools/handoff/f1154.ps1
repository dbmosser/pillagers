$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.54 CHECK, inserted before the v11.53 entry. The words are read off the
# function the badge draws from, and a control proves the draw reads it. The
# old phrase is assembled so this check never matches its own text.
SubRx @'
  {v:'11.53',what:'holding Shift with movement while crouched leaves the crouch and sprints, a roll leaves the crouch, and walking without Shift keeps it (his notes of 2026-09-05)',
'@ @'
  {v:'11.54',what:'an extraction point badge names one of his four states in his words (sound the alarm to begin countdown; N s until extraction begins; extract now, N s until it ends; closed for the remainder of this raid) with the live seconds, and the HUD draws that badge',
   run:function(){
     if(typeof zoneBadge!=='function') return 'the extraction point badge still says OPEN or CLOSED; there is no state function to read';
     if(typeof drawHUD!=='function') return 'SKIP: no HUD draw in this build';
     var bad=[], oldWord=['EXTRACTION',' - OPEN'].join('');
     function want(z,exp,what){ var got=String(zoneBadge(z)); if(got!==exp) bad.push(what+' reads "'+got+'" and not "'+exp+'"'); }
     want({open:false,beaconT:null,hold:null},'EXTRACTION POINT - CLOSED FOR THE REMAINDER OF THIS RAID','a closed point');
     want({open:true,beaconT:null,hold:null},'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN','an open point nobody has called');
     want({open:true,beaconT:17.2,hold:null},'EXTRACTION POINT - 18S UNTIL EXTRACTION BEGINS','a called point with the beacon inbound');
     want({open:true,beaconT:0,hold:11.4},'EXTRACTION POINT - EXTRACT NOW! 12S UNTIL EXTRACTION ENDS','a landed point in its hold window');
     want({open:true,beaconT:null,hold:null},'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN','a point the extraction has left');
     // CONTROL: the HUD draw reads the function, or the words above are never on screen.
     var src=''; try{ src=drawHUD.toString(); }catch(_s){}
     if(src.indexOf('zoneBadge(')<0) bad.push('control: the HUD draw does not read zoneBadge, so the badge on screen is not these words');
     if(src.indexOf(oldWord)>=0) bad.push('control: the HUD draw still carries the old '+oldWord+' badge');
     return bad.length?bad.join('; '):null; }},
  {v:'11.53',what:'holding Shift with movement while crouched leaves the crouch and sprints, a roll leaves the crouch, and walking without Shift keeps it (his notes of 2026-09-05)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
