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

# PRE RAID WHOLE NAMES AND CHOSEN MAP TYPE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #sectormodal #srkitcol{gap:24px}
'@ @'
/* v28.xx (cw-cx-preraid-names): preserve whole pack names beside the existing steppers and buy slots, including when the list scrolls. */
#root #sectormodal #srkitcol{gap:16px;overflow-y:auto}
#root #sectormodal .srprow[data-pk]{flex:0 0 auto;min-height:48px;max-height:none;padding:4px 0;gap:8px}
#root #sectormodal .srprow[data-pk] .nm{white-space:normal;overflow:visible;text-overflow:clip;overflow-wrap:anywhere;line-height:1.1}
#root #sectormodal .srprow[data-pk] .st,#root #sectormodal .srprow[data-pk] .held{flex:none}
#root #sectormodal .srprow .srbuy.dis{opacity:1}
#root #sectormodal #sectorkitpick .kitb{height:auto;min-height:52px;padding-top:6px;padding-bottom:6px}
#root #sectormodal .kitb span{min-width:0;white-space:normal;overflow-wrap:anywhere}
'@

SubRx @'
#root #sectormodal #sectorpack{flex:0 1 auto;min-height:0;padding:16px 0;border-top:1px solid var(--ui-line);border-bottom:1px solid var(--ui-line)}
'@ @'
#root #sectormodal #sectorpack{flex:1 1 auto;min-height:150px;padding:8px 0;border-top:1px solid var(--ui-line);border-bottom:1px solid var(--ui-line)}
'@

SubRx @'
      var zw=Math.max(10,z.w*sc-6), fs=24, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=TX(String(z.name)), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;
'@ @'
      var zw=Math.max(10,z.w*sc-6), fs=20, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=TX(String(z.name)), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;
'@

SubRx @'
      while(fs>20&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px '+FF; }
'@ @'
      while(fs>14&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px '+FF; }
'@

SubRx @'
    c.font='600 22px '+FF; c.textAlign='right'; c.fillStyle='#e6f1fb'; put(TX(String(b.name||'')),ox+b.x*sc-8,oy+(b.y+b.h/2)*sc+5); n++; }
'@ @'
    c.font='600 18px '+FF; c.textAlign='right'; c.fillStyle='#e6f1fb'; put(TX(String(b.name||'')),ox+b.x*sc-8,oy+(b.y+b.h/2)*sc+5); n++; }
'@

SubRx @'
    c.font='600 22px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6'; put(TX('exit '+String.fromCharCode(97+i)),ox+e.x*sc,oy+e.y*sc+R+22); n++; }
'@ @'
    c.font='600 18px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6'; put(TX('exit '+String.fromCharCode(97+i)),ox+e.x*sc,oy+e.y*sc+R+22); n++; }
'@

SubRx @'
  // buildings darker with a light edge, names 20 px (shrinking to 12 to fit), exits teal and keyed rooms purple. Everything is still read from the sector's own data, never a made-up shape.
'@ @'
  // v28.xx (cw-cx-preraid-names): his design A pick (10-20), zones start at 20 px and shrink to 14; exits and keyed rooms stay 18. The 24 px comparison put the long dock over a room outline.
'@

SubRx @'
var VER='36.04';
'@ @'
var VER='36.05';
'@

$pat = "(?m)^  now:'v36\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.05: Pack names wrap beside the same controls. The pack keeps scroll space at 4K. Zones return to the chosen 20 px start and 14 px floor; exits and keyed rooms return to 18 px. The 24 px long dock label crowded a room outline at both resolutions. Comparison pictures: tools/handoff/console/notes/shots/o-09d-red-35.81-preraid-names-and-ledger-recipes-2/preraid-zones-20-1080.jpg, preraid-zones-24-1080.jpg, preraid-zones-20-4k.jpg and preraid-zones-24-4k.jpg. Terms and rewards keep their readability gains. Watch: scroll a long pack at 4K; full names, prices and steppers must stay readable and ascend must remain reachable. Check 36.05 fails on v36.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
