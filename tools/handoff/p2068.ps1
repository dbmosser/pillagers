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

# THE SHOP SAYS HOW MANY YOU BOUGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function shopBought(label,price,where){
'@ @'
// v20.68, from the whole-game bug hunt of 2026-10-08 (H30): SHOP_TALLY, set by the cream panel while it buys an order of several,
// counts each unit here instead of saying it, and the panel says the whole order once when it is done.
var SHOP_TALLY=null;
function shopBought(label,price,where){
  if(SHOP_TALLY){ SHOP_TALLY.n++; SHOP_TALLY.v+=(price||0); SHOP_TALLY.l=label; SHOP_TALLY.w=where; return; }
'@

SubRx @'
    var _got=0;
    for(var q=0;q<qty;q++){
      var rowsNow=document.getElementById('shop').children;
      var rw=rowsNow[P._shopSel]; if(!rw) break;
      var bb=rw.querySelector('button');
      if(!bb||bb.disabled) break;
      bb.click(); _got++;
    }
'@ @'
    // v20.68, from the whole-game bug hunt of 2026-10-08 (H30): AN ORDER OF SEVERAL IS SAID ONCE, FOR ALL OF IT. Each unit is
    // bought by its own click on the row, and each click said its own line over the one before, so five Bandages for $3,300 read
    // as one Bandage for $660. The units are counted while the order runs and the whole order is said once at the end.
    var _got=0, _mh=(qty>1)?{n:0,v:0,l:'',w:''}:null;
    SHOP_TALLY=_mh;
    try{
      for(var q=0;q<qty;q++){
        var rowsNow=document.getElementById('shop').children;
        var rw=rowsNow[P._shopSel]; if(!rw) break;
        var bb=rw.querySelector('button');
        if(!bb||bb.disabled) break;
        bb.click(); _got++;
      }
    } finally { SHOP_TALLY=null; }
    if(_mh&&_mh.n>0) say2('Bought '+_mh.n+'x '+_mh.l+' for '+'$'+_mh.v.toLocaleString()+'. '+(_mh.n>1?'They are in the stash.':_mh.w));
'@

SubRx @'
var VER='20.67';
'@ @'
var VER='20.68';
'@

$pat = "(?m)^  now:'v20\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.68: Buying several of one item at the shop now says how many you bought and what all of them cost. Check 20.68 fails on v20.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
