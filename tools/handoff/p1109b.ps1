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

# ============ AND THE SWEEP FOUND FOUR, WHICH MY OWN GREP HAD MISSED.
# ============
# ============ I searched the file for a wrong font-family and found none, and
# ============ was about to report the menus clean. The check reads what the
# ============ BROWSER computes instead, and caught four:
# ============   pnamein   ARIAL   the box he types his pillager's name into
# ============   delword   ARIAL   the box he types delete into to erase a save
# ============   resword   ARIAL   the box he types restore into, mine, v11.04
# ============   verlabel  TITAN ONE  the version, inheriting the wordmark's face
# ============
# ============ A GREP FINDS WHAT IS WRITTEN, NOT WHAT IS MISSING. An input does
# ============ not inherit its font in any browser; it needs to be told, and three
# ============ of them never were, so the first thing a new player types his name
# ============ into has been in the browser's default face the whole time.
SubRx @'
  .brand span { color:var(--ash); }
'@ @'
  .brand span { color:var(--ash); }
  /* v11.09, HIS NOTE 18: the version is a readout, not the wordmark, so it is in
     the game font. The name beside it keeps the display face on purpose. */
  #verlabel { font-family:'Rubik',system-ui,sans-serif; font-weight:700; letter-spacing:.18em; }
  /* v11.09: AN INPUT DOES NOT INHERIT ITS FONT. Three boxes he types into, his
     pillager's name among them, were in the browser default. A grep for a wrong
     family finds nothing when the rule is simply absent. */
  input, textarea, select, option { font-family:'Rubik',system-ui,sans-serif; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
