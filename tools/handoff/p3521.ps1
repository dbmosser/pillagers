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

# FULLSCREEN GATE AT ANY ZOOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
try{ var sc=window.screen; if(sc&&sc.width>0&&sc.height>0&&window.innerWidth>=sc.width-1&&window.innerHeight>=sc.height-1) return true; }catch(_sz){}
'@ @'
try{ var sc=window.screen, ow=window.outerWidth, iw=window.innerWidth, z=(ow>0&&iw>0)?ow/iw:0; if(sc&&sc.width>0&&sc.height>0&&z>0&&ow>=sc.width-2&&window.innerHeight*z>=sc.height-2) return true; }catch(_sz){}   /* v35.xx (cw-fszoom), HIS REPORT (2026-10-27): "the version on the main PC doesn't have my mandatory fullscreen pages but the version on the VM does". His Chrome keeps 75 percent zoom for localhost; inner sizes are CSS px and grow as zoom drops, screen is not, so a normal window passed as F11 and the gate never opened. The view height is put back in screen units (outer over inner width) before comparing. */
'@

SubRx @'
var VER='35.20';
'@ @'
var VER='35.21';
'@

$pat = "(?m)^  now:'v35\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.21: the fullscreen gate opens in a normal window at any page zoom Check 35.21 fails on v35.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
