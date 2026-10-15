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

# DAMAGE NUMBERS BY WHAT THE HIT WAS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function dmgNum(x,y,amount,col,kill){
'@ @'
// v27.xx (feel2f), HIS WORDS (2026-10-14): "coloured by weak spot/element". DAMAGE NUMBERS ARE CODED BY WHAT THE HIT WAS. A number over a target now says it before you read it: a hit on a
// weak point is the colour of THAT weak point (the vent and the Pillbox slit orange, the optic cyan, the core seam amber, the dorsal spine violet; it was one orange for all), a round
// from a forged gun is the colour of its element (FIRE red, SHOCK blue, CRYO ice, ACID green), a hit the armour mostly soaked (a pillager's plate, the Bulwark shield, the Warden armour) is
// GREY, a hit from behind on a machine is amber as before, and a plain hit stays white. A weak point comes first (it ignores armour), then the element, then the armour. The colour
// goes to the other window in the same word, so player 2 sees the same colours. Cosmetic only: the damage and the DAMAGE NUMBERS setting (v27.13) are untouched.
var DMGC_SOAK='#9aa3ab';
function dmgNumCol(wk,el,soak,back){
  if(wk) return wk.c||'#ff8a3c';
  if(el&&ELEM[el]) return ELEM[el].c;
  if(soak) return DMGC_SOAK;
  return back?'#ffc04a':'#FFF6DC';
}
function dmgNum(x,y,amount,col,kill){
'@

SubRx @'
              var _nar=0;   // v22.04 (K16): on a linked window, the armour flag the host soaks this round with
'@ @'
              var _nar=0;   // v22.04 (K16): on a linked window, the armour flag the host soaks this round with
              var _soak=0;   // v27.xx (feel2f): the armour took most of this round (a grey number)
'@

SubRx @'
                edmg*=(en.kind==='warden')?WARDEN_SOAK:(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak);
'@ @'
                edmg*=(en.kind==='warden')?WARDEN_SOAK:(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak);
                _soak=1;   // v27.xx (feel2f)
'@

SubRx @'
                var eab=Math.min(en.armor,edmg*esk); en.armor-=eab; edmg-=eab;
'@ @'
                var eab=Math.min(en.armor,edmg*esk); en.armor-=eab; edmg-=eab;
                if(eab>0) _soak=1;   // v27.xx (feel2f)
'@

SubRx @'
                var _dc=WK?'#ff8a3c':((b.el&&ELEM[b.el])?ELEM[b.el].c:(edmg>0&&_backShot?'#ffc04a':'#FFF6DC'));   // v23.xx (forge3): an element round shows its colour; a weak point stays orange, the more important fact
'@ @'
                var _dc=dmgNumCol(WK,b.el,_soak||(NET.on&&netEntsPeer()&&en.armor>0&&!WK),edmg>0&&_backShot);   // v27.xx (feel2f): the weak point's own colour, the element, grey for armour, white; was one orange for every weak point
'@

SubRx @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,hitKills(en,edmg));   // v8.35; v23.18: the kill style on player 2 too
'@ @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg));   // v8.35; v23.18: the kill style on player 2 too   // v27.xx (feel2f): a weak point number starts above its label
'@

SubRx @'
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*1.1),_dn,_dc,hitKills(en,edmg));   // v16.22: the party sees your numbers
'@ @'
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*(WK?2.7:1.1)),_dn,_dc,hitKills(en,edmg));   // v16.22: the party sees your numbers
'@

SubRx @'
    wc.fillStyle=INK;   wc.fillText(d.kill?(d.n+'!'):String(d.n),d.x+1,d.y+1);
'@ @'
    var _dlw=wc.lineWidth, _dlj=wc.lineJoin; wc.lineJoin='round'; wc.lineWidth=3; wc.strokeStyle=INK; wc.strokeText(d.kill?(d.n+'!'):String(d.n),d.x,d.y); wc.lineWidth=_dlw; wc.lineJoin=_dlj;   // v27.xx (feel2f): an ink outline, so every colour reads on every floor
    wc.fillStyle=INK;   wc.fillText(d.kill?(d.n+'!'):String(d.n),d.x+1,d.y+1);
'@

SubRx @'
var VER='27.84';
'@ @'
var VER='27.85';
'@

$pat = "(?m)^  now:'v27\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.85: Damage numbers are coloured by what the hit was: weak spot colour, element colour, grey for armour, white for plain. Check 27.85 fails on v27.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
