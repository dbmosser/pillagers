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

if ($s.Contains("  {v:'20.62',what:")) { throw "check 20.62 is in the fixture already" }

SubRx @'
  {v:'20.61',what:
'@ @'
  {v:'20.62',what:'a gun that comes to hand from a search in the middle of a reload does not finish the old gun reload: it keeps the rounds it came with and needs its own reload',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof grantLoot!=='function'||typeof tickReload!=='function'||!ITEMS.gun_rifle||!WEAPONS.rifle||!WEAPONS.pistol||!WEAPONS.smg) return 'SKIP: no raid, search or guns in this fixture';
     var NK={}, k, bad=[], g, p, oSay=say, said=[], ct;
     for(k in NET) NK[k]=NET[k];
     function cp(w){ var o={}, q; for(q in w) o[q]=w[q]; o.q='field'; o.qRank=1; return o; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'SKIP: no live raid';
       p=g.player;
       say=function(s){ said.push(String(s)); };
       p.wep=cp(WEAPONS.pistol); p.ammo=3; p.wepIssued=true; p.wepFromArmory=false;
       p.sec=cp(WEAPONS.smg); p.secAmmo=10; p.secIssued=false; p.secFromArmory=false;
       p.reserve=777; p.reloading=WEAPONS.pistol.reload||1400; p.jam=0;
       g.stowAmmo={rifle:[5]};
       ct={x:p.x+30,y:p.y,dropped:1,loot:[],type:'crate',opened:true};
       grantLoot(ct,['gun_rifle'],0);
       if(!(p.wep&&p.wep.id==='rifle')) return 'SKIP: staging: the Auto Rifle did not come to hand from the search (holding '+(p.wep&&p.wep.id)+')';
       if(p.ammo!==5) return 'SKIP: staging: the Auto Rifle came up with '+p.ammo+' rounds, not the 5 it was dropped with';
       said=[];
       tickReload(2);
       if(p.ammo!==5||p.reserve!==777) bad.push('the Auto Rifle that came to hand mid reload was filled to '+p.ammo+' by the Scav Pistol reload, taking '+(777-p.reserve)+' rounds from the pool');
       if(said.indexOf('Reloaded')>=0) bad.push('Reloaded played for a reload the new gun never did');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.reloading=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
