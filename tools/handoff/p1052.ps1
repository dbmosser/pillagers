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

# ============ HIS NOTE, 2026-09-03 about 20:00: "'Search Crate, 1 Item left --
# ============ this text is too small". The prompt over a container was drawn
# ============ at TYPE.label, 12 source px, 15.6 on a 1080p screen, and the
# ============ count under the search bar at TYPE.micro, 10 px, 13 rendered: the
# ============ smallest type in the game, on the one line he reads while deciding
# ============ whether one more pull is worth the time. The prompt is a callout
# ============ now (TYPE.head, 15 px, 19.5 rendered) and the count a label (12 px,
# ============ 15.6 rendered), with the pill behind the count and the line below
# ============ the prompt grown to fit.

# 1. The prompt over a container: [E] SEARCH CRATE.
SubRx @'
      ctx.font=FS(TYPE.label); ctx.textAlign='center';
      ctx.fillStyle='#ffc04a';
      // A raider's corpse is the one container with a NAME, and saying it makes
'@ @'
      ctx.font=FS(TYPE.head); ctx.textAlign='center';   // v10.52, his note: the prompt was too small
      ctx.fillStyle='#ffc04a';
      // A raider's corpse is the one container with a NAME, and saying it makes
'@
# 1b. The item name under a single-item prompt keeps clear of the bigger line.
SubRx @'
          ctx.fillText(dit.name,s.x,s.y+LH(13)); }
'@ @'
          ctx.fillText(dit.name,s.x,s.y+LH(17)); }
'@

# 2. The count under the search bar: 1 item left.
SubRx @'
        ctx.font=FS(TYPE.micro); ctx.textAlign='center';
        var _lw2=ctx.measureText(_lbl).width;
        ctx.fillStyle='rgba(6,9,13,.72)';
        ctx.fillRect(s2.x-_lw2/2-LH(5),s2.y-LH(24),_lw2+LH(10),LH(13));
        ctx.fillStyle=_bc;
        ctx.fillText(_lbl,s2.x,s2.y-LH(14));
'@ @'
        ctx.font=FS(TYPE.label); ctx.textAlign='center';   // v10.52, his note: "1 Item left" was too small
        var _lw2=ctx.measureText(_lbl).width;
        ctx.fillStyle='rgba(6,9,13,.72)';
        ctx.fillRect(s2.x-_lw2/2-LH(6),s2.y-LH(27),_lw2+LH(12),LH(16));
        ctx.fillStyle=_bc;
        ctx.fillText(_lbl,s2.x,s2.y-LH(15));
'@

SubRx @'
var VER='10.51';
'@ @'
var VER='10.52';
'@
SubRx @'
  now:'v10.51: behind the terminal in the Undercroft you no longer vanish into the plinth: the room shows you through the wall the way a raid does, and the walk cycle follows the ground you cover, so you never run in place against a wall.',
'@ @'
  now:'v10.52: the prompt over a crate and the "1 item left" count under the search bar are bigger. The count was the smallest type in the game, on the one line you read while deciding whether one more pull is worth the time.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
