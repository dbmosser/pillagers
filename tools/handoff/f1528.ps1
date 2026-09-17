$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.27',what:
'@ @'
  {v:'15.28',what:'a grenade a pillager throws sounds where it lands: the Frag Charge he puts beside you plays the rising charge warning at the charge itself, the clank still plays at his hand, and the two scatter draws still land the charge where they always did (sound audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raiderThrow!=='function'||typeof sfx!=='function'||typeof rr!=='function'||typeof rnd!=='function') return 'SKIP: no pillager throw, sfx or seeded draw in this build';
     if(!ITEMS.frag||ITEMS.frag.use!=='throw'||ITEMS.frag.tk!=='frag') return 'SKIP: no Frag Charge a pillager can throw in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, e=null, keepE=null, fr=null, _sfx=sfx, _rr=rr, heard=[], draws=0, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.frags) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim, and a sim plays no sound';
       if(CFG.raiderKit===0) return 'SKIP: pillager kits are off here, so no pillager throws';
       var p=g.player;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed&&!g.ents[i].finished&&!g.ents[i].merc) e=g.ents[i];
       if(!e) return 'SKIP: no pillager to hand a charge to';
       keepE={x:e.x,y:e.y,bag:e.bag,thrT:e.thrT,smkT:e.smkT,hp:e.hp,rng:e.rng,kitThrows:e.kitThrows};
       var fR=(CFG.fragR===undefined?190:CFG.fragR), fd=fR+52+100;
       if(fd>=520) return 'SKIP: a blast radius of '+fR+' leaves no distance a pillager throws from';
       // Distinctive: he stands fd units east of you, a long-armed healthy man with one charge, and the two scatter draws are
       // pinned to 0.125 then 0.875, so his charge lands 19.5 west and 19.5 south of you: 27.6 from where you stand, and a
       // swapped draw order would put it 19.5 east instead.
       e.x=p.x+fd; e.y=p.y; e.bag=['frag']; e.thrT=0; e.smkT=99; e.hp=e.maxhp||100; e.rng=520;
       var DR=[0.125,0.875];
       rr=function(){ var v=(draws<DR.length)?DR[draws]:0.5; draws++; return v; };
       sfx=function(t,x,y){ heard.push({t:String(t),x:x,y:y}); };
       var n0=g.frags.length, threw=false;
       try{ threw=raiderThrow(e,p,fd,0.016); } finally { rr=_rr; sfx=_sfx; }
       fr=(g.frags.length>n0)?g.frags[g.frags.length-1]:null;
       // CONTROL: he threw one live charge of his own from inside his band, so a throw really happened.
       if(!threw||g.frags.length!==n0+1||!fr) return 'SKIP: the pillager would not throw from '+fd+' units here';
       if(fr.by!==e||!(fr.fuse>0)||fr.t!==0) return 'SKIP: the new charge is not his live charge here';
       // CONTROL: the pinned draws were taken, so where the charge lies is known.
       if(draws===0) return 'SKIP: the seeded draw stub did not take, so where the charge lands cannot be pinned';
       // CONTROL: the recorder heard the clank at his hand, so it hears the sounds a throw makes.
       var clank=heard.filter(function(h){ return h.t==='clank'&&Math.abs(h.x-e.x)<0.5&&Math.abs(h.y-e.y)<0.5; });
       if(!clank.length) return 'SKIP: the recorder heard no clank at the hand of the thrower ('+(heard.map(function(h){ return h.t; }).join(',')||'no sound')+'), so it cannot hear a throw here';
       // The scatter keeps its two draws in their old order.
       var wantX=p.x-19.5, wantY=p.y+19.5;
       if(draws!==2||Math.abs(fr.x-wantX)>0.001||Math.abs(fr.y-wantY)>0.001) bad.push('the charge took '+draws+' seeded draws and landed at '+(fr.x-p.x).toFixed(2)+','+(fr.y-p.y).toFixed(2)+' from you, not the two draws in order that put it at -19.50,19.50, so the seeded stream moved');
       // THE FIX: the warning plays at the charge itself.
       var dFr=Math.sqrt((fr.x-p.x)*(fr.x-p.x)+(fr.y-p.y)*(fr.y-p.y));
       var at=heard.filter(function(h){ return h.t==='charge'&&Math.abs(h.x-fr.x)<0.5&&Math.abs(h.y-fr.y)<0.5; });
       var off=heard.filter(function(h){ return h.t==='charge'&&!(Math.abs(h.x-fr.x)<0.5&&Math.abs(h.y-fr.y)<0.5); });
       if(!at.length){
         if(off.length) bad.push('the charge warning played '+Math.sqrt((off[0].x-fr.x)*(off[0].x-fr.x)+(off[0].y-fr.y)*(off[0].y-fr.y)).toFixed(1)+' units from where the charge lies, not at the charge');
         else bad.push('a charge a pillager threw landed '+dFr.toFixed(1)+' units from you with a '+fr.fuse+' second fuse and made no sound where it landed; the only sound was '+heard.map(function(h){ return h.t+' '+Math.round(Math.sqrt((h.x-p.x)*(h.x-p.x)+(h.y-p.y)*(h.y-p.y)))+' units away'; }).join(', '));
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       rr=_rr; sfx=_sfx;
       try{ if(g&&g.frags&&fr){ var fi=g.frags.indexOf(fr); if(fi>=0) g.frags.splice(fi,1); } }catch(_f){}
       try{ if(e&&keepE){ e.x=keepE.x; e.y=keepE.y; e.bag=keepE.bag; e.thrT=keepE.thrT; e.smkT=keepE.smkT; e.hp=keepE.hp; e.rng=keepE.rng; e.kitThrows=keepE.kitThrows; } }catch(_k){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
