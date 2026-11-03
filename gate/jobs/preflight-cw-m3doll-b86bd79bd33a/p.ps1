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

# SEASON ZERO M3: THE STASH DOLL: NINE SLOTS, WEAR AND TAKE OFF, COMPARE TIPS, SAVED OUTFITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
'@ @'
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
// v37.xx (cw-m3doll), m3 shared helpers: the sale value of a piece at power 50 by rarity (tune here only, from real numbers), its price before CFG.lootMult as an
// ITEMS val is, and the compare tip against what is worn. A ring is compared in place of the weaker ring, or in an empty ring.
var WORN_VAL=[150,400,1000,2600];
function wornPrice(pc){ return Math.round(WORN_VAL[pc.r]*wornPwMul(pc.pw)*(1+(pc.pip|0)*0.1)); }
function wornTip(pc,p){
  var was=wornMods(p.worn), w={}, s, sl=WORN_KINDS[pc.k].slots, t=sl[0], m, sum=0, i;
  for(s in p.worn) if(Object.prototype.hasOwnProperty.call(p.worn,s)) w[s]=p.worn[s];
  if(pc.k==='ring'){ t=null; for(i=0;i<sl.length;i++) if(!w[sl[i]]){ t=sl[i]; break; }
    if(!t){ m=[0,0]; var w2; for(i=0;i<2;i++){ w2=w[sl[i]].tr; for(s=0;s<w2.length;s++) m[i]+=wornTraitV(w[sl[i]],w2[s])/(WORN_STATS[w2[s].s]?WORN_STATS[w2[s].s].base:1); } t=sl[m[1]<m[0]?1:0]; } }
  w[t]=pc; m=wornMods(w);
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) sum+=(m[s]-was[s])/WORN_STATS[s].base;
  return sum>0.01?'better':(sum<-0.01?'worse':'even');
}
'@

SubRx @'
mig0p:1,lifeEarn:0,mig1x:1,mig2n:1,mkt:{s:{}},
'@ @'
mig0p:1,lifeEarn:0,mig1x:1,mig2n:1,mkt:{s:{}},outfits:[],
'@

SubRx @'
  try{ wornClean(P); }catch(_wc){}
'@ @'
  try{ wornOutfitClean(P); }catch(_wo){}   // v37.xx (cw-m3doll): the saved outfits, checked; an old save gets none
  try{ wornClean(P); }catch(_wc){}
'@

SubRx @'
// THE ONE SUM OF EVERYTHING WORN: stat to fraction.
'@ @'
// v37.xx (cw-m3doll), HIS ANSWER 70 OF 11-01: saved outfits, one tap to dress. A row is a name and the piece ids per slot, about 5 rows, checked as the pieces are: a row with nothing to read is dropped.
var WORN_OUTFITS_MAX=5;
function wornOutfitClean(p){
  var out=[], L, i, j, o, s;
  if(!p||typeof p!=='object') return false;
  L=Array.isArray(p.outfits)?p.outfits:[];
  for(i=0;i<L.length&&out.length<WORN_OUTFITS_MAX;i++){ o=L[i]; if(!o||typeof o!=='object'||typeof o.n!=='string') continue; s={};
    if(o.s&&typeof o.s==='object'&&!Array.isArray(o.s)) for(j=0;j<WORN_SLOTS.length;j++) if(typeof o.s[WORN_SLOTS[j]]==='string'&&o.s[WORN_SLOTS[j]]) s[WORN_SLOTS[j]]=o.s[WORN_SLOTS[j]];
    out.push({n:o.n.toLowerCase().trim().slice(0,16)||'outfit',s:s}); }
  p.outfits=out;
  return true;
}
function wornOwned(p,id){ var i, s; for(i=0;i<p.gear.length;i++) if(p.gear[i].id===id) return true; for(s in p.worn) if(p.worn[s]&&p.worn[s].id===id) return true; return false; }
function wornOutfitMissing(p,o){ var n=0, s; for(s in o.s) if(!wornOwned(p,o.s[s])) n++; return n; }
// One tap dresses through the one door (wornOff and wornWear): every piece still owned goes on, a slot the outfit left bare comes off, and a slot whose piece is gone stays as it is
// (unless what stands there belongs in another slot of this outfit).
function wornOutfitDress(p,o){
  var i, s, id, on;
  if(!p||!o||!wornClean(p)) return false;
  for(i=0;i<WORN_SLOTS.length;i++){ s=WORN_SLOTS[i]; id=o.s[s]; on=p.worn[s];
    if(!on||on.id===id) continue;
    if(!id||wornOwned(p,id)) wornOff(p,s);
  }
  for(s in p.worn) for(i=0;i<WORN_SLOTS.length;i++) if(p.worn[s]&&WORN_SLOTS[i]!==s&&o.s[WORN_SLOTS[i]]===p.worn[s].id) wornOff(p,s);
  for(i=0;i<WORN_SLOTS.length;i++){ s=WORN_SLOTS[i]; id=o.s[s]; if(id&&!(p.worn[s]&&p.worn[s].id===id)&&wornOwned(p,id)) wornWear(p,id,s); }
  return true;
}
// THE ONE SUM OF EVERYTHING WORN: stat to fraction.
'@

