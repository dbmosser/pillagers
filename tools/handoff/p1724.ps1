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

# WITH THE GAME OPEN IN TWO TABS, THE OLDER TAB NO LONGER WIPES WHAT THE OTHER TAB SAVED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function saveProfile(){ if(typeof NET==='object'&&NET&&NET.upHold) return;   // v15.79: nothing is written while a party build has the host world dials in; the build is saved once they are out
  P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@ @'
// v17.24, co-op hunt 2026-09-28: TWO TABS ON ONE SAVE. Each tab reads the save once, at boot, and every save writes its whole
// profile over the key, so with the game open in two tabs the tab holding the older copy wiped what the other had banked (an
// extract, or a death that cost the kit) the next time it saved anything, a backpack close or a settings click. When another
// tab writes this save (the storage event, which never fires in the tab that wrote it), this tab stops saving and puts up a
// card with RELOAD, so the newest save is the one kept. A ?p2 or ?netslot window has a key of its own and is never touched.
var SAVE_STALE=false;
function saveStaleShow(){
  var el=document.getElementById('stalesave'), b;
  if(el||!document.body) return el;
  el=document.createElement('div'); el.id='stalesave';
  el.style.cssText='position:fixed;left:0;top:0;right:0;bottom:0;z-index:99999;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,.84)';
  el.innerHTML='<div style="border:1px solid var(--hazard);border-radius:3px;padding:16px 22px;background:rgba(0,0,0,.6);max-width:460px;text-align:center">'+
    '<div style="color:var(--hazard);font-size:14px;letter-spacing:.12em;margin-bottom:8px">THIS SAVE WAS CHANGED IN ANOTHER TAB</div>'+
    '<div style="color:var(--bone);font-size:12px;margin-bottom:12px">Nothing more is saved from this tab, so it cannot write over the other one. Reload to carry on from the newest save.</div>'+
    '<button id="stalereload" class="deploy" style="padding:6px 18px">RELOAD</button></div>';
  document.body.appendChild(el);
  b=document.getElementById('stalereload'); if(b) b.onclick=function(){ try{ location.reload(); }catch(e){} };
  return el;
}
try{ window.addEventListener('storage',function(ev){ if(!ev||ev.key!==SKEY||SAVE_STALE) return; SAVE_STALE=true; try{ saveStaleShow(); }catch(e){} }); }catch(_sse){}
// ESC or ENTER on the card reloads too; nothing else closes it.
try{ window.addEventListener('keydown',function(ev){ if(!SAVE_STALE||!document.getElementById('stalesave')) return; if(ev.code==='Escape'||ev.code==='Enter'||ev.code==='NumpadEnter'){ ev.preventDefault(); ev.stopPropagation(); try{ location.reload(); }catch(e){} } },true); }catch(_ssk){}
function saveProfile(){ if(typeof NET==='object'&&NET&&NET.upHold) return;   // v15.79: nothing is written while a party build has the host world dials in; the build is saved once they are out
  if(SAVE_STALE) return;   // v17.24: another tab has written this save since this tab read it; writing now would wipe that
  P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@

SubRx @'
var VER='17.23';
'@ @'
var VER='17.24';
'@

$pat = "(?m)^  now:'v17\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.24: Two tabs on one save overwrote each other: saveProfile writes the whole in-memory P over SKEY, P is read only at boot, and nothing listened for another tab writing the key, so the stale tab next save (a backpack close, a settings click, the crash catcher) wiped the other tab extract or put back a kit lost to a death. A storage listener for SKEY now sets SAVE_STALE, saveProfile writes nothing while it is set, and a card that only closes to a reload (RELOAD, ESC or ENTER) says the save was changed in another tab. The storage event never fires in the tab that wrote, and a ?p2 or ?netslot window has its own key, so same machine co-op is untouched. Check 17.24 fails on v17.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
