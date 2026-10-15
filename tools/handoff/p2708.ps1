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

# THE HAUL REVEAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
s+='<span title="'+escHtml(ITEMS[keys[k]].name)+'" style="display:inline-block;margin:3px;padding:3px;border-radius:8px;
'@ @'
s+='<span class="haulit" data-k="'+keys[k]+'" data-r="'+(dispR(keys[k])||ITEMS[keys[k]].r||'common')+'" data-v="'+ival(keys[k])+'" title="'+escHtml(ITEMS[keys[k]].name)+'" style="display:inline-block;margin:3px;padding:3px;border-radius:8px;
'@

SubRx @'
if(n) lines.push('<span class="haulstrip" style="display:inline-block;margin:4px 0 2px">'+s+'</span>');
'@ @'
if(n) lines.push('<span class="haulstrip" data-sec="'+_secV+'" style="display:inline-block;margin:4px 0 2px">'+s+'</span>');   // v26.xx (career7): the value the card secured, for the reveal total
'@

SubRx @'
  document.getElementById('outcome').classList.add('on');
'@ @'
  document.getElementById('outcome').classList.add('on');
  if(how==='extract'&&!G.sim){ try{ haulRevealStart(); }catch(_hrv){} }   // v26.xx (career7): the haul reveals one by one
'@

