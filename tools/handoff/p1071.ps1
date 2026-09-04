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

# ============ THE SAFE POCKET TOLD THE TRUTH NOWHERE, AND ONE OF THE LIES WAS
# ============ MINE, SHIPPED IN v10.70.
# ============
# ============ The safe pocket NAMES one item key. One copy of it comes home if
# ============ you die CARRYING it, which is the spec from v6.01 and is right.
# ============ It is a name for something in your backpack, not a slot that holds
# ============ anything of its own. The deploy is honest about that: P.safeUp is
# ============ armed only when the named key is in the kit going up.
# ============
# ============ FAULT ONE, MINE. v10.70 added the safe pocket to the LOADOUT
# ============ total as though it were an extra thing being carried. Measured on
# ============ v10.70: a medkit and a plate read 550c; add a bandage worth 60 and
# ============ it reads 610c, correct; NAME that same packed bandage as the safe
# ============ pocket and it reads 670c, counting it twice; and arm a bandage
# ============ that is NOT packed and it still reads 610c, counting an item that
# ============ stays at home. Wrong in both directions. Taken back out.
# ============
# ============ FAULT TWO, older and worse. The stash screen shows the pocket as
# ============ 1/1 whether or not the named item is actually going up, because
# ============ safeKey accepts it sitting in the STASH. Measured: a bandage in
# ============ the stash, armed, with a backpack of medkit and plate, shows
# ============ "Safe pocket 1/1" and deploys with P.safeUp null. The one promise
# ============ that protects you from losing everything was inert and the screen
# ============ said it was armed.
# ============
# ============ FAULT THREE. The ASCENT CHECK, which calls itself the last stop
# ============ before the lift where everything can still be changed, never
# ============ mentioned the safe pocket at all.
SubRx @'
function setSafe(k){
'@ @'
// v10.71: the pocket that is ACTUALLY going up. safeKey above answers "is
// something named", which is true while the item sits in the stash; this answers
// "will anything come home", which is the question the player is really asking
// and the one the deploy uses. Same test as buildRaid's P.safeUp line.
function safeUpKey(){
  var k=safeKey(); if(!k) return null;
  var K=(typeof stageKitLive==='function')?stageKitLive():(P.kit||[]);
  return (K.indexOf(k)>=0)?k:null;
}
function setSafe(k){
'@

SubRx @'
  var k=safeKey();
  var lab=document.getElementById('safen');
  if(lab) lab.textContent=(k?1:0)+'/1';
  if(!k){
    var em=document.createElement('div'); em.className='cellempty';
    em.textContent='ONE ITEM SURVIVES YOUR DEATH. DROP IT HERE.';
    sg.appendChild(em);
  } else {
    var cell=invCell(k,1,{from:'safe',verb:'click: empty the pocket',
      act:function(){ setSafe(null); try{ sfx("pick"); }catch(e){} renderHub(); }});
'@ @'
  var k=safeKey();
  // v10.71: named is not the same as protecting you. The item only comes home if
  // you are carrying it, so a pocket naming something still sitting in the stash
  // is doing nothing, and this said 1/1 either way.
  var live=safeUpKey();
  var lab=document.getElementById('safen');
  if(lab) lab.textContent=k?(live?'1/1':'NOT PACKED'):'0/1';
  if(!k){
    var em=document.createElement('div'); em.className='cellempty';
    em.textContent='ONE ITEM SURVIVES YOUR DEATH. DROP IT HERE.';
    sg.appendChild(em);
  } else {
    if(!live){
      var wr=document.createElement('div'); wr.className='cellempty';
      wr.style.color='var(--hazard)';
      wr.textContent='NOT IN YOUR BACKPACK. PACK ONE OR NOTHING COMES HOME.';
      sg.appendChild(wr);
    }
    var cell=invCell(k,1,{from:'safe',verb:'click: empty the pocket',
      act:function(){ setSafe(null); try{ sfx("pick"); }catch(e){} renderHub(); }});
'@

SubRx @'
  var kvEl=document.getElementById('kitval');
  if(kvEl){ var kv=0; for(var _kq=0;_kq<_goingUp.length;_kq++) kv+=ival(_goingUp[_kq]);
    var _sk=safeKey(); if(_sk) kv+=ival(_sk);
    kvEl.textContent=kv.toLocaleString(); }
'@ @'
  // v10.70 counted the whole backpack including the copies on tactical belt keys,
  // which was the fix, AND added the safe pocket, which was my mistake in the
  // same line. The pocket names one of the items already in this list, so adding
  // it counted that item twice; and when the named item is not packed it counted
  // something that stays at home. Measured both ways at 60 credits out.
  var kvEl=document.getElementById('kitval');
  if(kvEl){ var kv=0; for(var _kq=0;_kq<_goingUp.length;_kq++) kv+=ival(_goingUp[_kq]);
    kvEl.textContent=kv.toLocaleString(); }
'@

SubRx @'
    var kn=stageKitLive().length;
    bits.push(kn?(kn+' item'+(kn===1?'':'s')+' packed'):'<span style="color:var(--ash)">nothing packed</span>');
    sw.innerHTML=bits.join('  &middot;  ');
'@ @'
    var kn=stageKitLive().length;
    bits.push(kn?(kn+' item'+(kn===1?'':'s')+' packed'):'<span style="color:var(--ash)">nothing packed</span>');
    // v10.71: and the safe pocket, on the page that calls itself the last stop
    // before the lift. It is the one thing that survives your death and the one
    // thing this page never named.
    var _sfk=safeKey(), _sfl=safeUpKey();
    if(!_sfk) bits.push('<span style="color:var(--ash)">no safe pocket</span>');
    else if(_sfl) bits.push('safe pocket: '+escHtml(ITEMS[_sfk].name));
    else bits.push('<span style="color:var(--hazard)">safe pocket names '+escHtml(ITEMS[_sfk].name)+', not packed</span>');
    sw.innerHTML=bits.join('  &middot;  ');
'@

SubRx @'
var VER='10.70';
'@ @'
var VER='10.71';
'@
SubRx @'
  now:'v10.70: the LOADOUT number counts everything going up with you. It was reading the backpack grid, so putting an item on a tactical belt key made its value disappear from the total, and the safe pocket was never counted at all.',
'@ @'
  now:'v10.71: the safe pocket tells you the truth. It read 1/1 even when the item it names is still in the stash, where it protects nothing, and the ascent check never mentioned it at all. This also corrects my own v10.70, which counted the pocket as an extra item being carried.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
