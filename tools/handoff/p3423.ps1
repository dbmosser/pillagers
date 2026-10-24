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

# EXTRACTED CARD: HAUL FIGURE LEADS, NO SEASON TOTAL, RECOVERED GUNS AS CHIPS, DASHED EMPTY SLOTS, FOCUS RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var out=[], i, k, ln, m, names=[], cells, h, chips, lost=[], lostTxt='';
'@ @'
  var out=[], i, k, ln, m, names=[], cells, h, chips, lost=[], lostTxt='', recN=[], recHid='', recAt=-1;   // v28.xx (cw-haulread): recN, recHid and recAt gather the recovered guns into one chip row
'@

SubRx @'
    if(ln.indexOf('>ACHIEVEMENT: ')>=0){
      chips='';
'@ @'
    // v28.xx (cw-haulread), the critic on 76 (2 of 5, P1): "the xp line is clutter, the 1,200,000 figure most of all" and "the recovered lines explain rather than show". Q8, reason in notes/ui/changes.md: the "n of 1,200,000" total leaves the card (it stays as hidden text, the season total is on the Mainframe), and each "x recovered to the armoury" sentence is one name chip with a tick, the sentence kept as hidden text.
    if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(  &middot;  [\d,]+ of [\d,]+)(<\/span>.*)$/.exec(ln))){ out.push(m[1]+'<span class="ocsr">'+m[2]+'</span>'+m[3]); continue; }
    if((m=/^(.*) recovered to the armoury$/.exec(ln))){
      if(recAt<0){ out.push(''); recAt=out.length-1; }
      recN.push(m[1]); recHid+='<span class="ocsr">'+ln+'</span>';
      out[recAt]='<div class="ocachs">'+recN.map(function(n){ return '<span class="ocach ocok">'+n+'</span>'; }).join('')+'</div>'+recHid; continue;
    }
    if(ln.indexOf('>ACHIEVEMENT: ')>=0){
      chips='';
'@

SubRx @'
strip.insertAdjacentHTML('afterend','<div class="haultot" id="haultot">HAUL  $0</div>');
'@ @'
strip.insertAdjacentHTML('beforebegin','<div class="haultot" id="haultot">HAUL  \x240</div>');   // v28.xx (cw-haulread): the figure leads, the tiles that make it sit under it
'@

SubRx @'
  #root .ocach.ocok::before{ content:'\2713'; margin-right:8px; color:var(--ok); }

'@ @'
  #root .ocach.ocok::before{ content:'\2713'; margin-right:8px; color:var(--ok); }
  /* v28.xx (cw-haulread), the critic on 76 (2 of 5): "an oversized empty tile overlaps its neighbours, four empty slots look broken", "the strip, not the number, is what the eye hits first", "+11 more is dim", "no focus ring on the one action". A slot not yet revealed is a dashed empty outline, the arriving tile settles at 1.12x (was 1.25x) so it no longer covers its neighbours, the +n more count is tx-1, the haul figure is 800 weight with 24px above and 8px below and the strip sits under it, and the one lime button draws a 3px lime ring when focused (keys or pad). */
  #root .ocwin .haulit.hid{ background:transparent !important; border:1px dashed var(--ui-line-hi) !important; }
  #root .ocwin .haulit.hid[data-r]{ border:1px dashed var(--ui-line-hi) !important; }
  @keyframes haulsettle{ 0%{ transform:scale(1.12); filter:brightness(2); } 100%{ transform:scale(1); filter:none; } }
  #root .ocwin .haulstrip>span:not(.haulit){ color:var(--tx-1) !important; }
  #root .haultot{ font-weight:800; margin:24px 0 8px; }
  #root .ocwin .haulstrip{ margin:8px 0 24px !important; }
  #root #oc_btn:focus-visible, #root #oc_btn.padfocus{ outline:3px solid var(--acc); outline-offset:4px; }
'@

SubRx @'
var VER='34.22';
'@ @'
var VER='34.23';
'@

$pat = "(?m)^  now:'v34\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.23: The extracted card shows the haul figure above the tiles, drops the season total and the recovered sentences from view, draws unrevealed tiles as dashed slots and rings the focused lime button. Check 34.23 fails on v34.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
