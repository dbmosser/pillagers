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

# THE PARTY SEES EACH OTHERS DAMAGE NUMBERS. His note of 2026-09-27.

SubRx @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v8.35
'@ @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v8.35
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v16.22: the party sees your numbers
'@

SubRx @'
  if(m.k==='n'&&m.n&&m.n.length){
'@ @'
  if(m.k==='d'&&m.d&&m.d.length>=4){   // v16.22: a damage number one of the party put up
    a=m.d; try{ if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(+a[0]||0,+a[1]||0,Math.max(1,a[2]|0),(/^#[0-9a-fA-F]{3,8}$/).test(a[3])?a[3]:'#FFF6DC',!!a[4]); }catch(_dn){}
    return 'fx:d';
  }
  if(m.k==='n'&&m.n&&m.n.length){
'@

SubRx @'
function netFxNoise(type,x,y,wid){
'@ @'
// v16.22, HIS NOTE: HE SHOULD SEE THE DAMAGE NUMBERS WHEN THE OTHER PLAYER DOES DAMAGE. Every number a player's round puts up is sent
// to the party (fast channel, the host passes it on) and drawn there with the same colour and the same kill mark.
function netFxDmg(x,y,n,c,dead){
  var i, m;
  if(!netUpShared()) return false;
  m={t:'fx',k:'d',s:NET.seat,d:[Math.round(x),Math.round(y),n|0,String(c||'#FFF6DC').slice(0,9),dead?1:0]};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  return true;
}
function netFxNoise(type,x,y,wid){
'@

SubRx @'
var VER='16.21';
'@ @'
var VER='16.22';
'@

$pat = "(?m)^  now:'v16\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.22: THE PARTY SEES EACH OTHERS DAMAGE NUMBERS. His note. In co-op every damage number a player puts up shows on every window, same colour, same kill mark. No number moved. Check 16.22 fails on v16.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
