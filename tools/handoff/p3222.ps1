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

# Party, sector, terms: short lines, bigger type (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="msub">Up to four pillagers, linked by invite code. The others in your party walk the Undercroft floor with you, with their names over their heads, and when the host takes the party up, everyone ascends into the same raid.</div>
'@ @'
<div class="msub">Up to four pillagers, one invite code.</div>
'@

SubRx @'
>TRADING. Up top: open the backpack, pick the item and press Z (Y on a controller) to drop it at your feet; your teammate searches the pile like any box. In the Undercroft: right-click a stash item (Y on a controller) and choose Drop on the floor; your teammate walks to the crate and presses E (A on a controller).</div>
'@ @'
>Trade: drop it on the floor, your teammate picks it up.</div>
'@

SubRx @'
line+='<div style="margin-top:5px">Your own gun is in your stash. Close this and choose Equip as your gun on it to take it up.</div>';
'@ @'
line+='<div style="margin-top:5px">Your gun is in your stash. Equip it first.</div>';
'@

SubRx @'
'<div style="margin-top:5px;color:var(--amber)">You ascend with <b>no armour on</b>. Equip Armour Plates on the '+
      'surface. Each absorbs '+Math.round(RG.absorb*100)+'% of every hit until it is gone, up to a cap of '+cap+'.</div>';
'@ @'
'<div style="margin-top:5px;color:var(--amber)">You ascend with <b>no armour on</b>. Equip plates on the surface.</div>';
'@

SubRx @'
  #partymodal textarea{ font-size:13px; word-break:break-all; }
'@ @'
  #partymodal textarea{ font-size:13px; word-break:break-all; }
/* v28.xx (cw-uc-lines) b-31 step 7, critic on 05/06/07 (explaining paragraphs, 13px text in an empty card): sector surface and weather hint lines hidden, party and terms text scaled to 18px. */
#root #condhint, #root #wxhint{ display:none !important; }
#root #partymodal .msub, #root #partymodal .hint, #root #termsmodal .msub{ font-size:18px; line-height:1.4; }
#root #partymodal textarea{ font-size:16px; }
#root #termsmodal .plist{ font-size:18px; }
'@

SubRx @'
var VER='32.21';
'@ @'
var VER='32.22';
'@

$pat = "(?m)^  now:'v32\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.22: The party and sector pages lose their explaining sentences and the party and terms text is larger. Check 32.22 fails on v32.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
