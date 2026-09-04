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

# ============ HIS NOTE 14, THE SECOND HALF: PASTING THE CODE BACK IN.
# ============
# ============ v11.03 put a RESTORE CODE at the end of every report and could
# ============ read one back. A code nobody can apply is a note in a bottle, so
# ============ this is the other half: paste it in the recorder tab, beside the
# ============ report it came out of.
# ============
# ============ IT IS DESTRUCTIVE AND IT SAYS SO. Applying a code REPLACES the save
# ============ being played. So it is a three step door, the same shape as the
# ============ save delete he already has: READ the code, which decodes it and
# ============ says in words whose character it is and what it is worth; then a
# ============ typed word; then REPLACE. Nothing is written before the word is
# ============ typed, and the code is shown to him before he types it, so he can
# ============ see he pasted the wrong one.
# ============
# ============ WHAT IT DOES NOT DO: it does not restore the run log. The log is
# ============ history, it is not in the code, and pretending to bring it back
# ============ would be a lie in the one place that has to be trustworthy.

# ---- 1. the door, under the report it belongs to
SubRx @'
      <button id="wipelog" style="padding:8px 22px;margin-left:auto;border-color:var(--rust);color:var(--rust)">Clear recorder</button>
    </div>
  </div>
'@ @'
      <button id="wipelog" style="padding:8px 22px;margin-left:auto;border-color:var(--rust);color:var(--rust)">Clear recorder</button>
    </div>
    <!-- v11.04, HIS NOTE 14: the other end of the restore code, beside the report
         it comes out of. Destructive, so it is a three step door. -->
    <div style="margin-top:12px;border-top:1px solid var(--steel-hi);padding-top:10px">
      <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">RESTORE A CHARACTER</div>
      <div class="msub">Paste a RESTORE CODE from the end of a run report. It REPLACES the save you are playing. Read it first: the game will tell you whose character it is before anything is written.</div>
      <textarea id="rescode" rows="2" spellcheck="false" placeholder="PIL1..." style="width:100%"></textarea>
      <div style="display:flex;gap:8px;margin-top:6px;align-items:center;flex-wrap:wrap">
        <button id="resread" style="padding:7px 16px">READ CODE</button>
        <span id="reswhat" style="font-size:11px;color:var(--ash)"></span>
      </div>
      <div id="resconfirm" style="display:none;margin-top:8px;border:1px solid var(--hazard);border-radius:3px;padding:8px 11px;background:rgba(0,0,0,.28)">
        <span style="color:var(--hazard);font-size:11px">Type the word restore to replace the save you are playing with <b id="reswho"></b>.</span>
        <div style="display:flex;gap:8px;margin-top:6px">
          <input id="resword" autocomplete="off" spellcheck="false" style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--hazard);border-radius:3px;color:var(--bone);padding:5px 9px;font-size:12px">
          <button id="resgo" class="deploy ghost" style="padding:5px 12px;border-color:var(--hazard);color:var(--hazard)">REPLACE</button>
          <button id="resno" class="deploy ghost" style="padding:5px 12px">KEEP MINE</button>
        </div>
      </div>
    </div>
  </div>
'@

