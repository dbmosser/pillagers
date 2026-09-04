$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTES, 2026-09-03 about 19:50 and 19:55: "add some full-body
# ============ outfits to the cosmetics that overrule everything else -- like a
# ============ skeleton, a robot, and a halo spartan", then "2b from nier
# ============ automata, lara croft, micheal jordan, 2pac". A new rack, OUTFIT,
# ============ above every other slot. When one is worn the painter takes its
# ============ colours for the coat, the trousers, the boots, the skin and the
# ============ hands, its own hat, cut and beard, no face mark, no tattoo, no
# ============ patch, and paints the suit's own marks on top. The four names are
# ============ licensed characters and real people, so the game gets its own
# ============ versions of what they stand for, in its own words.

# 1. The rack.
SubRx @'
var COSMETICS=[
  {id:'none',   name:'Bare',           how:'always',      kind:'hat'},
'@ @'
var COSMETICS=[
  // v10.54, his notes: OUTFITS. One rack that overrules every other slot.
  {id:'outnone',     name:'Own Clothes',       how:'always',       kind:'outfit'},
  {id:'outskeleton', name:'The Skeleton',      how:'extracts:12',  kind:'outfit'},
  {id:'outrobot',    name:'The Machine',       how:'warden:3',     kind:'outfit'},
  {id:'outtrooper',  name:'The Trooper',       how:'level:8',      kind:'outfit'},
  {id:'outandroid',  name:'The Android',       how:'runs:30',      kind:'outfit'},
  {id:'outexplorer', name:'The Tomb Explorer', how:'extracts:20',  kind:'outfit'},
  {id:'outballer',   name:'The Baller',        how:'runs:23',      kind:'outfit'},
  {id:'outpoet',     name:'The Street Poet',   how:'extracts:8',   kind:'outfit'},
  {id:'none',   name:'Bare',           how:'always',      kind:'hat'},
'@

# 2. The slot key, its default, and the look kinds.
SubRx @'
var COSKEY={hair:'cosHair',hat:'cosHat',build:'cosBuild',skin:'cosSkin',fit:'cosFit',cut:'cosCut',beard:'cosBeard',eyes:'cosEyes',face:'cosFace',boots:'cosBoots',gloves:'cosGloves',pack:'cosPack',patch:'cosPatch',tattoo:'cosTattoo'};
var COSDEF={hair:'blonde',hat:'none',build:'lean',skin:'fair',fit:'slate',cut:'long',beard:'clean',eyes:'eyebrown',face:'faceplain',boots:'bootblack',gloves:'barehands',pack:'packbrown',patch:'patchnone',tattoo:'tatnone'};
'@ @'
var COSKEY={hair:'cosHair',hat:'cosHat',build:'cosBuild',skin:'cosSkin',fit:'cosFit',cut:'cosCut',beard:'cosBeard',eyes:'cosEyes',face:'cosFace',boots:'cosBoots',gloves:'cosGloves',pack:'cosPack',patch:'cosPatch',tattoo:'cosTattoo',outfit:'cosOutfit'};
var COSDEF={hair:'blonde',hat:'none',build:'lean',skin:'fair',fit:'slate',cut:'long',beard:'clean',eyes:'eyebrown',face:'faceplain',boots:'bootblack',gloves:'barehands',pack:'packbrown',patch:'patchnone',tattoo:'tatnone',outfit:'outnone'};
// v10.54: WHAT EACH OUTFIT OVERRULES. coat and trs are the torso and the
// trousers, boots the two legs, skin the head, hands the gun hand; cut, hat and
// beard replace the racks; mark names the suit's own paint, done last.
var OUTFITS={
  outskeleton:{coat:'#0c0d10',trs:'#0c0d10',boots:['#ddd6c2','#ece6d2'],skin:'#ece6d2',hands:'#ece6d2',cut:'none',hat:'none',beard:'clean',mark:'skeleton'},
  outrobot:   {coat:'#6a7684',trs:'#4a545e',boots:['#2a3038','#3a424c'],skin:'#8a96a4',hands:'#485058',cut:'none',hat:'none',beard:'clean',mark:'robot'},
  outtrooper: {coat:'#3f6a3a',trs:'#2e4a2c',boots:['#1e2e1c','#2a4028'],skin:null,hands:'#2a4028',cut:'none',hat:'spartan',beard:'clean',mark:'trooper'},
  outandroid: {coat:'#101216',trs:'#101216',boots:['#0c0d10','#14161b'],skin:'#f7ddc2',hands:'#f7ddc2',cut:'bob',hair:'white',hat:'none',beard:'clean',mark:'android'},
  outexplorer:{coat:'#2f8a86',trs:null,boots:['#5a3a1e','#7a5030'],skin:null,hands:null,cut:'tail',hair:'dark',hat:'none',beard:'clean',mark:'explorer'},
  outballer:  {coat:'#c41e1e',trs:null,boots:['#a81a1a','#cc2424','#f2f0ea','#14161b'],skin:null,hands:null,cut:'shaved',hat:'none',beard:'clean',mark:'baller',jersey:1},
  outpoet:    {coat:'#14161b',trs:'#2a3a5a',boots:['#14161b','#1f2227','#f2f0ea','#e6e3da'],skin:null,hands:null,cut:'shaved',hat:'bandana',beard:'goatee',mark:'poet'}
};
function outfitOf(st){
  var id=st&&st.hero?cosWorn('outfit'):((st&&st.outfit)||'outnone');
  return OUTFITS[id]||null;
}
'@
SubRx @'
var LOOK_KINDS=['build','skin','hair','cut','hat','fit','beard','eyes','face','boots','gloves','pack','patch','tattoo'];
'@ @'
var LOOK_KINDS=['build','skin','hair','cut','hat','fit','beard','eyes','face','boots','gloves','pack','patch','tattoo','outfit'];   // v10.54: the outfit is part of a look
'@

# 3. The hands.
SubRx @'
function handColour(st){
  var g=st.hero?cosWorn('gloves'):(st.gloves||'barehands');
'@ @'
function handColour(st){
  var _of=outfitOf(st); if(_of&&_of.hands) return _of.hands;   // v10.54: the suit's hands
  var g=st.hero?cosWorn('gloves'):(st.gloves||'barehands');
'@

# 4. The painter: coat, trousers, boots.
SubRx @'
  var cc=iv>0?'#2a6a5e':(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
'@ @'
  var OUTF=outfitOf(st);   // v10.54: an outfit overrules the racks below
  var cc=iv>0?'#2a6a5e':(OUTF?OUTF.coat:(st.hero?((FITCOL[cosWorn('fit')]||FITCOL.slate)[1]):coat)),cLo=darkHex(cc,.42),cHi=litHex(cc,.20,true);
'@
SubRx @'
  var _BT=BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack;
'@ @'
  var _BT=OUTF?OUTF.boots:(BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack);   // v10.54
'@
SubRx @'
  var _TRS=darkHex(cc,.50);
  wc.fillStyle=_TRS;
'@ @'
  // v10.54: a suit names its trousers; null means bare legs in the skin colour.
  var _TRS=OUTF?(OUTF.trs||(OUTF.skin||(st.hero?(SKINCOL[cosWorn('skin')]||SKINCOL.fair):(SKINCOL[st.skin]||'#f2d2a8')))):darkHex(cc,.50);
  wc.fillStyle=_TRS;
'@

# 5. The jersey and the patch.
SubRx @'
  if(st.hero&&iv<=0&&cosWorn('fit')==='jersey'){
'@ @'
  if(iv<=0&&(OUTF?!!OUTF.jersey:(st.hero&&cosWorn('fit')==='jersey'))){   // v10.54: the baller wears it
'@
SubRx @'
  (function(){ var _pid=st.hero?cosWorn('patch'):(st.patch||'patchnone'); if(_pid&&_pid!=='patchnone') drawPatch(wc,_pid,x-fl*3.6-1.8+leanX,ty-21.8,3.6); })();
'@ @'
  (function(){ var _pid=OUTF?'patchnone':(st.hero?cosWorn('patch'):(st.patch||'patchnone')); if(_pid&&_pid!=='patchnone') drawPatch(wc,_pid,x-fl*3.6-1.8+leanX,ty-21.8,3.6); })();
'@

# 6. The head: hair, hat, beard, cut.
SubRx @'
  var _HC=HAIRCOL[HERO?cosWorn('hair'):(st.hair||'blonde')]||HAIRCOL.blonde;
  var HAIRDARK=_HC[0],HAIRLIT=_HC[1],HAIRHI=_HC[2];
  var HAT=HERO?cosWorn('hat'):(st.hat||'none');
  var BEARD=HERO?cosWorn('beard'):(st.beard||'clean');   // v10.17
  var _HCUT=HERO?cosWorn('cut'):null;
'@ @'
  var _HC=HAIRCOL[OUTF&&OUTF.hair?OUTF.hair:(HERO?cosWorn('hair'):(st.hair||'blonde'))]||HAIRCOL.blonde;   // v10.54
  var HAIRDARK=_HC[0],HAIRLIT=_HC[1],HAIRHI=_HC[2];
  var HAT=OUTF?OUTF.hat:(HERO?cosWorn('hat'):(st.hat||'none'));
  var BEARD=OUTF?OUTF.beard:(HERO?cosWorn('beard'):(st.beard||'clean'));   // v10.17
  var _HCUT=OUTF?OUTF.cut:(HERO?cosWorn('cut'):null);
'@
SubRx @'
  if(HERO){ _NHC=HAIRCOL[cosWorn('hair')]||HAIRCOL.blonde; _NCT=_HCUT||'long'; }
  else { _NHC=HAIRCOL[st.hair]||HAIRCOL.dark; _NCT=st.cut||'crop'; }
'@ @'
  if(OUTF){ _NHC=_HC; _NCT=_HCUT||'none'; }   // v10.54: the suit's own cut, or none
  else if(HERO){ _NHC=HAIRCOL[cosWorn('hair')]||HAIRCOL.blonde; _NCT=_HCUT||'long'; }
  else { _NHC=HAIRCOL[st.hair]||HAIRCOL.dark; _NCT=st.cut||'crop'; }
'@
SubRx @'
  wc.fillStyle=(st.hero?(SKINCOL[cosWorn('skin')]||SKINCOL.fair)
                       :(SKINCOL[st.skin]||'#f2d2a8')); rrF(hx2-7.5,ty-37,15,13,5);
  if(!HERO||(_NCT!=='long'&&_NCT!=='pigtails')){
    if(_NCT==='mohawk'){
'@ @'
  wc.fillStyle=(OUTF&&OUTF.skin)?OUTF.skin:(st.hero?(SKINCOL[cosWorn('skin')]||SKINCOL.fair)
                       :(SKINCOL[st.skin]||'#f2d2a8')); rrF(hx2-7.5,ty-37,15,13,5);   // v10.54: a suit's own skin
  if(_NCT==='none'){ /* v10.54: no hair under a suit that has none */ }
  else if(!HERO||(_NCT!=='long'&&_NCT!=='pigtails')){
    if(_NCT==='mohawk'){
'@
SubRx @'
    var _FACE=HERO?cosWorn('face'):(st.faceMark||null);   // faceMark, never face: e.face is the facing angle
'@ @'
    var _FACE=OUTF?'faceplain':(HERO?cosWorn('face'):(st.faceMark||null));   // faceMark, never face: e.face is the facing angle; v10.54: none under a suit
'@
SubRx @'
      var _tid=HERO?cosWorn('tattoo'):(st.tattoo||'tatnone'); if(!_tid||_tid==='tatnone') return;
'@ @'
      var _tid=OUTF?'tatnone':(HERO?cosWorn('tattoo'):(st.tattoo||'tatnone')); if(!_tid||_tid==='tatnone') return;   // v10.54
'@

# 7. The suit's own paint, after the headgear and before the healing arc.
SubRx @'
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
  // remaining, drawn where he is already looking rather than in the corner.
  if(HERO&&st.healLeft>0&&st.healTot>0){
'@ @'
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks
  // would have put there, so a suit is a suit and not a coat colour.
  if(OUTF&&OUTF.mark){
    var _om=OUTF.mark, _ox=x+leanX;
    if(_om==='skeleton'){
      // ribs across the torso, a spine, bone shafts down the legs, and a skull:
      // black sockets over the eyes, a nose notch, a row of teeth.
      wc.fillStyle='#ddd6c2';
      wc.fillRect(_ox-5,ty-20.6,10,1.1); wc.fillRect(_ox-5,ty-18.2,10,1.1); wc.fillRect(_ox-4.4,ty-15.8,8.8,1.1);
      wc.fillRect(_ox-0.6,ty-21.6,1.2,9.2);
      wc.fillRect(x-4.6+swing2*.5,ty-10.4,1.4,6.4-liftB*.5); wc.fillRect(x+3.4+swing*.5,ty-10.4,1.4,6.4-liftA*.5);
      wc.fillStyle=INK;
      wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.8,2.9,3.3,0,0,6.2832); wc.fill();
      wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.8,2.9,3.3,0,0,6.2832); wc.fill();
      wc.fillRect(hx2-0.7,ty-27.2,1.4,1.6);
      wc.fillRect(hx2-4.2,ty-25.4,8.4,1.0);
      wc.fillRect(hx2-2.6,ty-25.4,0.8,1.8); wc.fillRect(hx2-0.4,ty-25.4,0.8,1.8); wc.fillRect(hx2+1.8,ty-25.4,0.8,1.8);
    } else if(_om==='robot'){
      // plate seams, a chest light, a red eye bar across the face, an antenna.
      wc.fillStyle=INK;
      wc.fillRect(_ox-0.5,ty-22,1,11); wc.fillRect(_ox-6.5,ty-16.6,13,1);
      wc.fillStyle='#4de3d0'; wc.fillRect(_ox+fl*2.6-1.2,ty-19.6,2.4,1.6);
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.4,15.6,5.4,1.4);
      wc.fillStyle='#1a2028'; rrF(hx2-7.2,ty-31.9,14.4,4.4,1.1);
      wc.fillStyle='#ff3a3a'; wc.fillRect(hx2-5.8,ty-30.6,11.6,1.6);
      wc.fillStyle='#ffb0a0'; wc.fillRect(hx2-1.2+Math.cos(face)*3.6,ty-30.6,2.4,1.6);
      wc.fillStyle=INK;       wc.fillRect(hx2-0.6,ty-42.4,1.2,4.6);
      wc.fillStyle='#ff3a3a'; wc.fillRect(hx2-1.1,ty-43.6,2.2,1.6);
    } else if(_om==='trooper'){
      // shoulder plates and a chest plate in the helmet's green, lit on top.
      wc.fillStyle=INK;     rrF(_ox-9.6,ty-22.6,6,6.4,2.2); rrF(_ox+3.6,ty-22.6,6,6.4,2.2);
      wc.fillStyle='#55874c'; rrF(_ox-9,ty-22,4.8,5.6,1.8); rrF(_ox+4.2,ty-22,4.8,5.6,1.8);
      wc.fillStyle='#7aa86e'; wc.fillRect(_ox-8.6,ty-22,4,1.4); wc.fillRect(_ox+4.6,ty-22,4,1.4);
      wc.fillStyle=INK;     rrF(_ox-5.6,ty-19.4,11.2,7,1.8);
      wc.fillStyle='#55874c'; rrF(_ox-5,ty-18.9,10,6,1.4);
      wc.fillStyle='#7aa86e'; wc.fillRect(_ox-4.2,ty-18.9,8.4,1.4);
    } else if(_om==='android'){
      // a black dress: a flared hem over the hips, and a black band across the eyes.
      wc.fillStyle=INK;       rrF(_ox-8.6,ty-13.6,17.2,4.4,1.6);
      wc.fillStyle='#101216'; rrF(_ox-8,ty-13.2,16,3.6,1.3);
      wc.fillStyle='#f7ddc2'; wc.fillRect(_ox-5.4,ty-21.4,10.8,1.6);
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.0,15.6,4.6,1.4);
      wc.fillStyle='#1a1c22'; rrF(hx2-7.2,ty-31.5,14.4,3.6,1.1);
    } else if(_om==='explorer'){
      // a teal tank top with bare shoulders, a belt, and a holster on each hip.
      wc.fillStyle=(SKINCOL[st.hero?cosWorn('skin'):(st.skin||'fair')]||SKINCOL.fair);
      wc.fillRect(_ox-6.5,ty-22,2.4,3.2); wc.fillRect(_ox+4.1,ty-22,2.4,3.2);
      wc.fillStyle='#5a3a1e'; wc.fillRect(_ox-6.5,ty-12.6,13,1.6);
      rrF(_ox-8.2,ty-12.2,3,4.4,0.8); rrF(_ox+5.2,ty-12.2,3,4.4,0.8);
      wc.fillStyle='#a08a50'; wc.fillRect(_ox-1.2,ty-12.8,2.4,2);
    } else if(_om==='baller'){
      // shorts: a red band at the top of each bare leg, white trim on the hem.
      wc.fillStyle='#c41e1e';
      wc.fillRect(x-6.3+swing2*.5,ty-11,4.6,3.2); wc.fillRect(x+1.7+swing*.5,ty-11,4.6,3.2);
      wc.fillStyle='#f4f2ec';
      wc.fillRect(x-6.3+swing2*.5,ty-8,4.6,0.8); wc.fillRect(x+1.7+swing*.5,ty-8,4.6,0.8);
    } else if(_om==='poet'){
      // a gold chain at the collar and a white vest under the black.
      wc.fillStyle='#f4f2ec'; wc.fillRect(_ox-2.4,ty-21.4,4.8,7.4);
      wc.fillStyle='#e0b040';
      wc.fillRect(_ox-4.6,ty-20.4,1.2,1.2); wc.fillRect(_ox-2.6,ty-19.2,1.2,1.2); wc.fillRect(_ox-0.6,ty-18.6,1.2,1.2);
      wc.fillRect(_ox+1.4,ty-19.2,1.2,1.2); wc.fillRect(_ox+3.4,ty-20.4,1.2,1.2);
    }
  }
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
  // remaining, drawn where he is already looking rather than in the corner.
  if(HERO&&st.healLeft>0&&st.healTot>0){
'@

# 8. The Depot slot, first, because it overrules the rest.
SubRx @'
  h+=slot('build','BUILD',(cosFind(cosWorn('build'))||{name:'Lean'}).name,'\u25AF');
'@ @'
  h+=slot('outfit','OUTFIT',(cosFind(cosWorn('outfit'))||{name:'Own Clothes'}).name,'\u2B21');   // v10.54: overrules every slot below it
  h+=slot('build','BUILD',(cosFind(cosWorn('build'))||{name:'Lean'}).name,'\u25AF');
'@

# 9. The picker knows the new slot, the racks list it first, and its tile is
#    the suit's coat colour.
SubRx @'
  if(slot==='hat'||slot==='hair'||slot==='build'||slot==='skin'||slot==='fit'||slot==='cut'||slot==='beard'||slot==='eyes'||slot==='face'||slot==='boots'||slot==='gloves'||slot==='pack'||slot==='patch'||slot==='tattoo'){
'@ @'
  if(slot==='outfit'||slot==='hat'||slot==='hair'||slot==='build'||slot==='skin'||slot==='fit'||slot==='cut'||slot==='beard'||slot==='eyes'||slot==='face'||slot==='boots'||slot==='gloves'||slot==='pack'||slot==='patch'||slot==='tattoo'){   // v10.54: outfit
'@
SubRx @'
  var GROUPS=[['build','BUILD'],['skin','SKIN'],['eyes','EYES'],['face','FACE'],['tattoo','TATTOO'],['hair','HAIR'],['cut','HAIRSTYLE'],['beard','BEARD'],['hat','HEADGEAR'],['fit','CLOTHING'],['patch','PATCH'],['gloves','GLOVES'],['boots','BOOTS'],['pack','BACKPACK']]
'@ @'
  var GROUPS=[['outfit','OUTFIT'],['build','BUILD'],['skin','SKIN'],['eyes','EYES'],['face','FACE'],['tattoo','TATTOO'],['hair','HAIR'],['cut','HAIRSTYLE'],['beard','BEARD'],['hat','HEADGEAR'],['fit','CLOTHING'],['patch','PATCH'],['gloves','GLOVES'],['boots','BOOTS'],['pack','BACKPACK']]   // v10.54: the outfit rack first
'@
SubRx @'
function cosSwatch(c){
  if(c.kind==='cut'){
'@ @'
function cosSwatch(c){
  if(c.kind==='outfit'){   // v10.54: the suit's coat, or the plain tile for your own clothes
    var _oc=OUTFITS[c.id];
    return '<span style="display:inline-block;width:34px;height:34px;border-radius:6px;'+
           'background:'+(_oc?_oc.coat:'#3d4450')+';border:2px solid #14161b;position:relative">'+
           (_oc?'<span style="position:absolute;left:11px;top:4px;width:12px;height:12px;border-radius:6px;background:'+(_oc.skin||'#f2d2a8')+'"></span>':'')+'</span>';
  }
  if(c.kind==='cut'){
'@

# 10. A random look leaves the outfit rack alone (the full corpus caught it: seven
#     suits to one Own Clothes put a suit on seven times in eight).
SubRx @'
  for(var i=0;i<LOOK_KINDS.length;i++){
    var k=LOOK_KINDS[i], pool=COSMETICS.filter(function(c){ return c.kind===k&&cosOwned(c); });
    if(pool.length) P[COSKEY[k]]=pool[Math.floor(Math.random()*pool.length)].id;
  }
'@ @'
  for(var i=0;i<LOOK_KINDS.length;i++){
    var k=LOOK_KINDS[i];
    if(k==='outfit') continue;   // v10.54: a random look never puts a suit on over what it rolled
    var pool=COSMETICS.filter(function(c){ return c.kind===k&&cosOwned(c); });
    if(pool.length) P[COSKEY[k]]=pool[Math.floor(Math.random()*pool.length)].id;
  }
'@

SubRx @'
var VER='10.53';
'@ @'
var VER='10.54';
'@
SubRx @'
  now:'v10.53: the DEV CHEAT BOX has an ALL COSMETICS switch. On, every rack in the Depot is open; off, you are back to exactly what you earned and bought.',
'@ @'
  now:'v10.54: OUTFITS. A new rack at the top of the Depot with seven full-body suits that overrule every other slot: the Skeleton, the Machine, the Trooper, the Android, the Tomb Explorer, the Baller and the Street Poet. Own Clothes puts the racks back in charge.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
