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

if ($s.Contains("  {v:'27.06',what:")) { throw "check 27.06 is in the fixture already" }

SubRx @'
  {v:'27.05',what:
'@ @'
  {v:'27.06',what:'his answer 31: no weak spots or bonus damage in pillager fights: a round into a pillager back does the damage of the round, while a machine still takes the back shot bonus',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof updateBullets!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, r, c, lostR, lostC, i;
     function shoot(e){
       var h0, b;
       e.hp=e.maxhp=500; e.armor=0; e.x=p.x+80; e.y=p.y; e.face=0; e.roll=0; e.downed=false; e.finished=0;
       g.ents=[e]; g.bullets.length=0;
       h0=e.hp;
       b={x:p.x+20,y:p.y,vx:1180,vy:0,dmg:40,life:1,player:true,owner:p,tint:'#ffd48a',thru:0};
       g.bullets.push(b);
       for(i=0;i<8;i++) updateBullets(0.016);
       return h0-e.hp;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       all=g.ents.slice(); p.iv=99; p.downed=false;
       r=all.filter(function(x){ return x.kind==='raider'&&x.hp>0; })[0];
       if(!r){ try{ r=mkRaider(p.x+80,p.y,IDENTITIES[0],false); }catch(_mr){ r=null; } }
       c=mkCrawler(p.x+80,p.y);
       if(!r) return 'SKIP: no pillager to shoot';
       lostR=shoot(r);
       lostC=shoot(c);
       if(!(lostR>0)) return 'SKIP: staging: the round did not land on the pillager';
       if(Math.abs(lostR-40)>0.5) bad.push('a round of 40 into a pillager back did '+lostR.toFixed(1)+', not 40: there is still a back shot bonus on pillagers');
       if(!(lostC>40.5)) bad.push('a crawler hit from behind took '+lostC.toFixed(1)+', the machines lost the back shot bonus');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(all&&g) g.ents=all; }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over&&g2.player){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