# ---- 2. what applying one actually does
SubRx @'
function buildExport(){
'@ @'
// v11.04, HIS NOTE 14: apply a code. Every field the maker wrote, and nothing
// else: the run log is history, it is not in the code, and it is left alone
// rather than pretended at.
function restoreApply(o){
  if(!o||typeof o.c!=='number') return false;
  P.pname=String(o.n||'PILLAGER').slice(0,16);
  P.credits=o.c|0; P.xp=o.x|0; P.xpLevel=o.l||1;
  P.runs=o.r|0; P.ext=o.e|0; P.died=o.d|0; P.best=o.b|0; P.notoriety=o.no|0;
  P.pack=o.pk|0; P.racks=o.ra|0; P.arrays=o.ar|0; P.cstand=o.cs|0;
  P.spClaimed=(o.sc||[]).slice(); P.kills=o.ki||{}; P.cosBought=o.cb||{};
  P.junk=o.j||{}; P.mapIx=o.mi|0; P.cond=(o.cd==='night')?'night':'day';
  P.wxPick=o.wq||'any';
  var k;
  for(k in COSKEY) if(o.w&&o.w[k]) P[COSKEY[k]]=o.w[k];
  // An item that no longer exists cannot come back, or every panel that draws
  // the stash reads undefined for a key with no row in the table.
  var st=[], id, i, c;
  for(id in (o.s||{})){
    if(!ITEMS[id]) continue;
    c=o.s[id]|0; if(c<0) c=0; if(c>999) c=999;
    for(i=0;i<c;i++) st.push(id);
  }
  P.stash=st;
  saveProfile();
  return true;
}
// What a code says it is, in words, before anything is written.
function restoreSay(o){
  if(!o) return 'That is not a restore code.';
  var st=0, id;
  for(id in (o.s||{})) st+=(o.s[id]|0);
  return o.n+', '+(o.r|0)+' raid'+((o.r|0)===1?'':'s')+', '+'$'+(o.c|0).toLocaleString()+
         ', '+(o.x|0).toLocaleString()+' XP, '+st+' item'+(st===1?'':'s')+' in the stash.';
}
function buildExport(){
'@

# ---- 3. the three steps, wired
SubRx @'
document.getElementById('wipelog').onclick=function(){
'@ @'
// v11.04, HIS NOTE 14: READ, then a typed word, then REPLACE. Nothing is written
// until the word is typed, and what the code says it is shown first, so a wrong
// code is caught by reading rather than by losing a character to it.
(function(){
  var pend=null;
  function el(id){ return document.getElementById(id); }
  function shut(){ pend=null; var c=el('resconfirm'); if(c) c.style.display='none'; var w=el('resword'); if(w) w.value=''; }
  var rr=el('resread');
  if(rr) rr.onclick=function(){
    var ta=el('rescode'), o=restoreRead(ta?ta.value:'');
    var say=el('reswhat');
    pend=o;
    if(!o){ if(say){ say.style.color='var(--hazard)'; say.textContent='That is not a restore code.'; } shut(); return; }
    if(say){ say.style.color='var(--ash)'; say.textContent=restoreSay(o); }
    var who=el('reswho'); if(who) who.textContent=String(o.n||'PILLAGER');
    var c=el('resconfirm'); if(c) c.style.display='';
    pend=o;
  };
  var go=el('resgo');
  if(go) go.onclick=function(){
    var w=el('resword'), word=((w&&w.value)||'').trim().toLowerCase();
    if(word!=='restore'||!pend) return;
    var o=pend;
    if(!restoreApply(o)) return;
    shut();
    var say=el('reswhat');
    if(say){ say.style.color='var(--gain)'; say.textContent=o.n+' is back. The game is reloading.'; }
    // Everything on the floor was built from the old profile, so it comes back
    // the way switching save does.
    try{ setTimeout(function(){ location.reload(); },400); }catch(_rl){ location.reload(); }
  };
  var no=el('resno');
  if(no) no.onclick=function(){ shut(); var say=el('reswhat'); if(say) say.textContent=''; };
})();
document.getElementById('wipelog').onclick=function(){
'@

SubRx @'
var VER='11.03';
'@ @'
var VER='11.04';
'@
SubRx @'
  now:'v11.03: every run report now ends with a RESTORE CODE, your note 14. One line that carries the character: name, credits, XP, the counters the racks are unlocked from, what they are wearing, the stash as counts, contracts standing and junk tags. The run log stays out, being history rather than identity. Pasting it back in is the next build, behind a typed confirmation.',
'@ @'
  now:'v11.04: the other end of the restore code, your note 14. Settings, the recorder tab, under the report: paste a code, press READ CODE and it tells you whose character it is and what it is worth, then type the word restore and press REPLACE. Nothing is written before the word. It does not bring back the run log, because the log is history and is not in the code.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A LOST CHARACTER CAN COME BACK. Settings, the recorder tab: paste the RESTORE CODE from the end of any run report, press READ CODE to see whose it is, then type the word restore. It replaces the save you are playing, so it asks twice. It does not bring back the run log.',
'@
SubRx @'
var WHATSNEW_VER='11.03';
'@ @'
var WHATSNEW_VER='11.04';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
