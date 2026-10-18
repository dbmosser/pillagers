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

# Party pages: the slide ghost floats over the card (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; min-width:calc(var(--menu-w) * .4 * var(--attz,1)); justify-self:end; box-sizing:border-box; height:calc(var(--btn-h) * var(--attz,1)); min-height:0; display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); font-size:calc(var(--fs-body) * var(--attz,1)); line-height:1; border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
'@ @'
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; min-width:calc(var(--menu-w) * .4 * var(--attz,1)); justify-self:end; box-sizing:border-box; height:calc(var(--btn-h) * var(--attz,1)); min-height:0; display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); font-size:calc(var(--fs-body) * var(--attz,1)); line-height:1; border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
/* v28.xx (cw-party-att4): the tab slide (UIM.tabOut) puts a ghost copy of the old page in the attract for 200 ms; in the page column that copy took a grid row and the card jumped. The ghost floats over the card cell instead. */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage.uimghost{ position:absolute; grid-column:1; grid-row:2; left:auto; top:auto; transform:none; order:1; }
'@

SubRx @'
var VER='29.86';
'@ @'
var VER='29.87';
'@

$pat = "(?m)^  now:'v29\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.87: The board and how to play pages change without a jump. Check 29.87 fails on v29.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