SubRx @'
<div class="modal" id="welcomemodal">
'@ @'
<!-- v37.xx (cw-m3doll): the stash doll, picture a of tools/handoff/console/notes/progression/doll-pick-1101.html -->
<div class="modal" id="gearmodal">
  <h3><span>gear</span><span id="gearwn"></span></h3>
  <div id="gearwrap">
    <div id="geardoll" class="gpan">
      <div id="gearslots">
        <div class="gcol" id="gearcl"></div>
        <div id="gearmid"><canvas id="gearcv" width="176" height="304"></canvas><div id="gearpk"></div></div>
        <div class="gcol" id="gearcr"></div>
      </div>
      <div class="glab">you wear</div>
      <div id="gearsum"></div>
    </div>
    <div id="gearbox" class="gpan">
      <div id="gearhd"></div>
      <div id="gearlist"></div>
    </div>
    <div id="gearside">
      <div id="geartip" class="gpan"></div>
      <div id="gearout" class="gpan">
        <div class="glab" id="gearoutn"></div>
        <div id="gearsave"><input id="gearname" maxlength="16" autocomplete="off" spellcheck="false" placeholder="outfit name" aria-label="outfit name"><button id="gearsavebtn">save outfit</button></div>
        <div id="gearofs"></div>
      </div>
    </div>
  </div>
  <div style="display:flex;gap:8px;margin-top:10px">
    <div id="gearhints"></div>
    <button id="closegear" data-esc="1" style="padding:8px 22px;margin-left:auto">close</button>
  </div>
</div>
<div class="modal" id="welcomemodal">
'@

SubRx @'
trophymodal:'closetrophy',birthmodal:'closebirth'};
'@ @'
trophymodal:'closetrophy',birthmodal:'closebirth',gearmodal:'closegear'};
'@

SubRx @'
      r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
'@ @'
      r3.appendChild(sq); r3.appendChild(sb);
      if(pilHome()){ var gb=document.createElement('div'); gb.className='invtab'; gb.id='gearbtn'; gb.style.fontSize='13px';   // v37.xx (cw-m3doll): THE DOLL
        gb.textContent='GEAR  '+gearWornN()+'/'+WORN_SLOTS.length; gb.onclick=function(){ gearOpen('stash'); }; r3.appendChild(gb); }
      r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
'@

SubRx @'
        <div class="srcap">KIT</div>
'@ @'
        <div class="srcap">KIT<button type="button" id="srworn" data-pan="k" style="display:none"></button></div>
'@

SubRx @'
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
'@ @'
  try{ gearSrLine(); }catch(_gsl){}   // v37.xx (cw-m3doll)
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
'@

SubRx @'
  try{ stashCardAt(el); }catch(_sc){}   // v28.xx (cw-stashtabs): the details card follows the pad highlight
'@ @'
  try{ stashCardAt(el); }catch(_sc){}   // v28.xx (cw-stashtabs): the details card follows the pad highlight
  try{ if(el.closest&&el.closest('#gearmodal')) gearTipFrom(el); }catch(_gt){}   // v37.xx (cw-m3doll): the tip follows the highlight
'@

SubRx @'
    if(md.id==='birthmodal'){ birthFinish(false); padSetFocus(null); PAD.focus=null; return true; }
'@ @'
    if(md.id==='gearmodal'){ gearClose(); padSetFocus(null); PAD.focus=null; return true; }   // v37.xx (cw-m3doll): "sound backpack" holds the word back, so B must not go looking for a way out by its words
    if(md.id==='birthmodal'){ birthFinish(false); padSetFocus(null); PAD.focus=null; return true; }
'@

SubRx @'
  if(PADNAME||!input||(input.id!=='pnamein'&&input.id!=='birthname'&&input.id!=='hallname'))return false;
'@ @'
  if(PADNAME||!input||(input.id!=='pnamein'&&input.id!=='birthname'&&input.id!=='hallname'&&input.id!=='gearname'))return false;
'@

