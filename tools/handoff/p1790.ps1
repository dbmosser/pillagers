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

# THE WELCOME PACK SHOWS ITS ITEMS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    rows+='<div class="row"><div style="flex:1"><b class="r-'+rr2+'">'+W.name+'</b><div class="hint">'+rr2+' gun, to your stash</div></div></div>'; }
'@ @'
    rows+='<div class="row"><canvas class="wpic" data-g="'+W.id+'" width="56" height="56" style="flex:none;margin-right:14px"></canvas><div style="flex:1"><b class="r-'+rr2+'">'+W.name+'</b><div class="hint">'+rr2+' gun, to your stash</div></div></div>'; }   // v17.90: with its icon
'@

SubRx @'
    rows+='<div class="row"><div style="flex:1"><b class="r-'+(it.r||'common')+'">'+it.name+(counts[k]>1?' x'+counts[k]:'')+'</b><div class="hint">to your stash</div></div></div>'; }
'@ @'
    rows+='<div class="row"><canvas class="wpic" data-k="'+k+'" width="56" height="56" style="flex:none;margin-right:14px"></canvas><div style="flex:1"><b class="r-'+(it.r||'common')+'">'+it.name+(counts[k]>1?' x'+counts[k]:'')+'</b><div class="hint">to your stash</div></div></div>'; }   // v17.90: with its icon
'@

SubRx @'
  box.innerHTML=rows;
  document.getElementById('welcometake').onclick=function(){
'@ @'
  box.innerHTML=rows;
  try{ var _wc=box.querySelectorAll('canvas.wpic'), _wi, _wx; for(_wi=0;_wi<_wc.length;_wi++){ _wx=_wc[_wi].getContext('2d'); if(!_wx) continue; try{ if(_wc[_wi].getAttribute('data-g')) gunIcon(_wx,_wc[_wi].getAttribute('data-g'),28,28,40); else drawItemIcon(_wx,_wc[_wi].getAttribute('data-k'),28,28,40); }catch(_we){} } }catch(_wl){}   // v17.90: the icons
  document.getElementById('welcometake').onclick=function(){
'@

SubRx @'
var VER='17.89';
'@ @'
var VER='17.90';
'@

$pat = "(?m)^  now:'v17\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.90: The WELCOME PACK shows a picture of each item beside its name. Check 17.90 fails on v17.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
