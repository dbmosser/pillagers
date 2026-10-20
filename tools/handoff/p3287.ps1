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

# TITLE TAGLINE USES THE SPACING TOKENS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #title #titletag{ margin:24px auto 16px;
'@ @'
#root #title #titletag{ margin:var(--sp-3) auto var(--sp-2);   /* v28.xx (cw-titletag-tokens): the tagline margin was raw 24px and 16px in the shared block; the same two steps as tokens (24 is sp-3, 16 is sp-2), so the shared block holds no raw sizes (53-corpus-reds-b, check 29.33) */
'@

SubRx @'
.wordmark{ font-size:96px; }
'@ @'
.wordmark{ font-size:calc(var(--fs-hero) * 12 / 7); }   /* v28.xx (cw-titletag-tokens): 96px as a token sum (56 x 12 / 7) */
'@

SubRx @'
top:32px; right:5vw; margin:0 !important; display:flex; gap:12px;
'@ @'
top:var(--sp-4); right:5vw; margin:0 !important; display:flex; gap:calc(var(--sp-1) * 1.5);
'@

SubRx @'
#titleres button{ min-height:48px; padding:0 24px; font-size:16px; }
'@ @'
#titleres button{ min-height:var(--btn-h-sm); padding:0 var(--sp-3); font-size:var(--fs-label); }
'@

SubRx @'
bottom:24px; margin:0 !important; text-align:center; font-size:16px !important;
'@ @'
bottom:var(--sp-3); margin:0 !important; text-align:center; font-size:var(--fs-label) !important;
'@

SubRx @'
left:5vw; bottom:24px; margin:0; font:600 var(--fs-fine)
'@ @'
left:5vw; bottom:var(--sp-3); margin:0; font:600 var(--fs-fine)
'@

SubRx @'
var VER='32.86';
'@ @'
var VER='32.87';
'@

$pat = "(?m)^  now:'v32\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.87: The title tagline margin comes from the shared spacing tokens. Check 32.87 fails on v32.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