SubRx @'
(el.tagName==='INPUT'&&el.id!=='pnamein'&&el.id!=='birthname'&&el.id!=='hallname'&&!/^(button
'@ @'
(el.tagName==='INPUT'&&el.id!=='pnamein'&&el.id!=='birthname'&&el.id!=='hallname'&&el.id!=='gearname'&&!/^(button
'@

SubRx @'
&&!(n.input.id==='hallname'&&document.getElementById('opmodal').classList.contains('on'))){padNameClose(false);return false;}
'@ @'
&&!(n.input.id==='hallname'&&document.getElementById('opmodal').classList.contains('on'))&&!(n.input.id==='gearname'&&gearOn())){padNameClose(false);return false;}
'@

SubRx @'
PAD.focus.id==='birthname'||PAD.focus.id==='hallname') padNameStart(PAD.focus);
'@ @'
PAD.focus.id==='birthname'||PAD.focus.id==='hallname'||PAD.focus.id==='gearname') padNameStart(PAD.focus);
'@

SubRx @'
// v37.xx (cw-m2birth), HIS RULINGS OF 11-01, plan m2: THE BIRTH MOMENT.
'@ @'
// v37.xx (cw-m3doll), HIS RULINGS OF 11-01, plan "worn gear": "headgear, amulet, armor, pants, 2 rings, boots, gloves, backpack -- no cloak" (answer 54); any pillager can wear any piece (63); a compare tip better
// or worse (71); no limit on room for gear (69); saved outfits, one tap to dress (70). THE DOLL reads and writes P.gear and P.worn through wornWear, wornOff and wornClean only. Its doors are GEAR on the stash row and
// the worn line on the pre-raid page; neither is there in a raid, the demo or the player 2 window (pilHome), and every action asks pilHome again. A click, A or enter on a piece wears it: a ring takes the empty ring,
// else the weaker ring, the one wornTip compared it with, so the tip never promises one swap and does another. A click on a filled slot takes it off and lights it; a click on an empty slot lights it, and a lit
// slot filters the list. Picture a of his pick page; his pick later swaps it (rule 53).
careerStyle('gearcss',
  'body:has(#gearmodal.on) #topright{display:none !important}'+
  '#root #gearmodal{align-items:stretch}'+
  '#root #gearmodal h3{display:flex;align-items:baseline;gap:16px}'+
  '#root #gearmodal #gearwn{font:600 var(--fs-body)/1 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal #gearwrap{flex:1;min-height:0;display:grid;grid-template-columns:minmax(0,3fr) minmax(0,3fr) minmax(0,2fr);gap:16px;width:100%}'+
  '#root #gearmodal .gpan{display:flex;flex-direction:column;gap:8px;min-width:0;min-height:0;padding:16px;box-sizing:border-box;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad)}'+
  '#root #gearmodal .glab{font:600 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal #gearslots{display:grid;grid-template-columns:minmax(0,1fr) 176px minmax(0,1fr);gap:8px}'+
  '#root #gearmodal .gcol{display:grid;grid-auto-rows:96px;gap:8px;min-width:0}'+
  '#root #gearmodal #gearmid{display:flex;flex-direction:column;align-items:center;justify-content:space-between;gap:8px;min-width:0}'+
  '#root #gearmodal #gearpk{width:100%}'+
  '#root #gearmodal #gearcv{width:176px;height:304px;flex:none}'+
  '#root #gearmodal .gslot{display:flex;align-items:center;justify-content:flex-start;gap:8px;box-sizing:border-box;width:100%;height:96px;min-width:0;min-height:0;margin:0;padding:8px 12px;background:var(--ui-bg);border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-2);text-align:left;text-transform:none;letter-spacing:0;font:600 var(--fs-body)/1.15 var(--f-cond)}'+
  '#root #gearmodal .gslot.full{box-shadow:inset 4px 0 0 var(--gc);background:var(--ui-raised)}'+
  '#root #gearmodal .gslot.lit{border:2px solid var(--acc)}'+
  '#root #gearmodal .gslot svg,#root #gearmodal #geartip svg{width:32px;height:32px;flex:none;fill:none;stroke:var(--gc);stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}'+
  '#root #gearmodal .gslot span{display:flex;flex-direction:column;gap:2px;min-width:0}'+
  '#root #gearmodal .gslot b{font:700 22px/1.1 var(--f-cond);color:var(--gc)}'+
  '#root #gearmodal .gslot em{font:500 18px/1.1 var(--f-cond);font-style:normal;color:var(--tx-2);white-space:nowrap}'+
  '#root #gearmodal .gpip{font-style:normal;color:var(--tx-1);letter-spacing:.08em}'+
  '#root #gearmodal #gearsum{display:flex;flex-wrap:wrap;gap:4px 24px;min-height:0;overflow:hidden;font:600 var(--fs-body)/1.25 var(--f-cond);color:var(--tx-1)}'+
  '#root #gearmodal #gearsum em{margin-left:6px;font:600 var(--fs-label)/1 var(--f-cond);font-style:normal;color:var(--warn)}'+
  '#root #gearmodal #gearhd{display:flex;align-items:center;gap:16px;min-height:40px;font:600 var(--fs-body)/1 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal #gearhd b{font:700 28px/1 var(--f-cond);color:var(--tx-1)}'+
  '#root #gearmodal #gearhd button{margin-left:auto;min-height:40px;min-width:80px;padding:0 16px;font:600 var(--fs-body)/1 var(--f-cond);text-transform:none}'+
  '#root #gearmodal #gearlist{flex:1;min-height:0;display:flex;flex-direction:column;gap:8px;overflow-y:auto;overflow-x:hidden;padding:2px}'+
  '#root #gearmodal .gnone{padding:16px;font:600 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal .grow{display:flex;flex-direction:column;align-items:stretch;justify-content:center;gap:2px;flex:none;box-sizing:border-box;width:100%;min-width:0;min-height:72px;margin:0;padding:8px 16px;background:var(--ui-bg);border:1px solid var(--ui-line);border-radius:var(--rad);color:var(--tx-2);text-align:left;text-transform:none;letter-spacing:0}'+
  '#root #gearmodal .grow:hover,#root #gearmodal .grow.padfocus{background:var(--ui-raised);box-shadow:inset 4px 0 0 var(--acc);border-color:var(--ui-line-hi)}'+
  '#root #gearmodal .grow.padfocus{outline-offset:-3px}'+
  '#root #gearmodal .grow > span{display:flex;align-items:baseline;justify-content:space-between;gap:16px;min-width:0}'+
  '#root #gearmodal .grow b{font:700 24px/1.15 var(--f-cond);color:var(--gc);white-space:nowrap}'+
  '#root #gearmodal .grow .gpw{font:500 var(--fs-body)/1.15 var(--f-cond);color:var(--tx-2);white-space:nowrap}'+
  '#root #gearmodal .grow .gtr{flex:1;min-width:0;font:500 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-1);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
  '#root #gearmodal .grow em{flex:none;font:600 var(--fs-body)/1.2 var(--f-cond);font-style:normal}'+
  '#root #gearmodal .g-better{color:var(--ok)}#root #gearmodal .g-worse{color:var(--danger)}#root #gearmodal .g-even{color:var(--tx-2)}'+
  '#root #gearmodal #gearside{display:flex;flex-direction:column;gap:16px;min-width:0;min-height:0}'+
  '#root #gearmodal #geartip{flex:none;height:248px;overflow:hidden;background:var(--ui-raised)}'+
  '#root #gearmodal #geartip .gth{display:flex;align-items:center;gap:8px}'+
  '#root #gearmodal #geartip b{font:700 28px/1.1 var(--f-cond);color:var(--gc)}'+
  '#root #gearmodal #geartip span{font:500 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-1)}'+
  '#root #gearmodal #geartip .gag{color:var(--tx-2)}'+
  '#root #gearmodal #geartip .gv{margin-top:auto;font:700 var(--fs-title)/1 var(--f-cond)}'+
  '#root #gearmodal #gearout{flex:1}'+
  '#root #gearmodal #gearsave{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:8px}'+
  '#root #gearmodal #gearname{box-sizing:border-box;width:100%;height:48px;padding:0 12px;background:var(--ui-bg);border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);font:600 var(--fs-body)/1 var(--f-cond);text-transform:none}'+
  '#root #gearmodal #gearsavebtn{min-height:48px;min-width:0;padding:0 12px;font:600 var(--fs-body)/1 var(--f-cond);white-space:nowrap;text-transform:none}'+
  '#root #gearmodal #gearofs{flex:1;min-height:0;display:flex;flex-direction:column;gap:8px;overflow-y:auto;padding:2px}'+
  '#root #gearmodal .gof{display:grid;grid-template-columns:minmax(0,1fr) 48px;gap:8px;flex:none}'+
  '#root #gearmodal .gofb{display:flex;align-items:center;justify-content:space-between;gap:8px;min-height:48px;min-width:0;margin:0;padding:0 12px;background:var(--ui-bg);border:1px solid var(--ui-line);border-radius:var(--rad);color:var(--tx-1);text-align:left;text-transform:none;letter-spacing:0}'+
  '#root #gearmodal .gofb.on{box-shadow:inset 4px 0 0 var(--acc);background:var(--ui-raised)}'+
  '#root #gearmodal .gofb b{font:700 var(--fs-body)/1 var(--f-cond);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
  '#root #gearmodal .gofb span{flex:none;font:500 var(--fs-label)/1 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal .gofb i{flex:none;font:600 var(--fs-label)/1 var(--f-cond);font-style:normal;color:var(--danger)}'+
  '#root #gearmodal .gofx{min-height:48px;min-width:48px;margin:0;padding:0;font:600 var(--fs-body)/1 var(--f-cond);text-transform:none}'+
  '#root #gearmodal #gearhints{display:flex;align-items:center;gap:24px;font:500 var(--fs-body)/1 var(--f-cond);color:var(--tx-2)}'+
  '#root #gearmodal #gearhints span{display:inline-flex;align-items:center;gap:8px;white-space:nowrap}'+
  '#root #gearmodal #gearhints i{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:30px;padding:0 10px;border:1px solid var(--ui-line-hi);border-radius:4px;font:600 16px var(--f-cond);font-style:normal;color:var(--tx-1)}'+
  'body:not(.padon) #gearmodal #gearhints .bp,body.padon #gearmodal #gearhints .bk{display:none!important}'+
  '#root #sectormodal #srworn{height:28px;min-height:0;min-width:0;margin:-6px 0 0;padding:0 8px;background:none;border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);font:600 16px/1 var(--f-cond);letter-spacing:.02em;text-transform:lowercase}');
