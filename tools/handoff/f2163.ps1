$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'21.63',what:")) { throw "check 21.63 is in the fixture already" }

SubRx @'
  {v:'21.62',what:
'@ @'
  {v:'21.63',what:'a found Scav Pistol never takes a slot while you carry a better gun: holding Bare Hands in slot 2 with a rifle in slot 1, it goes into the backpack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof grantLoot!=='function'||typeof swapGuns!=='function'||!ITEMS.gun_pistol) return 'SKIP: no pickup here';
     var bad=[], w0=(P.weapons||[]).slice(), e0=P.equipped, s0=P.equippedSec, g, p, sl;
     try{
       __topClear(); __runPrep();
       P.weapons=['rifle']; P.equipped='rifle'; P.equippedSec='none';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player;
       if(!p.wep||p.wep.id!=='rifle') return 'SKIP: staging: did not deploy holding the rifle';
       swapGuns();
       grantLoot({x:p.x,y:p.y,loot:[],dropped:0},['gun_pistol']);
       sl=hotbarSlots().slice(0,2).map(function(s){ return s.icon; });
       if(sl.indexOf('pistol')>=0) bad.push('the Scav Pistol took a slot ('+sl.join(', ')+') while a rifle was carried');
       if(g.bag.indexOf('gun_pistol')<0) bad.push('the Scav Pistol is not in the backpack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} P.weapons=w0; P.equipped=e0; P.equippedSec=s0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
