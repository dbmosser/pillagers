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

# THE WANTED STRIP MOVES INTO THE STASH HEADER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        <div id="wanted" style="display:none;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:8px"></div><!-- v37.xx (cw-m1mkt): the three wanted items of the day -->
        <button id="sellall"
'@ @'
        <button id="sellall"
'@

SubRx @'
          <div class="lohead">STASH<em><span id="stashn">0</span> held</em></div>
'@ @'
          <div class="lohead">STASH<span id="wanted" style="display:none;margin-left:auto;margin-right:16px;align-items:center;gap:16px;white-space:nowrap;overflow:hidden;min-width:0;font-size:14px;font-weight:400;letter-spacing:.06em;color:var(--tx-1)"></span><em><span id="stashn">0</span> held</em></div><!-- v37.xx (cw-m1mkt2): the wanted strip in the header row -->
'@

SubRx @'
      _wh+='<span data-want="'+_wl[_wi]+'" style="height:28px;padding:0 8px;font-size:16px;letter-spacing:.04em;border:1px solid var(--ui-line-hi);border-radius:4px;display:inline-flex;align-items:center;gap:6px">'+
        iconImgHTML(_wl[_wi],20,1)+'<span>'+escHtml(_wn)+'</span><b style="color:var(--amber);font-weight:600">$'+sellPriceOf(_wl[_wi]).toLocaleString()+'</b></span>';
    }
    _wd.innerHTML=_wh?('<span style="font-size:16px;letter-spacing:.04em;color:var(--amber)">wanted +50%</span>'+_wh):'';
    _wd.style.display=_wh?'flex':'none';
'@ @'
      _wh+='<span data-want="'+_wl[_wi]+'" style="display:inline-flex;align-items:center;gap:6px">'+   // v37.xx (cw-m1mkt2): flat, in the header row
        iconImgHTML(_wl[_wi],18,1)+'<span>'+escHtml(_wn)+'</span><b style="color:var(--warn);font-weight:700">$'+sellPriceOf(_wl[_wi]).toLocaleString()+'</b></span>';
    }
    _wd.innerHTML=_wh?('<span style="font-weight:700;letter-spacing:.1em;color:var(--tx-2)">wanted +50%</span>'+_wh):'';
    _wd.style.display=_wh?'inline-flex':'none';
'@

SubRx @'
var VER='37.21';
'@ @'
var VER='37.22';
'@

$pat = "(?m)^  now:'v37\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.22: the three wanted items sit in the stash header row beside the held count (label, icon, name, price in the warn colour), so the grid keeps its full height Check 37.22 fails on v37.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
