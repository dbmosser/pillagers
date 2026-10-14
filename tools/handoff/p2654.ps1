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

# SETTINGS POLISH FROM THE 1080P SHOTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #setlist .setjump{ position:sticky; top:0; z-index:3; display:block; min-height:0; padding:10px 16px; border-bottom:1px solid var(--ui-line); background:var(--ui-panel); }
'@ @'
  #root #setlist .setjump{ position:sticky; top:-3px; margin-top:-3px; z-index:3; display:block; min-height:0; padding:13px 16px 10px; border-bottom:1px solid var(--ui-line); background:var(--ui-panel); }
'@

SubRx @'
  #root #setlist .setjump button:hover:not(:disabled){ color:var(--acc); border-color:var(--acc); background:var(--ui-hover); }
'@ @'
  #root #setlist .setjump button:hover:not(:disabled){ color:var(--acc); border-color:var(--acc); background:var(--ui-hover); }
  #root #setlist .setjump button.on{ color:var(--acc); border-color:var(--acc); background:var(--acc-dim); }
  /* the section heads outrank the row labels (the label rule is more specific than the head rule, so the heads were the same 18px): a head is 21px, bold, wide */
  #root #setlist .row[style*="opacity:.7"] > div:first-child > b{ font-size:21px; font-weight:700; letter-spacing:.12em; }
'@

SubRx @'
function setSecMove(host){
'@ @'
// v26.xx (settingsfix): THE CHIP OF THE SECTION IN VIEW LIGHTS. setSecSpy finds the last section head at or above the top of the list (under the jump bar) and gives its chip the class on.
function setSecSpy(host){
  var bar=host.querySelector('.setjump'), bh=bar?bar.getBoundingClientRect().height:0, ht=host.getBoundingClientRect().top, cur=null, i, h, bs;
  for(i=0;i<SETSEC.length;i++){ h=document.getElementById(setSecId(SETSEC[i])); if(h&&h.getBoundingClientRect().top<=ht+bh+6) cur=SETSEC[i]; }
  bs=host.querySelectorAll('.setjump button');
  for(i=0;i<bs.length;i++) bs[i].classList.toggle('on',bs[i].getAttribute('data-sec')===cur);
  return cur;
}
function setSecMove(host){
'@

SubRx @'
  [].forEach.call(host.querySelectorAll('.setjump button'),function(b){ b.onclick=function(){ setSecJump(host,b.getAttribute('data-sec')); }; });
'@ @'
  [].forEach.call(host.querySelectorAll('.setjump button'),function(b){ b.onclick=function(){ setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); }; });
  host.onscroll=function(){ setSecSpy(host); }; setSecSpy(host);   // v26.xx (settingsfix)
'@

SubRx @'
  #root #keysnote{ max-width:1100px; margin:8px 0 12px;
'@ @'
  #root #keysnote{ flex:0 0 auto; max-width:1100px; margin:8px 0 12px;
'@

SubRx @'
  return '<div class="row" style="margin-top:14px;border-top:1px solid var(--steel-hi);padding-top:10px"><div style="flex:1"><b style="color:var(--amber);letter-spacing:.14em">KID MODE</b>'+
'@ @'
  return '<div class="row" style="opacity:.7"><div style="flex:1"><b>KID MODE</b>'+
'@

SubRx @'
['SUPERHOT MODE','`']
'@ @'
['SUPERHOT MODE','LEFT OF 1']
'@

SubRx @'
var VER='26.53';
'@ @'
var VER='26.54';
'@

$pat = "(?m)^  now:'v26\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.54: Settings polish: a flush jump bar that lights the section in view, a proper KID MODE head, and the key notes no longer squeezed. Check 26.54 fails on v26.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
