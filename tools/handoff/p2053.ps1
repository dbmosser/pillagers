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

# THE BELT HIGHLIGHT DROPS NOTHING HIDDEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bagDropSel(){
'@ @'
function bagDropSel(){
  if(bagBeltNo('Move the item into the backpack to drop it.')) return false;   // v20.53 (H17): never the unmarked stack the highlight left
'@

SubRx @'
  n=bagStacks().length; if(G.bagSel>=n) G.bagSel=Math.max(0,n-1);
  return !!dk;
}
'@ @'
  n=bagStacks().length; if(G.bagSel>=n) G.bagSel=Math.max(0,n-1);
  return !!dk;
}
// v20.53, from the whole-game bug hunt of 2026-10-08 (H17): WITH THE HIGHLIGHT ON THE BELT ROW, DROP, OFFER AND EQUIP TOUCH NOTHING HIDDEN.
// Since v16.79 the backpack highlight walks onto the belt row, and the backpack stack it left keeps its place in G.bagSel with no
// ring drawn on it. Z, Y on a controller, T and Enter all still read that place, so a press meant for the Medkit ringed on the belt
// dropped (in co-op, for the teammate to take), offered or equipped the unmarked backpack stack instead. While the highlight is on
// the belt they say so and do nothing; a click on a backpack tile brings the highlight back into the backpack.
function bagBeltNo(tail){
  if(typeof G==='undefined'||!G||!G.bagOpen||!G.bagBelt) return false;
  say('The highlight is on your belt. '+tail);
  return true;
}
'@

SubRx @'
  if(G.bagOpen){
    S=bagStacks(); st=S[clamp(G.bagSel|0,0,Math.max(0,S.length-1))];
'@ @'
  if(G.bagOpen){
    if(bagBeltNo('Move the item into the backpack to offer it.')) return true;   // v20.53 (H17): never the unmarked stack the highlight left
    S=bagStacks(); st=S[clamp(G.bagSel|0,0,Math.max(0,S.length-1))];
'@

SubRx @'
      var _sg=bagStacks()[clamp(G.bagSel,0,_stN-1)];
'@ @'
      var _sg=bagBeltNo('Walk it back into the backpack to pick a gun.')?null:bagStacks()[clamp(G.bagSel,0,_stN-1)];   // v20.53 (H17): never the unmarked stack the highlight left
'@

SubRx @'
        G.drag={key:C.key,bagIx:C.bagIx};
        G.bagSel=(C.stackIx!==undefined?C.stackIx:C.bagIx);
'@ @'
        G.drag={key:C.key,bagIx:C.bagIx};
        G.bagSel=(C.stackIx!==undefined?C.stackIx:C.bagIx); G.bagBelt=false;   // v20.53 (H17): a click on a backpack tile brings the highlight back into the backpack
'@

SubRx @'
var VER='20.52';
'@ @'
var VER='20.53';
'@

$pat = "(?m)^  now:'v20\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.53: With the backpack highlight on the belt, dropping, offering and equipping no longer act on an unmarked backpack item. Check 20.53 fails on v20.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
