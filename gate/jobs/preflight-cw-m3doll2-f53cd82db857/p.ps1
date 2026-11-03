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

# THE STASH DOLL: IT FILLS ITS PANEL, THE KEY HINTS NO LONGER SIT ON THE PANELS, THE LIST STANDS IN GROUPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<canvas id="gearcv" width="176" height="304"></canvas>
'@ @'
<canvas id="gearcv" width="280" height="484"></canvas>
'@

SubRx @'
  '#root #gearmodal #gearslots{display:grid;grid-template-columns:minmax(0,1fr) 176px minmax(0,1fr);gap:8px}'+
  '#root #gearmodal .gcol{display:grid;grid-auto-rows:96px;gap:8px;min-width:0}'+
  '#root #gearmodal #gearmid{display:flex;flex-direction:column;align-items:center;justify-content:space-between;gap:8px;min-width:0}'+
  '#root #gearmodal #gearpk{width:100%}'+
  '#root #gearmodal #gearcv{width:176px;height:304px;flex:none}'+
  '#root #gearmodal .gslot{display:flex;align-items:center;justify-content:flex-start;gap:8px;box-sizing:border-box;width:100%;height:96px;min-width:0;min-height:0;margin:0;padding:8px 12px;
'@ @'
  // v37.xx (cw-m3doll2), seen on the first pictures: a third of the doll panel stood empty under the sum. Slots 96 to about 136px high in one grid of four rows, figure 176 to 192px wide, names 22 to 24px, stats 20 to 24px.
  '#root #gearmodal #gearslots{flex:1 1 auto;min-height:408px;max-height:568px;display:grid;grid-template-columns:minmax(0,1fr) 192px minmax(0,1fr);grid-template-rows:repeat(4,minmax(0,1fr));gap:8px}'+
  '#root #gearmodal .gcol,#root #gearmodal #gearmid,#root #gearmodal #gearpk{display:contents}'+
  '#root #gearmodal #gearcl .gslot{grid-column:1}#root #gearmodal #gearcr .gslot{grid-column:3}#root #gearmodal #gearpk .gslot{grid-column:2;grid-row:4}'+
  '#root #gearmodal .gcol .gslot:nth-child(1){grid-row:1}#root #gearmodal .gcol .gslot:nth-child(2){grid-row:2}#root #gearmodal .gcol .gslot:nth-child(3){grid-row:3}#root #gearmodal .gcol .gslot:nth-child(4){grid-row:4}'+
  '#root #gearmodal #gearcv{grid-column:2;grid-row:1/4;width:100%;height:100%;min-height:0;object-fit:contain}'+
  '#root #gearmodal .gslot{display:flex;flex-direction:column;align-items:flex-start;justify-content:center;gap:4px;overflow:hidden;box-sizing:border-box;width:100%;height:auto;min-width:0;min-height:0;margin:0;padding:6px 12px;
'@

SubRx @'
  '#root #gearmodal .gslot b{font:700 22px/1.1 var(--f-cond);color:var(--gc)}'+
  '#root #gearmodal .gslot em{font:500 18px/1.1 var(--f-cond);font-style:normal;color:var(--tx-2);white-space:nowrap}'+
'@ @'
  '#root #gearmodal .gslot b{font:700 24px/1.1 var(--f-cond);color:var(--gc);white-space:nowrap}'+
  '#root #gearmodal .gslot em{font:500 var(--fs-body)/1.1 var(--f-cond);font-style:normal;color:var(--tx-2);white-space:nowrap}'+
'@

SubRx @'
  '#root #gearmodal #gearsum{display:flex;flex-wrap:wrap;gap:4px 24px;min-height:0;overflow:hidden;font:600 var(--fs-body)/1.25 var(--f-cond);color:var(--tx-1)}'+
'@ @'
  '#root #gearmodal #gearsum{flex:none;display:flex;flex-wrap:wrap;gap:4px 24px;font:600 24px/1.25 var(--f-cond);color:var(--tx-1)}'+
'@

SubRx @'
  '#root #gearmodal .glab{font:600 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2)}'+
'@ @'
  '#root #gearmodal .glab{font:600 var(--fs-body)/1.2 var(--f-cond);letter-spacing:.02em;color:var(--tx-2)}'+
'@

SubRx @'
  '#root #gearmodal #geartip .gv{margin-top:auto;font:700 var(--fs-title)/1 var(--f-cond)}'+
'@ @'
  '#root #gearmodal #geartip .gv{margin-top:auto;font:600 24px/1 var(--f-cond)}'+
