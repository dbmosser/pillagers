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

# TV-size text in the demo (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
keymap:{},keymapV:2,crashes:[]};
'@ @'
keymap:{},keymapV:2,crashes:[],uiScale:1.5,menuZoom:1.25};   // v28.xx (cw-tvtext), his answer Q21 (2026-10-18): "TV-size text is on by default in the demo". The party plays on two TVs 6 to 10 ft away: HUD size 150 percent (UISCALES step 3) with the matching menu zoom (1.5 / 1.2), the pair hudSizeStep sets. Settings can still change it for the night; arcadeSandboxOut puts his own profile back
'@

SubRx @'
  netUpPutP(JSON.stringify(sb));
  try{ KEYS.inv=null; keysInv(); }catch(_ki){}
  return true;
'@ @'
  netUpPutP(JSON.stringify(sb));
  try{ KEYS.inv=null; keysInv(); }catch(_ki){}
  try{ applyMenuZoom(); }catch(_tz){}   // v28.xx (cw-tvtext): the TV size takes hold at once
  return true;
'@

SubRx @'
var VER='30.28';
'@ @'
var VER='30.29';
'@

$pat = "(?m)^  now:'v30\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.29: The demo starts with bigger text for the TVs. Check 30.29 fails on v30.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
