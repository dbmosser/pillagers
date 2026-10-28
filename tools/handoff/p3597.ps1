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

# WIRT OFFER FITS AT 4K: THE NEED LINE SITS INSIDE ITS PANEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #gamblemodal #wirtlotbtn{position:relative;flex:none;width:100%;min-width:0;min-height:56px;margin-bottom:32px;}
'@ @'
#root #gamblemodal #wirtlotbtn{position:relative;flex:none;width:100%;min-width:0;min-height:56px;margin-bottom:32px;}
/* v35.xx (cw-wirtfit), menus master pass 2026-10-28, his 4K screen: the offer column ran 37px past its panel, so the buy button and its need line hung under the panel border. The picture tile gives up height first (192 down to 96, the inline flex:none it is built with is overridden), so the buy button lines up with the gamble button and the need line sits inside the panel. */
#root #gamblemodal #wirtlot > span[title]{flex:1 1 192px !important;min-height:96px;max-height:192px;height:auto !important;}
#root #gamblemodal #wirtlot > span[title] img{width:auto !important;height:calc(100% - 16px) !important;max-height:176px;aspect-ratio:1/1;}
'@

SubRx @'
var VER='35.96';
'@ @'
var VER='35.97';
'@

$pat = "(?m)^  now:'v35\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.97: at 4k the wirt buy button lines up with the gamble button and its need line sits inside the panel Check 35.97 fails on v35.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
