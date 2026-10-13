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

# NO SEARCH RESUMED LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(!G.sim&&(near.prog||0)>0) say('Search resumed, '+Math.round(100*near.prog/near.time)+'% done.');   // v11.94, HIS NOTE: resuming what
'@ @'
        // v24.xx (nosearchline), HIS ORDER (2026-10-12): "'Search resumed' get rid of this messaging". Picking a search back up said
        // Search resumed, N% done (v11.94) in the raid text, every time. The search bar already shows how far the box got, so the line was
        // chatter: picking a search back up now says nothing, and the progress carries on exactly as before.
'@

SubRx @'
    if(!G.sim&&(near.prog||0)>0) say('Search resumed, '+Math.round(100*near.prog/(near.time||1))+'% done.');
'@ @'
    // v24.xx (nosearchline), HIS ORDER (2026-10-12): no Search resumed line on a linked window either; the search bar shows the progress.
'@

SubRx @'
var VER='25.11';
'@ @'
var VER='25.12';
'@

$pat = "(?m)^  now:'v25\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.12: Picking a search back up no longer prints Search resumed; the search bar shows how far it got. Check 25.12 fails on v25.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