SubRx @'
function buildTags(){
'@ @'
// v26.xx (career7), HIS YES (2026-10-14) to suggestion 36, THE HAUL REVEAL: "after an extract, the items reveal one by one with a rarity flash. It can be skipped with a click, ESC or pad A."
// The pictures under "N items secured" on the EXTRACTED card (the strip, up to twelve, dearest first) start hidden and come up one at a time, the cheapest first so the best lands
// last: about a sixth of a second each and half as long again for a purple or a gold one, each with a flash and a glow in its own rarity colour and the pick sound of that rarity
// (lootVoice, the one the pickup plays), under a running HAUL line in caps that counts up to the figure the card secured. A strip of one picture is not worth a reveal and
// shows at once. A real click anywhere on the card (the mouse, or ENTER and SPACE on its button), ESC or TAB, or A or B on a controller SKIPS it: the first
// press only fills the strip in and does not leave the card, the next press logs the run as before. An extraction only: a death or an abandon has no strip. The DEMO shows no
// card, so nothing changes there. Display only: nothing that is paid or kept moves.
var HAUL_REV=null, HAUL_LAST=0;
function haulRevealing(){ return !!(HAUL_REV&&HAUL_REV.i<HAUL_REV.list.length); }
function haulTotalLine(){
  var R=HAUL_REV, el;
  if(!R) return;
  el=document.getElementById('haultot'); if(!el) return;
  el.textContent='HAUL  $'+Math.round(R.sum).toLocaleString();
}
function haulRevealStart(){
  var w=document.getElementById('oc_manifest'), strip, its, i, list=[], sec;
  HAUL_REV=null;
  if(!w) return 0;
  strip=w.querySelector('.haulstrip'); if(!strip) return 0;
  its=strip.querySelectorAll('.haulit'); if(its.length<2) return 0;
  for(i=its.length-1;i>=0;i--){ list.push(its[i]); its[i].classList.add('hid'); }
  sec=+strip.getAttribute('data-sec')||0;
  strip.insertAdjacentHTML('afterend','<div class="haultot" id="haultot">HAUL  $0</div>');
  HAUL_REV={list:list,i:0,t:0.3,sum:0,sec:sec};
  HAUL_LAST=0;
  return list.length;
}
function haulShow(nd,quiet){
  var R=HAUL_REV, r=nd.getAttribute('data-r')||'common', k=nd.getAttribute('data-k')||'';
  nd.classList.remove('hid');
  if(!quiet){
    nd.style.setProperty('--hc',RCOL[r]||'#9da3a8'); nd.classList.add('pop');
    try{ if(k&&ITEMS[k]) sfx(lootVoice([k])); }catch(_sf){}
  }
  if(R){ R.sum+=(+nd.getAttribute('data-v'))||0; haulTotalLine(); }
}
function haulRevealTick(dt){
  var R=HAUL_REV, nd, r;
  if(!R||R.i>=R.list.length) return 0;
  R.t-=(dt>0?dt:0);
  while(R.t<=0&&R.i<R.list.length){
    nd=R.list[R.i++]; haulShow(nd,false);
    r=nd.getAttribute('data-r');
    R.t+=(r==='elite'||r==='gold')?0.26:0.17;
  }
  if(R.i>=R.list.length){ if(R.sec>0) R.sum=R.sec; haulTotalLine(); }
  return R.i;
}
function haulRevealSkip(){
  var R=HAUL_REV;
  if(!R||R.i>=R.list.length) return false;
  while(R.i<R.list.length) haulShow(R.list[R.i++],true);
  if(R.sec>0) R.sum=R.sec;
  haulTotalLine();
  return true;
}
(function(){
  var oc=document.getElementById('outcome');
  if(oc) oc.addEventListener('click',function(ev){ if(ev.isTrusted&&haulRevealing()){ ev.preventDefault(); ev.stopPropagation(); haulRevealSkip(); } },true);   // a real click (mouse or keyboard) on the card skips; the presses the game makes itself (ESC, pad A and B) skip in their own code
  setInterval(function(){ var n=(typeof performance!=='undefined')?performance.now():Date.now(), d=HAUL_LAST?Math.min(0.2,(n-HAUL_LAST)/1000):0.04; HAUL_LAST=n; try{ haulRevealTick(d); }catch(_ht){} },40);
})();
careerStyle('careercss7',
  '.haulit{transition:opacity .12s}'+
  '.haulit.hid{opacity:0}'+
  '.haulit.pop{animation:haulpop .6s ease-out}'+
  '@keyframes haulpop{0%{transform:scale(1.5);filter:brightness(2.4);box-shadow:0 0 0 0 var(--hc)}45%{transform:scale(1.08);filter:brightness(1.4);box-shadow:0 0 26px 8px var(--hc)}100%{transform:scale(1);filter:none;box-shadow:0 0 0 0 rgba(0,0,0,0)}}'+
  '.haultot{font-family:var(--f-cond);font-weight:700;font-size:21px;letter-spacing:.14em;color:var(--acc);margin:4px 0 6px;text-transform:uppercase}');
function buildTags(){
'@

SubRx @'
if(_ocw&&_ocw.classList.contains('on')){ if(ev) ev.preventDefault(); document.getElementById('oc_btn').click(); return; }
'@ @'
if(_ocw&&_ocw.classList.contains('on')){ if(ev) ev.preventDefault(); if(haulRevealSkip()) return; document.getElementById('oc_btn').click(); return; }   // v26.xx (career7): the first press skips the haul reveal
'@

SubRx @'
if(tap(0)&&PAD.focus){ PAD.aSpent=1; if(!stashPadAct(PAD.focus)) PAD.focus.click(); }
'@ @'
if(tap(0)&&PAD.focus){ PAD.aSpent=1; if(md.id==='outcome'&&haulRevealSkip()){} else if(!stashPadAct(PAD.focus)) PAD.focus.click(); }   // v26.xx (career7): A on the card skips the haul reveal first
'@

SubRx @'
    if(back) back.click(); else md.classList.remove('on');
'@ @'
    if(md.id==='outcome'&&haulRevealSkip()){} else if(back) back.click(); else md.classList.remove('on');   // v26.xx (career7): B on the card skips the haul reveal first
'@

SubRx @'
var VER='27.07';
'@ @'
var VER='27.08';
'@

$pat = "(?m)^  now:'v27\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.08: Your haul reveals one item at a time with a rarity flash, and can be skipped. Check 27.08 fails on v27.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
