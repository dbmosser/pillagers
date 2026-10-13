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

# THE FORGE: A DROPPED FORGED GUN STAYS FORGED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function dropItem(idx){
  if(idx<0||idx>=G.bag.length) return null;
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
'@ @'
// v23.xx, THE FORGE (2026-10-12), forge11: A FORGED GUN DROPPED IS STILL FORGED. A gun in the backpack is a key plus a copy in
// G.stowQ (first in, first out per model); a drop leaves the oldest copy to be trimmed, and grantLoot rebuilt a dropped gun at field
// grade (the v8 anti-reroll rule). The pile now records the MK and the element of that copy (c.fw), on a linked window in the pile word
// too, and the gun comes back out of the pile forged: you can drop your MK III and take it back, and a teammate can pick it up. A plain
// gun still comes back at field grade, exactly as before. No draw on any stream.
function forgeOfDrop(key){
  var gk=(/^gun_/.test(key)&&ITEMS[key]&&ITEMS[key].gk)?ITEMS[key].gk:null, q, w;
  if(!gk||!G||!G.stowQ) return null;
  q=G.stowQ[gk]; if(!q||q.length<=gunQCount(gk)) return null;
  w=q[0];
  if(!w||!(w.fk===1||w.fk===2)) return null;
  return {fk:w.fk,el:(w.fk===2&&w.el&&ELEM[w.el])?w.el:''};
}
function dropItem(idx){
  if(idx<0||idx>=G.bag.length) return null;
  var p=G.player,key=G.bag[idx];
  G.bag.splice(idx,1);
  var _fw=forgeOfDrop(key);   // v23.xx (forge11)
'@

SubRx @'
    if(_q&&netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib})){
'@ @'
    var _pw={t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib};
    if(_fw){ _pw.fk=_fw.fk; if(_fw.el) _pw.el=_fw.el; }   // v23.xx (forge11): a forged gun stays forged in the pile the host makes
    if(_q&&netSend(_q,_pw)){
'@

SubRx @'
  var c=setLoot(mkContainer(p.x+rnd(-14,14),p.y+rnd(6,18),'crate'),[key]);
  c.time=0.6; c.dropped=1;
'@ @'
  var c=setLoot(mkContainer(p.x+rnd(-14,14),p.y+rnd(6,18),'crate'),[key]);
  c.time=0.6; c.dropped=1;
  if(_fw) c.fw=_fw;   // v23.xx (forge11)
'@

SubRx @'
  c.time=0.6; c.dropped=1; c.dropBy=peer.seat; if(m.ib) c.issuedB=1;
'@ @'
  if((m.fk===1||m.fk===2)&&/^gun_/.test(k)) c.fw={fk:m.fk,el:(m.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''};   // v23.xx (forge11)
  c.time=0.6; c.dropped=1; c.dropBy=peer.seat; if(m.ib) c.issuedB=1;
'@

SubRx @'
var found=ct.dropped?(function(){var g2={};for(var k2 in WEAPONS[itm.gk])g2[k2]=WEAPONS[itm.gk][k2];g2.q='field';g2.qRank=1;return g2;})():rollFieldGun(itm.gk);
'@ @'
var found=ct.dropped?(function(){var g2={};for(var k2 in WEAPONS[itm.gk])g2[k2]=WEAPONS[itm.gk][k2];g2.q='field';g2.qRank=1;return g2;})():rollFieldGun(itm.gk);
      if(ct.dropped&&ct.fw&&(ct.fw.fk===1||ct.fw.fk===2)) found=forgeApply(found,ct.fw.fk,ct.fw.el);   // v23.xx (forge11): a forged gun comes out of the pile forged
'@

SubRx @'
var VER='25.49';
'@ @'
var VER='25.50';
'@

$pat = "(?m)^  now:'v25\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.50: A forged gun dropped on the ground keeps its upgrade when picked up again. Check 25.50 fails on v25.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
