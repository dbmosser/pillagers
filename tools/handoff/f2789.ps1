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

if ($s.Contains("  {v:'27.89',what:")) { throw "check 27.89 is in the fixture already" }

SubRx @'
  {v:'27.88',what:
'@ @'
  {v:'27.89',what:'cloud review finding 14 and his answer 31: the crowbar swing does a pillager the same damage from behind as from the front, while a machine still takes half again from behind',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof fireWeapon!=='function'||typeof WEAPONS!=='object'||!WEAPONS.fists) return 'SKIP: no melee here';
     var bad=[], g=null, p=null, all=null, r, c, lostR, lostC, w=WEAPONS.fists, want;
     function swing(e,face){
       var h0;
       e.hp=e.maxhp=500; e.armor=0; e.x=p.x+34; e.y=p.y; e.face=face; e.roll=0; e.downed=false; e.finished=0;
       g.ents=[e]; h0=e.hp;
       fireWeapon(p,w,p.x+100,p.y,true);
       return h0-e.hp;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: staging: no raid';
       all=g.ents.slice(); p.iv=99; p.downed=false; keys={};
       r=all.filter(function(x){ return x.kind==='raider'&&x.hp>0&&!x.merc; })[0];
       if(!r){ try{ r=mkRaider(p.x+34,p.y,IDENTITIES[0],false); }catch(_mr){ r=null; } }
       if(!r) return 'SKIP: no pillager to swing at';
       c=mkCrawler(p.x+34,p.y);
       want=w.dmg*pwrMul('dmg',true);
       lostR=swing(r,0);            // facing away from the swing: a blow from behind
       if(!(lostR>0)) return 'SKIP: staging: the swing did not land on the pillager';
       lostC=swing(c,0);
       if(Math.abs(lostR-want)>0.5) bad.push('a swing into a pillager back did '+lostR.toFixed(1)+', not '+want.toFixed(1)+': the blow from behind still pays more on a pillager');
       if(!(lostC>want*1.3)) bad.push('a swing into a crawler back did '+lostC.toFixed(1)+', the machines lost their blow from behind (want '+(want*1.5).toFixed(1)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(all&&g) g.ents=all; }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over&&g2.player){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
