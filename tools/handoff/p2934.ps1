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

# RUN INFO TEXT IS THE LABEL SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.font=FS(TYPE.micro);
    var pad=8, lh=LH(11), bw=Math.round(LH(165)), inner=bw-pad*2;
'@ @'
    ctx.font=FS(TYPE.label);   // v28.xx (cw-runinfo16), UI step 4 (style guide: 16 px floor for anything read): the run info panel was the micro size (13 px), a wall of small print
    var pad=8, lh=LH(13), bw=Math.round(LH(196)), inner=bw-pad*2;   // v28.xx (cw-runinfo16): and a little wider and taller in the row so the bigger text wraps no more than before
'@

SubRx @'
var VER='29.33';
'@ @'
var VER='29.34';
'@

$pat = "(?m)^  now:'v29\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.34: Run info text is bigger and easier to read. Check 29.34 fails on v29.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
