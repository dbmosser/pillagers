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

if ($s.Contains("  {v:'27.13',what:")) { throw "check 27.13 is in the fixture already" }

SubRx @'
  {v:'27.12',what:
'@ @'
  {v:'27.13',what:'his answer 33: damage numbers are a Settings row in DISPLAY, ON by default; OFF stops them floating off a hit',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof updateBullets!=='function') return 'SKIP: no Settings or bullets here';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kD=CFG.dmgNumbers, rows, rr=null, i, all=null, e, n0, onN, offN;
     function secOf(id){ var el=document.getElementById(id), s=el&&el.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function hit(){
       var h;
       e.hp=e.maxhp=500; e.armor=0; e.x=p.x+80; e.y=p.y; e.face=Math.PI; e.roll=0; e.downed=false; e.finished=0;
       g.ents=[e]; g.bullets.length=0; g.dmgN=[];
       g.bullets.push({x:p.x+20,y:p.y,vx:1180,vy:0,dmg:30,life:1,player:true,owner:p,tint:'#ffd48a',thru:0});
       for(h=0;h<8;h++) updateBullets(0.016);
       return (g.dmgN||[]).length;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: staging: no raid';
       all=g.ents.slice(); p.iv=99; p.downed=false;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       for(i=0;i<rows.length;i++) if(rows[i].k==='dmgNumbers') rr=rows[i];
       if(!rr){ bad.push('Settings has no DAMAGE NUMBERS row'); }
       else {
         if(rr.label!=='DAMAGE'+' NUMBERS') bad.push('the row is called '+rr.label);
         if(secOf('go_dmgNumbers')!=='DISPLAY') bad.push('the row sits under '+secOf('go_dmgNumbers')+', not DISPLAY');
         if(CFG.dmgNumbers!==1) bad.push('a fresh profile has damage numbers '+CFG.dmgNumbers+', not ON');
         if(__opts.ix('dmgNumbers')!==rr.def||rr.opts[rr.def].cfg.dmgNumbers!==1) bad.push('the default of the row is not ON');
       }
       e=mkCrawler(p.x+80,p.y);
       onN=hit();
       if(!(onN>0)) bad.push('with the row ON a hit floated no damage number');
       if(rr){
         __opts.cycle('dmgNumbers');
         if(CFG.dmgNumbers!==0) bad.push('one click did not turn damage numbers OFF ('+CFG.dmgNumbers+')');
         offN=hit();
         if(offN!==0) bad.push('with the row OFF a hit still floated '+offN+' damage numbers');
         __opts.cycle('dmgNumbers');
         if(CFG.dmgNumbers!==1) bad.push('a second click did not turn damage numbers back ON');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CFG.dmgNumbers=kD; P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ if(all&&g) g.ents=all; }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __cleanProfile(); }catch(_cp){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
