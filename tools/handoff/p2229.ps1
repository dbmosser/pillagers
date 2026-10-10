$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# THE TEAMMATE KIT CARD SAYS THE PARTY GOES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    '<br><br><b>The freebie kit</b>: '+escHtml(freeKitText());
'@ @'
    '<br><br><b>The freebie kit</b>: '+escHtml(freeKitText());
  // v22.29, from the whole-game bug hunt of 2026-10-08 (K43): A TEAMMATE IS TOLD HIS PARTY GOES UP WITHOUT HIM ANSWERING. On a
  // teammate's card Not yet sent nothing to the host, whose timer (NET_KIT_WAIT, v16.37) takes the whole party up anyway, so a
  // player who backed out to buy a Medkit first was pulled up 15 seconds later with whatever was packed. The host still takes
  // everyone up; the teammate's card now says so, and its way out reads KEEP MY KIT, which is what it does.
  if(mate&&ss) ss.innerHTML+='<br><br><b>PARTY IS GOING UP</b> \u00b7 Auto-ascend in '+NET_KIT_WAIT+' seconds with your current kit';   // in the shooter voice (his order of 2026-10-09)
'@

SubRx @'
  ASKBACK=mate?null:'sectormodal';
'@ @'
  ASKBACK=mate?null:'sectormodal';
  (function(){ var _no=document.getElementById('askno'); if(_no) _no.textContent=mate?'KEEP MY KIT':'Not yet'; })();   // v22.29 (K43): the way out of a teammate card says what it does
'@

SubRx @'
  ASKBACK='tradermodal';   // v12.68: this question is about the bench, so come back to it
'@ @'
  (function(){ var _no=document.getElementById('askno'); if(_no) _no.textContent='Not yet'; })();   // v22.29 (K43): this card declines with Not yet, whatever the last kit card said
  ASKBACK='tradermodal';   // v12.68: this question is about the bench, so come back to it
'@

SubRx @'
    for(var i=0;i<bs.length;i++) if(/leave|close|not yet|back|done|return/i.test(bs[i].textContent||'')) { back=bs[i]; break; }
'@ @'
    for(var i=0;i<bs.length;i++) if(/leave|close|not yet|keep my kit|back|done|return/i.test(bs[i].textContent||'')) { back=bs[i]; break; }
'@

SubRx @'
var VER='22.28';
'@ @'
var VER='22.29';
'@

$pat = "(?m)^  now:'v22\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.29: In co-op, the kit question tells a teammate the party goes up without him answering, and its way out reads KEEP MY KIT. Check 22.29 fails on v22.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
