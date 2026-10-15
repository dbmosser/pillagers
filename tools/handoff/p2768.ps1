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

# CONTROLLER B CLOSES SETTINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(var i=0;i<bs.length;i++) if(/leave|close|not yet|keep my kit|back|done|return/i.test(bs[i].textContent||'')) { back=bs[i]; break; }
'@ @'
    // v27.68 (cloud-menus-pad-b-closes-settings), CLOUD HUNT 2026-10-15: B took the first button whose words read like a way out, and in Settings the MINIMAP ZOOM row reading CLOSE
    // comes before the window's own CLOSE, so B changed the zoom and left Settings open. A Settings option row (id go_...) is never the way out.
    for(var i=0;i<bs.length;i++) if(!/^go_/.test(bs[i].id||'')&&/leave|close|not yet|keep my kit|back|done|return/i.test(bs[i].textContent||'')) { back=bs[i]; break; }
'@

SubRx @'
var VER='27.67';
'@ @'
var VER='27.68';
'@

$pat = "(?m)^  now:'v27\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.68: B on a controller now closes Settings even when MINIMAP ZOOM is set to CLOSE, and leaves the zoom alone. Check 27.68 fails on v27.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
