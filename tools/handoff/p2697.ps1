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

# THE ARMORY CODEX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="modal" id="termsmodal">
'@ @'
<!-- v26.xx (career2), HIS YES (2026-10-14) to suggestion 30, THE ARMORY CODEX: a stash page that lists every gun and its rarity, found or not found. -->
<div class="modal" id="codexmodal">
  <h3 id="codex_h">ARMORY CODEX</h3>
  <div class="cxgrid" id="codexgrid"></div>
  <div style="display:flex;gap:8px;margin-top:10px">
    <button id="closecodex" style="padding:8px 22px">CLOSE</button>
  </div>
</div>

<div class="modal" id="termsmodal">
'@

SubRx @'
partymodal:'closeparty',opmodal:'closeop',sectormodal:'closesector',settingsmodal:'closesettings',welcomemodal:'welcomeno'};
'@ @'
partymodal:'closeparty',opmodal:'closeop',sectormodal:'closesector',settingsmodal:'closesettings',welcomemodal:'welcomeno',codexmodal:'closecodex'};
'@

SubRx @'
r3.appendChild(sq); r3.appendChild(sb); tb.appendChild(r3);
'@ @'
var cxb=document.createElement('div'); cxb.className='invtab'; cxb.id='codexbtn'; cxb.style.fontSize='13px';   // v26.xx (career2): THE ARMORY CODEX
      cxb.textContent='ARMORY  '+codexFound()+'/'+codexGuns().length; cxb.onclick=function(){ codexOpen(); };
      r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); tb.appendChild(r3);
'@

