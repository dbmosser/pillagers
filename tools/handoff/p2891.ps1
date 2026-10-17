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

# PRE-RAID: PACK WHEEL ITEMS, AMMO, KEYS AND A DATA CORE ON THE MAP SELECT SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<h3>Where are you going?</h3>
'@ @'
<h3>PRE-RAID</h3>
'@

SubRx @'
<div id="sectorkit" style="margin-top:11px;
'@ @'
<!-- v28.xx (cw-preraid), HIS ORDER (2026-10-15): "On the pre-raid screen, quickly pick how much cash and how many of each wheel item to take, plus keys and guns", "Also how much ammo to take", "Slot a data core there too". The pack row: one chip per kind of thing in the stash, minus, plus and MAX, and the data core slot. -->
  <div id="sectorpack" style="margin-top:9px"></div>
  <div id="sectorkit" style="margin-top:11px;
'@

SubRx @'
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;

'@ @'
// v28.xx (cw-preraid), HIS ORDER (2026-10-15): "On the pre-raid screen (the map select screen, renamed PRE-RAID), quickly pick how much cash and how many of each wheel item to take, plus keys and guns. Also how much ammo to take. Slot a data core there too."
// The map select screen is headed PRE-RAID and has a PACK row under the surface and weather rows: every kind of item the stash holds that can be carried (wheel items in wheel order, then ammo, keys, guns,
// the rest) as a chip with minus, plus and MAX that packs it for this raid (P.kit, the same list the stash and the ascent check edit), ALL and NONE, and the data core slot (P.intel, burns on ascent).
// It shows with MY LOADOUT only; a kit pick fills the pack itself. Cash is not here yet (a raid has no cash to carry in).
function packList(){
  var cnt={}, i, k, it, out=[], seen={}, ord=[], rest, rk;
  for(i=0;i<(P.stash||[]).length;i++){ k=P.stash[i]; it=ITEMS[k]; if(it&&it.use) cnt[k]=(cnt[k]||0)+1; }
  try{ ord=wheelOrderTable().slice(); }catch(_pw){ ord=[]; }
  for(i=0;i<ord.length;i++) if(cnt[ord[i]]&&!seen[ord[i]]){ seen[ord[i]]=1; out.push(ord[i]); }
  rest=Object.keys(cnt).filter(function(x){ return !seen[x]; });
  rk=function(x){ var u=ITEMS[x].use; return u==='ammo'?0:(u==='key'?1:(u==='gun'?2:3)); };
  rest.sort(function(a,b){ return (rk(a)-rk(b))||(ITEMS[a].name<ITEMS[b].name?-1:1); });
  return out.concat(rest);
}
function packSet(key,n){
  var held=heldCount(key), cur;
  if(P.freeKit) kitApply('mine');   // the freebie kit is set aside first, as MY LOADOUT does
  n=Math.max(0,Math.min(held,n)); cur=packedCount(key);
  if(n>cur) packSome(key,n-cur); else if(n<cur) unpackSome(key,cur-n);
  saveProfile();
}
function packCore(){
  if(P.intel){ P.intel=0; P.stash.push('core'); }
  else if(heldCount('core')>0){ spendHeld('core',1); P.intel=1; }
  else return false;
  saveProfile(); return true;
}
careerStyle('careercsspk',
  '.pkc{display:inline-flex;align-items:center;gap:5px;padding:4px 8px;border:1px solid var(--steel-hi);border-radius:3px;font-size:14px}'+
  '.pkc.on{border-color:var(--amber)}'+
  '.pkc .pkn{letter-spacing:.08em;color:var(--ash);margin-right:3px}'+
  '.pkc.on .pkn{color:var(--amber)}'+
  '.pkc button,.pkb{padding:2px 9px;font-size:14px;min-width:0}'+
  '.pkc b{min-width:1.4em;text-align:center}');
function syncSectorPack(){
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc;
  if(!host) return;
  if(kitPickOf()!=='mine'){ host.style.display='none'; host.innerHTML=''; return; }
  host.style.display='';
  keys=packList();
  h='<div style="display:flex;flex-wrap:wrap;gap:6px 8px;align-items:center"><span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">PACK</span>';
  for(i=0;i<keys.length;i++){
    k=keys[i]; held=heldCount(k); got=packedCount(k);
    h+='<span class="pkc'+(got?' on':'')+'" data-pk="'+escHtml(k)+'"><span class="pkn">'+escHtml(String(ITEMS[k].name).toUpperCase())+'</span>'+
       '<button data-pd="-1">-</button><b>'+got+'</b><span style="color:var(--ash)">/'+held+'</span><button data-pd="1">+</button><button data-pd="max">MAX</button></span>';
  }
  nc=heldCount('core');
  h+='<button class="pkb" data-pa="all">ALL</button><button class="pkb" data-pa="none">NONE</button>';
  h+='<button class="pkb" data-core="1"'+((!P.intel&&!nc)?' disabled':'')+(P.intel?' style="border-color:var(--amber);color:var(--amber)"':'')+'>'+
     (P.intel?'DATA CORE SLOTTED':(nc?('SLOT DATA CORE ('+nc+')'):'NO DATA CORE'))+'</button></div>';
  host.innerHTML=h;
  host.onclick=function(ev){
    var b=ev.target&&ev.target.closest?ev.target.closest('button'):null, ch, pk, d, pa, j, ks;
    if(!b||b.disabled) return;
    ch=b.closest('[data-pk]'); pk=ch?ch.getAttribute('data-pk'):null; d=b.getAttribute('data-pd'); pa=b.getAttribute('data-pa');
    if(b.getAttribute('data-core')){ if(!packCore()) return; }
    else if(pa){ ks=packList(); for(j=0;j<ks.length;j++) packSet(ks[j],pa==='all'?heldCount(ks[j]):0); }
    else if(pk&&d){ packSet(pk,d==='max'?heldCount(pk):packedCount(pk)+(+d)); }
    else return;
    try{ sndUi('click'); }catch(_ps){}
    syncSectorPack(); try{ syncSectorKit(); }catch(_pk){} try{ refreshInv(); }catch(_pr){}
  };
}
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)

'@

SubRx @'
var VER='28.90';
'@ @'
var VER='28.91';
'@

$pat = "(?m)^  now:'v28\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.91: The map select screen is now PRE-RAID, with a PACK row: plus, minus and MAX for each wheel item, ammo, key and gun, and a data core slot. Check 28.91 fails on v28.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
