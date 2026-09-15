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
  {v:'15.07',what:
'@ @'
  {v:'15.08',what:'a cooked Frag Charge keeps burning through a roll: rolling with a Frag Charge cooking moves the fuse on as standing does, and a fuse that runs out mid-roll goes off in his hand with the roll cover dropped (throwables audit finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function'||typeof explodeFrag!=='function'||typeof FRAG_FUSE!=='number'||typeof mouse==='undefined'||typeof keys==='undefined') return 'SKIP: no cook, roll or belt in this build';
     if(!(THROWKEYS&&THROWKEYS.indexOf('frag')>=0&&ITEMS.frag)) return 'SKIP: no Frag Charge in this build';
     var bad=[], g0=null, _say=say, _ex=explodeFrag, blasts=[];
     function cellOf(want){ var sl=hotbarSlots(), i; for(i=0;i<sl.length;i++) if(sl[i]&&(sl[i].k==='throw:'+want||sl[i].itemKey===want)) return i; return -1; }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     function cook(q,t,roll){ clearKeys(); q.downed=false; q.cooking=1; q.cookKind='frag'; q.cookT=t; q.fired=true; q.trigYield=0; q.roll=roll; q.rollCd=(roll>0?0.85:0); q.rollDir={x:0,y:0}; q.iv=(roll>0?0.3:99); mouse.down=true; }
     function steps(k,dt){ for(var j=0;j<k;j++) updatePlayer(dt); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g;
       var p=g.player;
       g.ents.length=0; p.downed=false; p.roll=0; p.iv=99;
       g.hotAuto={}; g.hotAssign={}; g.pouch=g.pouch||{}; g.pouch.frag=2;
       var fc=cellOf('frag');
       if(fc<0) return 'SKIP: no Frag Charge cell on the tactical belt';
       g.hot=-1; setHot(fc);
       say=function(m){}; explodeFrag=function(f){ blasts.push({iv:g.player.iv}); };
       // CONTROL: standing still with the trigger held, four 0.05s steps move a cooking fuse from 0.5 to 0.7.
       cook(p,0.5,0); steps(4,0.05);
       if(!p.cooking||Math.abs((p.cookT||0)-0.7)>0.01) return 'SKIP: standing with a Frag Charge cooking, the fuse read '+p.cookT+' after 0.2s, not 0.7';
       // THE FINDING: the same fuse through a roll. Four 0.05s steps leave 0.18s of the 0.38s roll.
       cook(p,0.5,0.38); steps(4,0.05);
       if(!(p.roll>0)) return 'SKIP: the roll ended inside the steps here (roll '+p.roll+')';
       if(!p.cooking) bad.push('the Frag Charge stopped cooking during the roll');
       else if(Math.abs((p.cookT||0)-0.7)>0.01) bad.push('rolling for 0.2s with a Frag Charge cooking left the fuse at '+(+p.cookT).toFixed(2)+', where standing moves it to 0.70');
       // AND A FUSE THAT RUNS OUT MID-ROLL goes off in his hand, with the roll cover gone so the blast can hurt him.
       blasts.length=0;
       cook(p,FRAG_FUSE-0.03,0.38); steps(2,0.05);
       if(!(p.roll>0)) return 'SKIP: the roll ended inside the cook-off steps here';
       if(p.cooking||!blasts.length) bad.push('a Frag Charge 0.03s from its fuse was still in hand after 0.1s of rolling (cooking '+p.cooking+', fuse '+(+(p.cookT||0)).toFixed(2)+')');
       else if(blasts[0].iv>0) bad.push('the Frag Charge went off in his hand mid-roll with '+(+blasts[0].iv).toFixed(2)+'s of roll cover left, so the blast could not hurt him');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; explodeFrag=_ex;
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(g0){ if(g0.player){ var q=g0.player; q.cooking=0; q.cookT=0; q.cookKind=null; q.fired=false; q.roll=0; q.rollCd=0; q.iv=0; q.downed=false; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
