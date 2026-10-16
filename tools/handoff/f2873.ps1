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

if ($s.Contains("  {v:'28.73',what:")) { throw "check 28.73 is in the fixture already" }

SubRx @'
  {v:'28.72',what:
'@ @'
  {v:'28.73',what:'his words 2026-10-15 (what is that siren): the lock-on siren says LOCKED ON the moment it starts, once while it plays, and again for a fresh lock-on after the cool-off',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tickMachSiren!=='function'||typeof MSIREN!=='object'||typeof mkSentry!=='function') return 'SKIP: this fixture cannot stage the siren';
     var bad=[], g=null, p=null, S, lines=[], kSay=say, oAc=ac, kSim=null, kT=0, kPause=false, E0=null, kMS={}, k, kIv=0;
     var hasNet=(typeof NET==='object'&&!!NET), ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined;
     function run(sec,seeing){ var j, nn=Math.round(sec/0.05); for(j=0;j<nn;j++){ g.t+=0.05; if(seeing) for(k=0;k<g.ents.length;k++) g.ents[k].sirenSeeT=g.t; tickMachSiren(0.05); } }
     function said(){ return lines.filter(function(s){ return s==='LOCKED ON'; }).length; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents) return 'SKIP: no live raid';
       kT=g.t; kPause=!!g.paused; E0=g.ents; kSim=g.sim; kIv=p.iv; for(k in MSIREN) kMS[k]=MSIREN[k];
       g.paused=false; g.sim=false; p.iv=99; if(hasNet) NET.specTick=0;
       say=function(m){ lines.push(String(m)); };
       ac=function(){ return null; };
       MSIREN.v=null; MSIREN.on=0; MSIREN.n=0; MSIREN.lvl=0; MSIREN.said=0;
       S=mkSentry(p.x+300,p.y); S.state='chase'; S.alert=2.4; S.hp=Math.max(S.hp,10); delete S.sirenSeeT; g.ents=[S];
       run(3,false); if(said()) bad.push('LOCKED ON was said for a machine that does not see him');
       run(0.4,true); if(said()) bad.push('LOCKED ON was said before the 0.6 s lock-on hold');
       run(2,true); if(said()!==1) bad.push('LOCKED ON was said '+said()+' times at the start of a lock-on, not once');
       run(2,true); if(said()!==1) bad.push('LOCKED ON was said again while the same lock-on went on ('+said()+')');
       run(1,false); run(2,true); if(said()!==1) bad.push('LOCKED ON was said again inside the 5 s cool-off ('+said()+')');
       run(1,false); run(6,false); run(1.5,true); if(said()!==2) bad.push('a fresh lock-on after the cool-off did not say LOCKED ON again ('+said()+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=kSay; ac=oAc; }catch(_s){}
       try{ for(k in kMS) MSIREN[k]=kMS[k]; }catch(_m){}
       try{ if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; } }catch(_n){}
       try{ var g2=__state(); if(g2){ if(E0) g2.ents=E0; g2.t=kT; g2.paused=kPause; g2.sim=kSim; if(g2.player) g2.player.iv=kIv; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
