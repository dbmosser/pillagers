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

# A THIRD GRENADE KIND RIDES IN THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function unkeyedHeals(){
'@ @'
// v25.xx (belt4), HIS ORDER 2026-10-13 (grenades their own class, 2 slots), decision D2: A THIRD KIND OF GRENADE LIVES IN THE BACKPACK. The two
// throwable keys hold two kinds; a kind with no key is carried as items in the backpack (key frag, smoke, decoy or trip in G.bag, weight 1
// each), so it shows in the grid, can be dropped and can be dragged onto a throwable key. How many he has of a kind is the pouch plus the
// backpack; a throw takes from the pouch first, then the backpack. The pouch is where a found grenade lands (grantLoot), and once a frame
// beltThrowTick moves the pouch of a kind that has no throwable key into the backpack. The sim, the Undercroft belt and the arcade keep
// everything in the pouch, as before.
function throwHave(tk){
  var n=(G.pouch&&G.pouch[tk])|0, i;
  if(G.sim||G.hubFloor||!G.bag) return n;
  for(i=0;i<G.bag.length;i++) if(G.bag[i]===tk) n++;
  return n;
}
function throwTake(tk){
  var ix;
  if(((G.pouch&&G.pouch[tk])|0)>0){ G.pouch[tk]--; return true; }
  if(!G.sim&&G.bag){ ix=G.bag.indexOf(tk); if(ix>=0){ G.bag.splice(ix,1); return true; } }
  return false;
}
function beltThrowTick(){
  if(!G||G.sim||G.hubFloor||G.over||G.arcade||!G.pouch||!G.bag||!G.player) return;
  var sl=hotbarSlots(), shown={}, i, tk, n;
  for(i=GUNKEYS;i<HOTBAR_N;i++) if(BELT_CLASS[i]==='throw'&&sl[i]&&sl[i].kind==='throw') shown[sl[i].icon]=1;
  for(i=0;i<THROWKEYS.length;i++){
    tk=THROWKEYS[i]; n=G.pouch[tk]|0;
    if(n>0&&!shown[tk]){ G.pouch[tk]=0; while(n-->0) G.bag.push(tk); }
  }
}
function unkeyedHeals(){
'@

SubRx @'
  if(it.use==='throw') return ((G.pouch&&G.pouch[it.tk])|0);
'@ @'
  if(it.use==='throw') return throwHave(key);   // v25.xx (belt4): the pouch and the backpack
'@

SubRx @'
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return; }
  G.pouch[tk]--; G.tel.thr[tk]++;
'@ @'
  if(throwHave(tk)<=0){ emptyThrowCell(tk); return; }   // v25.xx (belt4): the pouch and the backpack
  throwTake(tk); G.tel.thr[tk]++;
'@

SubRx @'
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return false; }
  G.pouch[tk]--; G.tel.thr[tk]++;
'@ @'
  if(throwHave(tk)<=0){ emptyThrowCell(tk); return false; }   // v25.xx (belt4): the pouch and the backpack
  throwTake(tk); G.tel.thr[tk]++;
'@

SubRx @'
    if(G.pouch[THROWKEYS[n]]>0){
'@ @'
    if(throwHave(THROWKEYS[n])>0){   // v25.xx (belt4): the pouch and the backpack
'@

SubRx @'
  holdHTick(dt);   // v25.xx (holdhplate): H, a tap or a hold
'@ @'
  holdHTick(dt);   // v25.xx (holdhplate): H, a tap or a hold
  beltThrowTick();   // v25.xx (belt4): a kind of grenade with no throwable key goes from the pouch to the backpack
'@

SubRx @'
  if(cls==='throw') return;
'@ @'
  // v25.xx (belt4): a grenade of a third kind has no key and goes to the backpack (BELTAT -2, the BACKPACK tag on its row)
'@

SubRx @'
var VER='25.91';
'@ @'
var VER='25.92';
'@

$pat = "(?m)^  now:'v25\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.92: A third kind of grenade is now carried in the backpack as items, and a throwable key swaps it in. Check 25.92 fails on v25.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