SubRx @'
function renderHub(){
'@ @'
function renderHub(){
  try{ codexScan(); }catch(_cxs){}   // v26.xx (career2): every gun in the armoury, stash or backpack is in the codex
'@

SubRx @'
if((G.arcade||G.career)&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}
'@ @'
if((G.arcade||G.career)&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}
      if(!G.arcade&&!G.over) try{ careerTick(dt); }catch(_ctk){}   // v26.xx (career2): the CAREER ticks (the codex scan)
'@

SubRx @'
function gunKillsOf(gk){
'@ @'
// v26.xx (career2), HIS YES (2026-10-14) to suggestion 30, THE ARMORY CODEX: "a stash page listing every gun, rarity found or not found". The page lists every gun
// id the game has (the eleven models and the eight rarity twins, in rarity order, each wearing the rarity the game shows for it) with a silhouette and NOT FOUND for
// the ones you have never held, and the name, the rarity, the class and the kill tally (career1) for the ones you have. A gun is FOUND once it has been in your
// armoury, stash or backpack, or in your hands or backpack in a raid (a once-a-second scan while you are up there, careerTick), and stays found for good; the
// profile keeps it as P.codex, gun id to the time it was first found (an old save has none, and the first stash draw files what it already owns). NEW marks an entry
// found since you last closed the page. Opening it is a button beside SORT on the stash (ARMORY n/N); CLOSE and ESC shut it. Display only: no gun changes.
function careerStyle(id,css){ var s=document.getElementById(id); if(s) return s; s=document.createElement('style'); s.id=id; s.textContent=css; document.head.appendChild(s); return s; }
function codexGuns(){
  var out=[], k;
  for(k in WEAPONS) if(Object.prototype.hasOwnProperty.call(WEAPONS,k)&&k!=='fists'&&WEAPONS[k]&&ITEMS['gun_'+k]) out.push(k);
  out.sort(function(a,b){ return ((_RRANK[gunRarity(a)]||0)-(_RRANK[gunRarity(b)]||0))||(ival('gun_'+a)-ival('gun_'+b))||(a<b?-1:1); });
  return out;
}
function codexHas(gk){ return !!(P&&P.codex&&typeof P.codex==='object'&&P.codex[gk]); }
function codexFound(){ var L=codexGuns(), n=0, i; for(i=0;i<L.length;i++) if(codexHas(L[i])) n++; return n; }
function codexNote(gk){
  if(!P||!gk||gk==='fists'||!WEAPONS[gk]||!ITEMS['gun_'+gk]) return false;
  if(!P.codex||typeof P.codex!=='object'||Array.isArray(P.codex)) P.codex={};
  if(P.codex[gk]) return false;
  P.codex[gk]=Date.now();
  return true;
}
function codexScan(){
  var n=0, i, k, it, p, a, nw=[];
  function put(gk){ if(codexNote(gk)){ n++; nw.push(gk); } }
  function item(key){ it=ITEMS[key]; if(it&&it.use==='gun'&&it.gk) put(it.gk); }
  if(!P) return 0;
  a=P.weapons||[]; for(i=0;i<a.length;i++) put(a[i]);
  a=P.stash||[]; for(i=0;i<a.length;i++) item(a[i]);
  a=P.kit||[]; for(i=0;i<a.length;i++) item(a[i]);
  if(typeof G!=='undefined'&&G&&!G.sim&&!G.arcade){
    a=G.bag||[]; for(i=0;i<a.length;i++) item(a[i]);
    p=G.player;
    if(p){ if(p.wep&&p.wep.id) put(p.wep.id); if(p.sec&&p.sec.id) put(p.sec.id); }
    if(n&&state==='raid'){ try{ say('CODEX ENTRY','info',{sub:String(WEAPONS[nw[0]].name).toUpperCase()+'  \u00b7  '+(ITEMRAR[gunRarity(nw[0])]||'')}); }catch(_cs){} }
  }
  if(n){ try{ saveProfile(); }catch(_sv){} }
  return n;
}
function careerTick(dt){
  if(!G||G.sim||G.arcade||G.over) return;
  G.cxT=(G.cxT||0)-(dt>0?dt:0);
  if(G.cxT>0) return;
  G.cxT=1;
  codexScan();
}
careerStyle('careercss2',
  '#codexmodal .cxgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(228px,1fr));gap:10px;flex:1;min-height:0;overflow-y:auto;padding:4px 4px 8px 2px;align-content:start}'+
  '.cxt{position:relative;display:flex;gap:12px;align-items:center;padding:10px 12px;background:rgba(0,0,0,.32);border:1px solid var(--ui-line-hi);border-left:3px solid var(--cx,#9da3a8);clip-path:polygon(9px 0,100% 0,100% 100%,0 100%,0 9px)}'+
  '.cxt .cxi{flex:none;width:60px;height:60px;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.4)}'+
  '.cxt.no .cxi img{filter:brightness(0) opacity(.45)}'+
  '.cxt .cxb{min-width:0;font-family:var(--f-cond);text-transform:uppercase}'+
  '.cxt .cxn{font-weight:700;font-size:19px;letter-spacing:.04em;color:var(--tx-1);line-height:1.1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
  '.cxt.no .cxn{color:var(--tx-3)}'+
  '.cxt .cxr{font-weight:600;font-size:14px;letter-spacing:.1em;color:var(--cx,#9da3a8);margin-top:3px}'+
  '.cxt.no .cxr{opacity:.7}'+
  '.cxt .cxk{font-weight:600;font-size:14px;letter-spacing:.1em;color:var(--tx-2);margin-top:2px}'+
  '.cxt .cxnew{position:absolute;top:6px;right:8px;font-family:var(--f-cond);font-weight:700;font-size:12px;letter-spacing:.14em;color:var(--acc-ink);background:var(--acc);padding:1px 6px}');
function renderCodex(){
  var gr=document.getElementById('codexgrid'), hd=document.getElementById('codex_h'), L=codexGuns(), h='', i, id, W, r, f, kn, seen=(P&&+P.codexSeen)||0, nw;
  if(hd) hd.textContent='ARMORY CODEX  \u00b7  '+codexFound()+' OF '+L.length+' FOUND';
  if(!gr) return 0;
  for(i=0;i<L.length;i++){
    id=L[i]; W=WEAPONS[id]; r=gunRarity(id); f=codexHas(id); kn=f?gunKillsOf(id):0;
    nw=(f&&seen>0&&(+P.codex[id])>seen);
    h+='<div class="cxt '+(f?'yes':'no')+'" data-gun="'+id+'" style="--cx:'+(RCOL[r]||'#9da3a8')+'">'+
       '<div class="cxi">'+iconImgHTML(id,52)+'</div>'+
       '<div class="cxb"><div class="cxn">'+(f?escHtml(W.name):'NOT FOUND')+'</div>'+
       '<div class="cxr">'+escHtml(ITEMRAR[r]||'')+(gunClassOf(id)?'  \u00b7  '+escHtml(gunClassOf(id)):'')+'</div>'+
       (kn>0?'<div class="cxk">KILLS  '+kn.toLocaleString()+'</div>':'')+'</div>'+
       (nw?'<div class="cxnew">NEW</div>':'')+'</div>';
  }
  gr.innerHTML=h;
  return L.length;
}
function codexOpen(){
  codexScan();
  renderCodex();
  openModal('codexmodal');
  try{ sndUi('open'); }catch(_su){}
  try{ var b=document.getElementById('closecodex'); if(b&&!b._cx){ b._cx=1; b.onclick=function(){ document.getElementById('codexmodal').classList.remove('on'); if(P){ P.codexSeen=Date.now(); try{ saveProfile(); }catch(_s){} } try{ renderHub(); }catch(_rh){} }; } }catch(_cb){}
}
function gunKillsOf(gk){
'@

SubRx @'
var VER='26.96';
'@ @'
var VER='26.97';
'@

$pat = "(?m)^  now:'v26\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.97: The stash has an ARMORY page that lists every gun and rarity, found or not. Check 26.97 fails on v26.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
