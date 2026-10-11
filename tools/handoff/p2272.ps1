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

# PICK-UPS AND GIFTS IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // An open offer to this player is answered before anything else; with none waiting the key offers as before.
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('Taking it.'); return true; }
'@ @'
  // An open offer to this player is answered before anything else; with none waiting the key offers as before.
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('TAKING IT','ally'); return true; }   // v22.72 (tr5fixc): the caps callout
'@

SubRx @'
  }
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('Taking it.'); return true; }
'@ @'
  }
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('TAKING IT','ally'); return true; }   // v22.72 (tr5fixc): the caps callout
'@

SubRx @'
      if(rose){ say((netSeatName(w)||'PILLAGER')+' revived.'); blip('pick'); }
'@ @'
      // v22.72 (tr5fixc), the review of raid text batch 5: HIS ORDER (2026-10-09), a raid line is a short caps callout. The line for a
      // teammate brought back up was his name and revived with a full stop; it is now his name in caps and IS BACK UP, an ally row.
      if(rose){ say(String(netSeatName(w)||'your teammate').toUpperCase()+' IS BACK UP','ally'); blip('pick'); }
'@

SubRx @'
  if(!G.netRevT) say('Reviving '+nm+'. Hold '+keyLabel('KeyE','E')+'.');
'@ @'
  // v22.72 (tr5fixc), the review of raid text batch 5: a pick-up no longer says a line as it starts. The line named him and the key
  // to hold, which the [E] REVIVE prompt at his body (v22.68) had just said, and the REVIVING bar over him shows it while it runs.
'@

SubRx @'
var VER='22.71';
'@ @'
var VER='22.72';
'@

$pat = "(?m)^  now:'v22\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.72: A teammate pick-up no longer repeats the revive prompt, and a teammate back up and a gift taken read MOTH IS BACK UP and TAKING IT. Check 22.72 fails on v22.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
