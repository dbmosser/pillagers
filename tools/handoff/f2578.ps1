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

if ($s.Contains("  {v:'25.78',what:")) { throw "check 25.78 is in the fixture already" }

SubRx @'
  {v:'25.77',what:
'@ @'
  {v:'25.78',what:'his answer (crouch should always quiet walk): a crouched step makes the smallest footstep ring on every dry ground (metal and undergrowth no longer raise it), always below the upright walk on the same ground, plays the quiet crouch step sound, and crouched movement makes no loud move noise while an upright walk does',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof window.__stepsReal!=='function'||typeof ping!=='function'||typeof surfAt!=='function'||typeof updatePlayer!=='function'||typeof blipMine!=='function') return 'SKIP: this fixture cannot stage a footstep';
     var bad=[], g=null, p=null, kPing=ping, kSurf=surfAt, kBlip=blip, kMine=blipMine, kCr, kSp, kMv, kPS, kBush, ss=['stone','wood','metal','leaf'], i, s, cr={}, st={}, snd=[], loud=0, loudUp=0, quietMin;
     function stepRing(surf,on){
       var r=null; G.crouchTog=on; G.sprinting=false; G.pBush=false; p.moving=true; p.downed=false; p.roll=0; PSTEP=0;
       surfAt=function(){ return surf; };
       ping=function(x,y,sz,h,quiet,src,typ){ if(src==='player'&&typ==='move'&&quiet) r=sz; };
       snd=[]; blip=function(){ snd.push(['blip'].concat([].slice.call(arguments))); }; blipMine=function(){ snd.push(['mine'].concat([].slice.call(arguments))); };
       window.__stepsReal(0.016);   // the real step: the fixture switches the game one off (__setSteps puts it back)
       return r;
     }
     function walkLoud(on){
       var n=0, j; G.crouchTog=on; G.sprinting=false; p.moving=false; p.noiseAcc=0; p.iv=99; p.downed=false; p.roll=0;
       ping=function(x,y,sz,h,quiet,src,typ){ if(src==='player'&&!quiet) n++; };
       for(var z in keys) keys[z]=false; keys['KeyW']=true;
       for(j=0;j<50;j++) updatePlayer(0.05);
       keys['KeyW']=false;
       return n;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||g.sim) return 'SKIP: no live raid';
       kCr=g.crouchTog; kSp=g.sprinting; kMv=p.moving; kPS=PSTEP; kBush=g.pBush;
       for(i=0;i<ss.length;i++){ s=ss[i]; cr[s]=stepRing(s,true); if(snd.length) cr[s+'_snd']=snd[0]; st[s]=stepRing(s,false); if(snd.length) st[s+'_snd']=snd[0]; }
       for(i=0;i<ss.length;i++){ s=ss[i]; if(typeof cr[s]!=='number'||typeof st[s]!=='number') bad.push('no footstep ring on '+s+' (crouched '+cr[s]+', upright '+st[s]+')'); }
       if(!bad.length){
         quietMin=Math.min(cr.stone,cr.wood,cr.metal,cr.leaf);
         for(i=0;i<ss.length;i++){ s=ss[i];
           if(cr[s]>quietMin+1e-9) bad.push('a crouched step on '+s+' makes a ring of '+cr[s].toFixed(1)+', above the quiet walk of '+quietMin.toFixed(1));
           if(!(cr[s]<st[s])) bad.push('a crouched step on '+s+' ('+cr[s].toFixed(1)+') is not quieter than an upright one ('+st[s].toFixed(1)+')');
         }
         if(!(st.metal>st.stone)) bad.push('the upright step on metal ('+st.metal.toFixed(1)+') is no longer louder than on stone ('+st.stone.toFixed(1)+')');
         if(cr.stone_snd&&!(cr.stone_snd[0]==='blip'&&cr.stone_snd[5]==='crouch'&&cr.stone_snd[2]>=540)) bad.push('the crouched step did not play the quiet crouch step ('+JSON.stringify(cr.stone_snd.slice(0,6))+')');
         if(st.stone_snd&&!(st.stone_snd[0]==='mine'&&st.stone_snd[5]==='walk')) bad.push('the upright step lost its own sound ('+JSON.stringify(st.stone_snd.slice(0,6))+')');
       }
       ping=kPing; surfAt=kSurf; blip=kBlip; blipMine=kMine;
       loudUp=walkLoud(false); loud=walkLoud(true);
       if(loudUp<1) bad.push('SKIP-ish: the upright walk made no loud move noise here, so the crouched count proves nothing');
       if(loud>0) bad.push('crouched movement made '+loud+' loud move noises');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ ping=kPing; surfAt=kSurf; blip=kBlip; blipMine=kMine; }catch(_p){}
       try{ for(var z2 in keys) keys[z2]=false; if(g){ g.crouchTog=kCr; g.sprinting=kSp; g.pBush=kBush; } if(p) p.moving=kMv; PSTEP=kPS; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
