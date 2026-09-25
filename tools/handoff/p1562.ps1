$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
    else { G.bagOpen=false; G.drag=null; }
    return;
  }
  // v15.49, pause audit finding 9: HOLDING ESC OR P DOES NOT FLICKER THE PAUSE BOX. Only TAB ignored a key repeat here, so a
'@ @'
    else { G.bagOpen=false; G.drag=null; }
    return;
  }
  // v15.62, menus audit finding: ESC AND TAB LEAVE THE END OF RAID CARD THROUGH ITS OWN BUTTON. The card that comes up after
  // an extraction, a death or an abandon is an .outcome, not a .modal, so the document ESC listener (escCloseTopModal) never
  // saw it. The page stays in state 'raid' with G.over set until the card is left, and every ESC and TAB line in here, the
  // pause toggle below among them, and backOut's raid branch all wait on !G.over, so both keys did nothing on the card. TAB is
  // also in the preventDefault list above, so it could not even move the focus to the button. Only the mouse on Log run and
  // return and controller B (v15.57) left the card, against his rule that every menu closes on ESC and the TAB line that says
  // it closes whatever is in front. A fresh ESC or TAB with the card up now presses the card's own Log run and return, so
  // ocCommit logs the run once with its tags and note exactly as a click does, and the return stops this function touching G
  // after the button has let it go. A key repeat does nothing, and a press while the note box has the focus still goes to the
  // note, as in every other window. No player text, no number and no seeded draw moved.
  if((code==='Escape'||code==='Tab')&&!repeat&&G&&G.over){
    var _ocw=document.getElementById('outcome');
    if(_ocw&&_ocw.classList.contains('on')){ if(ev) ev.preventDefault(); document.getElementById('oc_btn').click(); return; }
  }
  // v15.49, pause audit finding 9: HOLDING ESC OR P DOES NOT FLICKER THE PAUSE BOX. Only TAB ignored a key repeat here, so a
'@
SubRx @'
var VER='15.61';
'@ @'
var VER='15.62';
'@

$pat = "(?m)^  now:'v15\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.62: ESC AND TAB LEAVE THE END OF RAID CARD THROUGH ITS OWN BUTTON. On the card after an extraction, a death or an abandon, ESC and TAB did nothing, so only the mouse or controller B could leave it, against his rule that every menu closes on ESC. A fresh ESC or TAB on the card now presses Log run and return, so the run is logged once with its tags and note, exactly as a click logs it. Check 15.62 leaves one card by TAB and a second by ESC, each with a tag chosen and a note typed; it fails on v15.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
