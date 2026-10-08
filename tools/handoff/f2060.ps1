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

if ($s.Contains("  {v:'20.60',what:")) { throw "check 20.60 is in the fixture already" }

SubRx @'
  {v:'20.59',what:
'@ @'
  {v:'20.60',what:'a round fired by the survivor you helped passes through you, as your hire rounds do, while a round from a hostile survivor still hits you',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateBullets!=='function'||typeof damagePlayer!=='function') return 'SKIP: no raid or bullets in this fixture';
     var NK={}, k, bad=[], oDP=damagePlayer, hits=[], g, p, dirs=[[-1,0],[1,0],[0,-1],[0,1]], d=null, i, foe, pal, n;
     for(k in NET) NK[k]=NET[k];
     function shoot(own,dv){
       hits=[]; g.bullets.length=0;
       g.bullets.push({x:p.x-dv[0]*24,y:p.y-dv[1]*24,vx:dv[0]*1180,vy:dv[1]*1180,dmg:7.25,life:1,player:false,owner:own,tint:'#ffffff',thru:0});
       updateBullets(0.03); g.bullets.length=0;
       return hits.length;
     }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.bullets) return 'SKIP: no live raid';
       p=g.player;
       damagePlayer=function(a,src,nm){ hits.push(String(nm)); };
       foe={kind:'stray',name:'QX STRAY HOSTILE',hostile:true,helped:0,x:p.x+300,y:p.y,r:11};
       pal={kind:'stray',name:'QX STRAY HELPED',hostile:false,helped:1,x:p.x+300,y:p.y,r:11};
       for(i=0;i<dirs.length&&!d;i++) if(shoot(foe,dirs[i])===1) d=dirs[i];
       if(!d) return 'SKIP: staging: a round from a hostile survivor never reached you from any side here';
       n=shoot(pal,d);
       if(n) bad.push('a round from the survivor you helped hit you ('+hits.join(', ')+'), as hard as a round from a hostile one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       damagePlayer=oDP;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ if(g2.bullets) g2.bullets.length=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
