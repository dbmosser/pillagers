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

# THE WANTED STRIP READS FROM THE COUCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<span id="wanted" style="display:none;margin-left:auto;margin-right:16px;align-items:center;gap:16px;white-space:nowrap;overflow:hidden;min-width:0;font-size:14px;font-weight:400;letter-spacing:.06em;color:var(--tx-1)"></span>
'@ @'
<span id="wanted" style="display:none;margin-left:auto;margin-right:24px;align-items:center;gap:24px;white-space:nowrap;overflow:hidden;min-width:0;font-size:16px;font-weight:600;letter-spacing:.04em;color:var(--tx-2)"></span>
'@

SubRx @'
        iconImgHTML(_wl[_wi],18,1)+'<span>'+escHtml(_wn)+'</span><b style="color:var(--warn);font-weight:700">$'+sellPriceOf(_wl[_wi]).toLocaleString()+'</b></span>';
    }
    _wd.innerHTML=_wh?('<span style="font-weight:700;letter-spacing:.1em;color:var(--tx-2)">wanted +50%</span>'+_wh):'';
'@ @'
        iconImgHTML(_wl[_wi],20,1)+'<span style="color:var(--tx-2)">'+escHtml(_wn)+'</span><b style="color:var(--tx-1);font-weight:700">$'+sellPriceOf(_wl[_wi]).toLocaleString()+'</b></span>';   // v37.xx (cw-m1mkt3): 16px, names tx-2, prices tx-1
    }
    _wd.innerHTML=_wh?('<span style="font-weight:700;letter-spacing:.08em;color:var(--warn)">wanted +50%</span>'+_wh):'';
'@

SubRx @'
var VER='37.23';
'@ @'
var VER='37.24';
'@

$pat = "(?m)^  now:'v37\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.24: the wanted strip is 16px with 24px between items; the label is in the warn colour, the names in the second text colour and the prices in the first Check 37.24 fails on v37.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
