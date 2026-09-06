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

# HIS ORDER, 2026-09-06 about 13:45, four messages: "dragging items,
# especially guns, in the stash isn't working right"; "GUNS in particular are
# fucked up, for some reason you keep treating them like they are special but
# they need to just move around like any other inventory item"; "in stash,
# blue and purple smgs won't drag onto tac belt". The armoury rack cells were
# made NOT draggable at v8.20b because an owned gun has no stash item behind
# it and planPut had nothing to pack. They drag now: a drop on a belt key or
# on the backpack moves the gun out of the armoury into the stash as its item
# form, then packs and binds it like anything else; a gun on the figure keeps
# its place and takes the key alone, since it goes up in your hands already.
SubRx @'
        // the wording of the refusal. Right-click equips it; that is the verb.
        oc.addEventListener('contextmenu',function(ev){
          ev.preventDefault(); ev.stopPropagation();
          openGunMenu(ev.clientX,ev.clientY,gk);
          return false;
        });
'@ @'
        // the wording of the refusal. Right-click equips it; that is the verb.
        // v11.95, HIS ORDER: "GUNS ... need to just move around like any other
        // inventory item". Draggable after all. A drop on a belt key or on the
        // backpack goes through rackPut and rackToStash below: the gun leaves the
        // armoury for the stash as its item form, then packs and binds like any
        // item; a gun on the figure keeps its place and takes the key alone.
        if(ITEMS[_ik]) grabbable(oc,_ik,'rack',W.name);
        oc.addEventListener('contextmenu',function(ev){
          ev.preventDefault(); ev.stopPropagation();
          openGunMenu(ev.clientX,ev.clientY,gk);
          return false;
        });
'@
SubRx @'
function planPut(slot,key){
  if(!key||!ITEMS[key]) return 'Nothing to put there.';
'@ @'
// v11.95, HIS ORDER: an armoury gun handled like an item. rackToStash moves it
// out of the armoury into the stash as its item form (a gun on the figure is
// left where it is); rackPut then packs and binds it through planPut, or, for
// a figure gun, binds the key alone. Both return a refusal or null.
function rackToStash(key){
  if(!key||key.indexOf('gun_')!==0||!ITEMS[key]) return 'That is not a gun.';
  var gk=key.slice(4), wi=(P.weapons||[]).indexOf(gk);
  if(wi<0) return 'That gun is not in your armoury.';
  if(P.equipped===gk||P.equippedSec===gk) return null;
  P.weapons.splice(wi,1); P.stash.push(key); saveProfile(); return null;
}
function rackPut(slot,key){
  var why=rackToStash(key); if(why) return why;
  var gk=key.slice(4);
  if(P.equipped===gk||P.equippedSec===gk){
    P.hotAssign=P.hotAssign||{};
    for(var ok in P.hotAssign) if(P.hotAssign[ok]===key) delete P.hotAssign[ok];
    P.hotAssign[slot]=key; saveProfile(); return null;
  }
  return planPut(slot,key);
}
function planPut(slot,key){
  if(!key||!ITEMS[key]) return 'Nothing to put there.';
'@
SubRx @'
      dropzone(el,function(key){
        var why=planPut(ix,key);
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
        try{ sfx('pick'); }catch(e){}
        renderHub();
      });
'@ @'
      dropzone(el,function(key,from){
        var why=(from==='rack')?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
        try{ sfx('pick'); }catch(e){}
        renderHub();
      });
'@
SubRx @'
      dropzone(el,function(key){
        var why=planPut(ix,key);
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
        try{ sfx('pick'); }catch(e){}
        renderStage();
      });
'@ @'
      dropzone(el,function(key,from){
        var why=(from==='rack')?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
        try{ sfx('pick'); }catch(e){}
        renderStage();
      });
'@
SubRx @'
  dropzone(col,function(key,from){
    // v9.82, HIS REPORT: THE BACKPACK NOW TAKES WHAT COMES OFF THE BELT. This
'@ @'
  dropzone(col,function(key,from){
    // v11.95, HIS ORDER: and a gun off the rack. It leaves the armoury for the
    // stash as its item form and is packed; a figure gun goes up already.
    if(from==='rack'){
      var _rg=key.slice(4);
      if(P.equipped===_rg||P.equippedSec===_rg){ say2('That one goes up in your hands already.'); return; }
      var _rw=rackToStash(key); if(_rw){ say2(_rw); try{ sfx('clank'); }catch(e){} return; }
      var _pw=packSome(key,1); if(_pw){ say2(_pw); return; }
      try{ sfx('pick'); }catch(e){} renderHub(); return;
    }
    // v9.82, HIS REPORT: THE BACKPACK NOW TAKES WHAT COMES OFF THE BELT. This
'@
SubRx @'
  dropzone(document.getElementById('stagekit'),function(key,from){
    if(from!=='stash') return;
'@ @'
  dropzone(document.getElementById('stagekit'),function(key,from){
    if(from==='rack'){   // v11.95: a rack gun, like any item
      var _rg2=key.slice(4);
      if(P.equipped===_rg2||P.equippedSec===_rg2){ say2('That one goes up in your hands already.'); return; }
      var _rw2=rackToStash(key); if(_rw2){ say2(_rw2); try{ sfx('clank'); }catch(e){} return; }
      var _pw2=packSome(key,1); if(_pw2){ say2(_pw2); return; }
      try{ sfx('pick'); }catch(e){} renderStage(); return;
    }
    if(from!=='stash') return;
'@

# STAMPS.
SubRx @'
var VER='11.94';
'@ @'
var VER='11.95';
'@
SubRx @'
var WHATSNEW_VER='11.94';
'@ @'
var WHATSNEW_VER='11.95';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'GUNS DRAG LIKE ANY OTHER ITEM. Drag a gun off the rack onto a tactical belt key or into the backpack and it comes with you; a gun on the figure takes the key and stays in your hands.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.94:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.94 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.94:[^']*'",{ param($m) "now:'v11.95: HIS ORDER of 2026-09-06, guns must move around like any other inventory item; the armoury rack cells were not draggable (v8.20b) because an owned gun had no stash item behind it. They drag now: a drop on a belt key or the backpack moves the gun out of the armoury into the stash as its item form, packs it and binds the key; a figure gun takes the key alone. Check 11.95 drops the SMG rack cell on key 4 and the figure pistol on key 6 through the real drop handlers; fails on v11.94.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
