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

if ($s.Contains("  {v:'22.09',what:")) { throw "check 22.09 is in the fixture already" }

SubRx @'
  {v:'22.08',what:
'@ @'
  {v:'22.09',what:'a Listener that a call or the hot ground sent to look goes back to sleep on its next step and wakes with its scream and its beat, and the hot ground moving never takes a Listener, sleeping or hunting',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkListener!=='function'||typeof listenersHear!=='function'||typeof updateEnts!=='function'||typeof tickHot!=='function'||typeof freeSpot!=='function') return 'SKIP: no raid or Listener here';
     var NK={}, k, bad=[], g=null, p, L=null, E0=null, oSfx=sfx, oFs=freeSpot, oHot=null, hotSet=0, oPr, oLt, snd=[], z=null, far=0, i, d, lg;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       p=g.player;
       for(i=0;i<g.zones.length;i++){ d=dist(g.zones[i],p); if(d>far){ far=d; z=g.zones[i]; } }
       if(!z||far<1400) return 'SKIP: staging: no ring far from the player';
       L=mkListener(z.x+37.5,z.y+21.25); g.ents.push(L);
       sfx=function(n){ snd.push(n); };
       // a pull put it in investigate, then a noise right beside it
       L.state='investigate'; L.wakeT=0; L.millT=0;
       listenersHear(L.x+12,L.y,600,false);
       if(L.state!=='hunt') bad.push('a Listener sent to look did not wake to a noise beside it (it is '+L.state+')');
       else if(!(L.wakeT>0)) bad.push('a Listener sent to look woke and charged at once, with no beat');
       if(snd.indexOf('alarm')<0) bad.push('a Listener sent to look woke with no scream');
       // a pull put it in investigate, then one step of its own
       L.state='investigate'; L.wakeT=0; L.millT=0; lg=L.legs;
       oPr=g.prints; oLt=g.lightning; E0=g.ents;
       g.prints=[]; g.lightning=0; g.ents=[L];
       try{ updateEnts(0.016); } finally { g.ents=E0; g.prints=oPr; g.lightning=oLt; }
       if(L.legs===lg) return 'SKIP: staging: the Listener took no step';
       if(L.state!=='dormant') bad.push('a Listener sent to look stayed '+L.state+' instead of going back to sleep');
       // the hot ground moves right onto it
       oHot=g.hotZone; hotSet=1;
       freeSpot=function(){ return {x:L.x,y:L.y}; };
       g.hotZone={x:L.x,y:L.y,r:1,at:HOT_EVERY+1,moves:0};
       L.state='hunt'; L.wakeT=0; L.heardX=L.x+333.5; L.heardY=L.y;
       tickHot(0.016);
       if(L.state!=='hunt') bad.push('the hot ground moving switched a hunting Listener to '+L.state);
       g.hotZone.at=HOT_EVERY+1; L.state='dormant';
       tickHot(0.016);
       if(L.state!=='dormant') bad.push('the hot ground moving left a sleeping Listener '+L.state);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       sfx=oSfx; freeSpot=oFs;
       try{ if(g&&hotSet) g.hotZone=oHot; }catch(_h){}
       try{ if(g&&L){ i=g.ents.indexOf(L); if(i>=0) g.ents.splice(i,1); } }catch(_l){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
