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

# THE WELCOME PACK HAS ONE FRAME AND A LEFT TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #welcomemodal > .ui-foot{ margin-top:14px !important; }

'@ @'
  #root #welcomemodal > .ui-foot{ margin-top:14px !important; }
  /* v28.xx (cw-welcomeleft), the critic on v30.07 (02 = 2 of 5, better than before): "a double frame (the list has its own border), a centred title against left content, 15px buttons under the 56px floor, 13px sub-lines". One frame: the list loses its border and inset. The title is left on the content edge at the 32px title size. Names are 20px, hints 16px. Both buttons are the button height, 200px wide at least. Restyle only; his words stay. */
  #root #welcomemodal h3{ text-align:left; width:100%; max-width:880px; font-size:32px; }
  #root #welcomemodal #welcomelist{ border:0 !important; padding:0 !important; }
  #welcomelist .row b{ font-size:20px; }
  #welcomelist .row .hint{ font-size:16px; }
  #root #welcomemodal > .ui-foot button{ min-height:56px !important; min-width:200px; font-size:20px !important; }

'@

SubRx @'
var VER='30.08';
'@ @'
var VER='30.09';
'@

$pat = "(?m)^  now:'v30\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.09: The welcome pack has one frame, a left title and bigger buttons. Check 30.09 fails on v30.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