var GEAR={lit:'',back:'',tip:''};
var WORN_ICON={head:'M4 16a8 8 0 0 1 16 0v3H4zM9 8.5V4h6v4.5',amulet:'M6 3l6 9 6-9M12 12a4.5 4.5 0 1 0 .01 0z',armor:'M8 3l4 2 4-2 4 3-2 5v10H6V11L4 6z',pants:'M6 3h12l2 18h-5l-3-11-3 11H4z',
  ring:'M12 9a6 6 0 1 0 .01 0zM9 6l3-3 3 3-3 3z',boots:'M8 3h6v10l6 4v4H8zM8 17h12',gloves:'M8 21v-6l-4-5 1.5-1.5L8 11V4h1.8v6h.7V3h1.8v7h.7V4H15v6h.7V6h1.8v9l-2 2v4z',pack:'M8 8a4 4 0 0 1 8 0M5 8h14v13H5zM9 13h6v4H9z'};
function gearOn(){ var m=document.getElementById('gearmodal'); return !!(m&&m.classList.contains('on')); }
function gearWornN(){ return (P&&P.worn&&typeof P.worn==='object')?Object.keys(P.worn).length:0; }
function gearKindOf(slot){ var k; for(k in WORN_KINDS) if(WORN_KINDS[k].slots.indexOf(slot)>=0) return k; return null; }
function gearSlotN(slot){ return WORN_KINDS[gearKindOf(slot)].n; }
function gearIcon(k){ return '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="'+WORN_ICON[k]+'"/></svg>'; }
function gearPct(v){ return (v<0?'-':'+')+Math.round(Math.abs(v)*100)+'%'; }
function gearTrait(pc,t){ return WORN_STATS[t.s].n+' '+gearPct(wornTraitV(pc,t)); }
function gearPower(pc){ var n=pc.pip|0, d='', i; for(i=0;i<n;i++) d+='\u2022'; return 'power '+pc.pw+(d?' <i class="gpip">'+d+'</i>':''); }
// The ring a new ring replaces with both full: the weaker, on the same measure wornTip compares with; even, the first.
function gearRingOut(p){
  var sl=WORN_KINDS.ring.slots, m=[0,0], i, j, tr;
  for(i=0;i<2;i++){ tr=p.worn[sl[i]].tr; for(j=0;j<tr.length;j++) m[i]+=wornTraitV(p.worn[sl[i]],tr[j])/WORN_STATS[tr[j].s].base; }
  return sl[m[1]<m[0]?1:0];
}
function gearTarget(p,pc){ var sl=WORN_KINDS[pc.k].slots, i; if(pc.k!=='ring') return sl[0]; for(i=0;i<sl.length;i++) if(!p.worn[sl[i]]) return sl[i]; return gearRingOut(p); }
function gearFind(id){ var i, s; for(i=0;i<P.gear.length;i++) if(P.gear[i].id===id) return {pc:P.gear[i],slot:''}; for(s in P.worn) if(P.worn[s].id===id) return {pc:P.worn[s],slot:s}; return null; }
// THE ONE DOOR OF THE WINDOW'S WEARING. Null when it is not his own floor.
function gearWear(id){
  var f, s;
  if(!pilHome()||!wornClean(P)) return false;
  f=gearFind(id); if(!f||f.slot) return false;
  s=gearTarget(P,f.pc);
  if(!wornWear(P,id,s)) return false;
  try{ sndUi('ok'); }catch(_gw){}
  try{ saveProfile(); }catch(_gs){}
  if(gearOn()) gearDraw();
  return s;
}
function gearOff(slot){
  if(!pilHome()||!wornOff(P,slot)) return false;
  GEAR.lit=slot;
  try{ sndUi('back'); }catch(_go){}
  try{ saveProfile(); }catch(_gs){}
  if(gearOn()) gearDraw();
  return true;
}
function gearDress(i){
  var o;
  if(!pilHome()||!wornClean(P)||!wornOutfitClean(P)) return false;
  o=P.outfits[i|0]; if(!o) return false;
  if(!wornOutfitDress(P,o)) return false;
  try{ sndUi('ok'); }catch(_gw){}
  try{ saveProfile(); }catch(_gs){}
  if(gearOn()) gearDraw();
  return true;
}
// A name already there is saved over. A new row needs room, and an outfit of nothing is not a row.
function gearOutfitCan(name){
  var i, n=String(name||'').toLowerCase().trim().slice(0,16);
  if(!gearWornN()) return false;
  if(n) for(i=0;i<P.outfits.length;i++) if(P.outfits[i].n===n) return true;
  return P.outfits.length<WORN_OUTFITS_MAX;
}
function gearOutfitSave(name){
  var n=String(name||'').toLowerCase().trim().slice(0,16), s={}, i, u, o=null;
  if(!pilHome()||!wornClean(P)||!wornOutfitClean(P)||!gearOutfitCan(n)) return null;
  for(u in P.worn) s[u]=P.worn[u].id;
  u=1; while(!n){ n='outfit '+u; for(i=0;i<P.outfits.length;i++) if(P.outfits[i].n===n) n=''; u++; }
  for(i=0;i<P.outfits.length;i++) if(P.outfits[i].n===n) o=P.outfits[i];
  if(o) o.s=s; else { o={n:n,s:s}; P.outfits.push(o); }
  try{ sndUi('ok'); }catch(_gw){}
  try{ saveProfile(); }catch(_gs){}
  if(gearOn()) gearDraw();
  return o;
}
function gearOutfitDel(i){
  if(!pilHome()||!P.outfits[i|0]) return false;
  P.outfits.splice(i|0,1);
  try{ sndUi('back'); }catch(_gw){}
  try{ saveProfile(); }catch(_gs){}
  if(gearOn()) gearDraw();
  return true;
}
function gearSlotHtml(s){
  var pc=P.worn[s], c=pc?WORN_RARS[pc.r].c:'var(--tx-2)';
  return '<button type="button" class="gslot'+(pc?' full':'')+(GEAR.lit===s?' lit':'')+'" data-gs="'+s+'" data-gk="s:'+s+'" style="--gc:'+c+'">'+
    (pc?gearIcon(pc.k)+'<span><b>'+wornName(pc)+'</b><em>'+gearPower(pc)+'</em></span>':gearSlotN(s))+'</button>';
}
function gearRowHtml(pc){
  var t=wornTip(pc,P), i, tr=[];
  for(i=0;i<pc.tr.length;i++) tr.push(gearTrait(pc,pc.tr[i]));
  return '<button type="button" class="grow" data-gp="'+pc.id+'" data-gk="p:'+pc.id+'" style="--gc:'+WORN_RARS[pc.r].c+'"><span><b>'+wornName(pc)+'</b><span class="gpw">'+gearPower(pc)+'</span></span>'+
    '<span><span class="gtr">'+tr.join('   ')+'</span><em class="g-'+t+'">'+t+'</em></span></button>';
}
function gearSumHtml(){
  var m=wornMods(P.worn), h='', s;
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)&&m[s]) h+='<span data-st="'+s+'">'+WORN_STATS[s].n+' '+gearPct(m[s])+(m[s]>=WORN_STATS[s].cap?'<em>cap</em>':'')+'</span>';
  return h||'<span class="gnil">nothing</span>';
}
function gearTipFrom(el){ var k=el&&el.getAttribute&&el.getAttribute('data-gk'); if(k&&(k.charAt(0)==='p'||k.charAt(0)==='s')){ GEAR.tip=k; gearTipDraw(); } }
function gearTipDraw(){
  var el=document.getElementById('geartip'), k=GEAR.tip, f=null, h='', i, s, t, pc;
  if(!el) return;
  if(k.charAt(0)==='s'){ s=k.slice(2); pc=P.worn[s]; if(pc) f={pc:pc,slot:s}; else if(gearKindOf(s)){ el.style.setProperty('--gc','var(--tx-2)'); el.innerHTML='<b>'+gearSlotN(s)+'</b><span class="gag">empty</span>'; return; } }
  else if(k.charAt(0)==='p') f=gearFind(k.slice(2));
  if(!f){ el.innerHTML=''; return; }
  pc=f.pc; el.style.setProperty('--gc',WORN_RARS[pc.r].c);
  h='<div class="gth">'+gearIcon(pc.k)+'<b>'+wornName(pc)+'</b></div><span class="gag">'+gearPower(pc)+'</span>';
  for(i=0;i<pc.tr.length;i++) h+='<span>'+gearTrait(pc,pc.tr[i])+'</span>';
  if(f.slot) h+='<div class="gv g-even">worn</div>';
  else { t=wornTip(pc,P); s=gearTarget(P,pc); h+='<div class="gv g-'+t+'">'+t+'</div><span class="gag">against '+(P.worn[s]?wornName(P.worn[s]):'empty '+gearSlotN(s))+'</span>'; }
  el.innerHTML=h;
}
function gearSrLine(){
  var b=document.getElementById('srworn'); if(!b) return;
  if(!pilHome()){ b.style.display='none'; return; }
  b.style.display=''; b.textContent='worn '+gearWornN()+' of '+WORN_SLOTS.length;
  b.onclick=function(){ gearOpen('sector'); };
}
function gearDraw(){
  var m=document.getElementById('gearmodal'), f=(PAD.focus&&m.contains(PAD.focus))?PAD.focus:null, fk=f?f.getAttribute('data-gk'):null, lst=document.getElementById('gearlist'), fix=-1, nf, L, k, h='', i, nm, o, n;
  wornClean(P); wornOutfitClean(P);
  if(f&&lst.contains(f)) fix=[].indexOf.call(lst.children,f);
  document.getElementById('gearwn').textContent='worn '+gearWornN()+' of '+WORN_SLOTS.length;
  document.getElementById('gearcl').innerHTML=['head','armor','pants','boots'].map(gearSlotHtml).join('');
  document.getElementById('gearcr').innerHTML=['amulet','ring1','ring2','gloves'].map(gearSlotHtml).join('');
  document.getElementById('gearpk').innerHTML=gearSlotHtml('pack');
  document.getElementById('gearsum').innerHTML=gearSumHtml();
  k=GEAR.lit?gearKindOf(GEAR.lit):null;
  L=P.gear.filter(function(pc){ return !k||pc.k===k; });
  L.sort(function(a,b){ return (b.r-a.r)||(b.pw-a.pw)||(a.id<b.id?-1:1); });
  document.getElementById('gearhd').innerHTML='<b>gear '+P.gear.length+'</b>'+(k?'<span>'+WORN_KINDS[k].n+' '+L.length+'</span><button type="button" id="gearall" data-gk="all">all</button>':'');
  for(i=0;i<L.length;i++) h+=gearRowHtml(L[i]);
  lst.innerHTML=h||'<div class="gnone">'+(k?'no '+WORN_KINDS[k].n:'no gear')+'</div>';
  document.getElementById('gearoutn').textContent='outfits '+P.outfits.length+' of '+WORN_OUTFITS_MAX;
  h='';
  for(i=0;i<P.outfits.length;i++){ o=P.outfits[i]; n=wornOutfitMissing(P,o); nm=Object.keys(o.s).length;
    h+='<div class="gof"><button type="button" class="gofb'+(gearOutfitOn(o)?' on':'')+'" data-gof="'+i+'" data-gk="o:'+i+'"><b>'+escHtml(o.n)+'</b>'+(n?'<i>'+n+' missing</i>':'<span>'+nm+' piece'+(nm===1?'':'s')+'</span>')+'</button><button type="button" class="gofx" data-gofx="'+i+'" data-gk="x:'+i+'" aria-label="delete">x</button></div>'; }
  document.getElementById('gearofs').innerHTML=h;
  gearSaveSync();
  document.getElementById('gearhints').innerHTML='<span class="bk"><i>arrows</i>pick</span><span class="bk"><i>enter</i>wear</span><span class="bk"><i>esc</i>close</span>'+
    '<span class="bp"><i>'+escHtml(padB('A'))+'</i>wear</span><span class="bp"><i>'+escHtml(padB('B'))+'</i>close</span>';
  gearTipDraw();
  try{ drawAvatarCanvas(document.getElementById('gearcv')); }catch(_gd){}
  if(f&&!m.contains(f)){ nf=fk?m.querySelector('[data-gk="'+fk+'"]'):null; if(!nf&&fix>=0){ L=lst.querySelectorAll('.grow'); nf=L[Math.min(fix,L.length-1)]; } if(!nf) nf=m.querySelector('[data-gs]'); padSetFocus(nf); }
}
function gearOutfitOn(o){ var i, s, w; for(i=0;i<WORN_SLOTS.length;i++){ s=WORN_SLOTS[i]; w=P.worn[s]; if((w?w.id:'')!==(o.s[s]||'')) return false; } return true; }
function gearSaveSync(){ var b=document.getElementById('gearsavebtn'), n=document.getElementById('gearname'); if(b&&n) b.disabled=!gearOutfitCan(n.value); }
function gearOpen(back){
  if(!pilHome()) return false;
  GEAR.back=back||''; GEAR.lit=''; GEAR.tip='';
  gearDraw(); openModal('gearmodal');
  try{ drawAvatarCanvas(document.getElementById('gearcv')); }catch(_gd){}
  try{ if(padOn()) padSetFocus(document.querySelector('#gearslots [data-gs="head"]')); }catch(_gp){}
  return true;
}
function gearClose(){
  document.getElementById('gearmodal').classList.remove('on');
  try{ if(PAD.focus&&document.getElementById('gearmodal').contains(PAD.focus)){ padSetFocus(null); PAD.focus=null; } }catch(_gp){}
  if(GEAR.back==='sector'){ renderSector(); openModal('sectormodal'); }
  else { try{ renderHub(); }catch(_rh){} }
}
document.getElementById('closegear').onclick=gearClose;
document.getElementById('gearslots').onclick=function(ev){
  var b=ev.target.closest('[data-gs]'), s; if(!b||!pilHome()) return;
  s=b.getAttribute('data-gs');
  if(P.worn[s]){ gearOff(s); return; }
  GEAR.lit=(GEAR.lit===s)?'':s;
  try{ sndUi('click'); }catch(_gu){}
  gearDraw();
};
document.getElementById('gearlist').onclick=function(ev){ var b=ev.target.closest('[data-gp]'); if(b) gearWear(b.getAttribute('data-gp')); };
document.getElementById('gearhd').onclick=function(ev){ if(!ev.target.closest('#gearall')) return; GEAR.lit=''; try{ sndUi('click'); }catch(_gu){} gearDraw(); };
document.getElementById('gearofs').onclick=function(ev){
  var b=ev.target.closest('[data-gof]'), x=ev.target.closest('[data-gofx]');
  if(b) gearDress(+b.getAttribute('data-gof')); else if(x) gearOutfitDel(+x.getAttribute('data-gofx'));
};
document.getElementById('gearsavebtn').onclick=function(){
  var n=document.getElementById('gearname');
  if(gearOutfitSave(n.value)){ n.value=''; gearSaveSync(); }
};
document.getElementById('gearname').oninput=function(){ var v=String(this.value||'').toLowerCase().slice(0,16); if(this.value!==v) this.value=v; gearSaveSync(); };
document.getElementById('gearname').onkeydown=function(e){ if(e.code==='Escape') return; e.stopPropagation(); if(e.code==='Enter'||e.code==='NumpadEnter'){ e.preventDefault(); this.blur(); } };
document.getElementById('gearmodal').addEventListener('mouseover',function(ev){ var b=ev.target&&ev.target.closest?ev.target.closest('[data-gk]'):null; if(b) gearTipFrom(b); });
// The keyboard walks every slot, piece and button with the highlight the pad uses (padStep), and enter is the press. ESC is the window's own close.
window.addEventListener('keydown',function(e){
  var c=e.code, ae, mv=null, m, nx;
  if(!gearOn()) return;
  ae=document.activeElement; if(ae&&ae.id==='gearname') return;
  m=document.getElementById('gearmodal');
  if(c==='Enter'||c==='NumpadEnter'){
    if(e.repeat||!PAD.focus||!m.contains(PAD.focus)) return;
    e.preventDefault(); e.stopPropagation();
    if(PAD.focus.id==='gearname') PAD.focus.focus(); else PAD.focus.click();
    return;
  }
  if(c==='ArrowUp'||c==='KeyW') mv=[0,-1]; else if(c==='ArrowDown'||c==='KeyS') mv=[0,1]; else if(c==='ArrowLeft'||c==='KeyA') mv=[-1,0]; else if(c==='ArrowRight'||c==='KeyD') mv=[1,0];
  if(!mv) return;
  e.preventDefault(); e.stopPropagation();
  nx=padStep(padFocusables(m),(PAD.focus&&m.contains(PAD.focus))?PAD.focus:null,mv[0],mv[1]);
  if(nx) padSetFocus(nx);
});
// v37.xx (cw-m2birth), HIS RULINGS OF 11-01, plan m2: THE BIRTH MOMENT.
'@

SubRx @'
var VER='37.41';
'@ @'
var VER='37.42';
'@

$pat = "(?m)^  now:'v37\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.42: a gear button on the stash row and a worn line on the pre-raid page open a full window: nine slots around the figure with the sum of what you wear, every piece in a scrolling list, click A or enter wears and a click on a filled slot takes off, a tip says better worse or even against what you wear, and up to five named outfits dress in one tap and show how many pieces are missing. A new ring with both full replaces the weaker ring, the one the tip compared it with. Never in a raid or the demo Check 37.42 fails on v37.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
