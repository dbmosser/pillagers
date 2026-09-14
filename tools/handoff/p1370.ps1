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

# HIRE AND PEDDLER AUDIT OF 2026-09-14, finding 3: SELL BACKPACK ALSO SOLD WHAT WAS ON THE BELT.
# His v8.78 rule is that an item is on the tactical belt or in the backpack, never both, and the
# backpack grid hides the copies the belt claims. The stall counted and sold all of G.bag: a
# Medkit on key 3, or a rifle just bought from him and put on the belt, went for 55 percent,
# and the key named something that was gone. The count on the stall and the sale now leave the
# belt's copies out, counted per key exactly as bagStacks counts them.
SubRx @'
function pedSellAll(){
'@ @'
// v13.70: the copies the tactical belt claims, per key, the way bagStacks counts them (v8.78).
function pedBeltClaims(){
  var cl={};
  if(G&&G.hotAssign) for(var a in G.hotAssign){ var hk=G.hotAssign[a]; if(hk) cl[hk]=(cl[hk]||0)+1; }
  return cl;
}
function pedSellAll(){
'@
SubRx @'
  var i,tot=0,full=0,n=0,kept=[];
  for(i=0;i<G.bag.length;i++){
    var k=G.bag[i];
    // He will not buy a key. Selling him the way into the vault you are standing
    // next to is not a trade, it is a mistake with a confirmation button.
    if(ITEMS[k]&&ITEMS[k].use==='key'){ kept.push(k); continue; }
'@ @'
  var i,tot=0,full=0,n=0,kept=[];
  var _cl=pedBeltClaims();
  for(i=0;i<G.bag.length;i++){
    var k=G.bag[i];
    // He will not buy a key. Selling him the way into the vault you are standing
    // next to is not a trade, it is a mistake with a confirmation button.
    if(ITEMS[k]&&ITEMS[k].use==='key'){ kept.push(k); continue; }
    // v13.70, hire and peddler audit: a copy on the tactical belt is on the belt INSTEAD of in
    // the backpack (v8.78), so SELL BACKPACK does not sell it.
    if(_cl[k]>0){ _cl[k]--; kept.push(k); continue; }
'@
SubRx @'
  var tot=0,n=0,fullv=0;
  for(i=0;i<G.bag.length;i++){
    var k=G.bag[i]; if(ITEMS[k]&&ITEMS[k].use==='key') continue;
'@ @'
  var tot=0,n=0,fullv=0,_tcl=pedBeltClaims();
  for(i=0;i<G.bag.length;i++){
    var k=G.bag[i]; if(ITEMS[k]&&ITEMS[k].use==='key') continue;
    if(_tcl[k]>0){ _tcl[k]--; continue; }   // v13.70: the belt's copies are not for sale
'@
SubRx @'
var VER='13.69';
'@ @'
var VER='13.70';
'@

$pat = "(?m)^  now:'v13\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.70: SELL BACKPACK LEAVES YOUR BELT ALONE. Hire and peddler audit of 2026-09-14, finding 3: an item is on the tactical belt or in the backpack, never both (v8.78), and the backpack grid hides the belt copies, but the stall counted and sold all of G.bag, so a Medkit on a key or a gun just bought and belted went for 55 percent and the key named nothing. pedBeltClaims counts the belt copies per key as bagStacks does, and both the stall count and the sale leave them out. Check 13.70 sells a backpack holding a belted Medkit and one other item and requires the Medkit kept and only the other item paid for; it fails on v13.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