'@

SubRx @'
  '#root #gearmodal .grow > span{display:flex;
'@ @'
  '#root #gearmodal .grow.gnew{margin-top:8px}'+
  '#root #gearmodal .grow > span{display:flex;
'@

SubRx @'
  '#root #gearmodal #gearsavebtn{min-height:48px;min-width:0;padding:0 12px;font:600 var(--fs-body)/1 var(--f-cond);white-space:nowrap;text-transform:none}'+
'@ @'
  '#root #gearmodal #gearsavebtn{min-height:48px;min-width:0;padding:0 12px;font:700 var(--fs-body)/1 var(--f-cond);letter-spacing:0;white-space:nowrap;text-transform:none}'+
  '#root #gearmodal #gearsavebtn:not(:disabled){background:var(--acc);border-color:var(--acc);color:var(--acc-ink)}'+
'@

SubRx @'
  '#root #gearmodal .gof{display:grid;grid-template-columns:minmax(0,1fr) 48px;gap:8px;flex:none}'+
  '#root #gearmodal .gofb{display:flex;align-items:center;justify-content:space-between;gap:8px;min-height:48px;
'@ @'
  '#root #gearmodal .gof{display:grid;grid-template-columns:minmax(0,1fr) 56px;gap:8px;flex:none}'+
  '#root #gearmodal .gofb{display:flex;align-items:center;justify-content:space-between;gap:8px;min-height:56px;
'@

SubRx @'
  '#root #gearmodal .gofx{min-height:48px;min-width:48px;
'@ @'
  '#root #gearmodal .gofx{min-height:56px;min-width:56px;
'@

SubRx @'
  'body:has(#gearmodal.on) #topright{display:none !important}'+
'@ @'
  'body:has(#gearmodal.on) #topright{display:none !important}'+
  'body:has(#gearmodal.on) #hubtoast{bottom:auto!important;top:12px}'+
  '#root #gearmodal > .ui-foot{height:auto!important;min-height:42px!important;padding:12px 0 0!important;box-sizing:border-box}'+
'@

SubRx @'
function gearRowHtml(pc){
'@ @'
function gearRowHtml(pc,nw){
'@

SubRx @'
class="grow" data-gp="'+pc.id+'"
'@ @'
class="grow'+(nw?' gnew':'')+'" data-gp="'+pc.id+'"
'@

SubRx @'
'<span><span class="gtr">'+tr.join('   ')+'</span>
'@ @'
'<span><span class="gtr">'+tr.join('&nbsp;&nbsp;&nbsp;')+'</span>
'@

SubRx @'
  L.sort(function(a,b){ return (b.r-a.r)||(b.pw-a.pw)||(a.id<b.id?-1:1); });
'@ @'
  var _ko=Object.keys(WORN_KINDS);   // v37.xx (cw-m3doll2), critic P1: a list of every kind reads as one wall; the same kinds stand together, a gap between them
  L.sort(function(a,b){ return (_ko.indexOf(a.k)-_ko.indexOf(b.k))||(b.r-a.r)||(b.pw-a.pw)||(a.id<b.id?-1:1); });
'@

SubRx @'
'<b>gear '+P.gear.length+'</b>'
'@ @'
'<b>stash '+P.gear.length+'</b>'
'@

SubRx @'
  for(i=0;i<L.length;i++) h+=gearRowHtml(L[i]);
'@ @'
  for(i=0;i<L.length;i++) h+=gearRowHtml(L[i],i>0&&L[i].k!==L[i-1].k);
'@

SubRx @'
    '<span class="bp"><i>'+escHtml(padB('A'))+'</i>wear</span>
'@ @'
    '<span class="bp"><i>d-pad</i>pick</span><span class="bp"><i>'+escHtml(padB('A'))+'</i>wear</span>
'@

SubRx @'
  if(!f){ el.innerHTML=''; return; }
'@ @'
  if(!f){ el.style.setProperty('--gc','var(--tx-2)'); el.innerHTML='<span class="gag">pick a piece</span>'; return; }   // v37.xx (cw-m3doll2): the panel never stands blank
'@

SubRx @'
var VER='37.43';
'@ @'
var VER='37.44';
'@

$pat = "(?m)^  now:'v37\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.44: slots are taller and hold the icon over the name, the figure is larger, the hints have their own row under the panels, the list groups pieces by kind with a gap and its head reads stash n, save outfit is the one lime button, the verdict word is calmer, the tip panel reads pick a piece until something is picked Check 37.44 fails on v37.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
