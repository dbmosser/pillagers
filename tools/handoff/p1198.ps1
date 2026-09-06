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

# FIRST TEN MINUTES AUDIT, 2026-09-06: the "N notes logged" line is drawn at
# y 26 against the right edge, inside the rectangle the enlarged corner
# credits and XP readout (v11.78) now fills, so the two print over each other
# from the first note he leaves, which is what the alpha card asks him to do.
SubRx @'
    ctx.fillText(T.notes.length+' note'+(T.notes.length>1?'s':'')+' logged',W-16,26); ctx.restore(); }
'@ @'
    // v11.98: BELOW THE CORNER READOUT, not through it. y 26 sat inside the
    // rectangle the v11.78 credits and XP readout now fills, so the line and
    // the readout printed over each other from the first note he left. The
    // CONDITIONS panel, which starts under the readout, starts under this too.
    var _nly=Math.max(26,Math.ceil(topRightBottom())+LH(14));
    ctx.fillText(T.notes.length+' note'+(T.notes.length>1?'s':'')+' logged',W-16,_nly); ctx.restore(); }
'@

SubRx @'
    by=Math.max(by,Math.ceil((topRightBottom()+8)/_cz));
'@ @'
    by=Math.max(by,Math.ceil((topRightBottom()+8+((T.notes&&T.notes.length)?LH(20):0))/_cz));   // v11.98: and under the notes-logged line when there is one
'@

# STAMPS.
SubRx @'
var VER='11.97';
'@ @'
var VER='11.98';
'@
$cnt=([regex]::Matches($s,"now:'v11\.97:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.97 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.97:[^']*'",{ param($m) "now:'v11.98: from the 2026-09-06 first-ten-minutes audit, the notes-logged line in the raid HUD was drawn at y 26 inside the enlarged corner readout of v11.78, so the two printed over each other from the first note. It sits below the readout now. Check 11.98 logs a note, draws a frame with the canvas text call recorded, and requires the line under the bottom edge of the readout; fails on v11.97.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
