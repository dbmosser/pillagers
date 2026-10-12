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

if ($s.Contains("  {v:'24.20',what:")) { throw "check 24.20 is in the fixture already" }

SubRx @'
  {v:'24.19',what:
'@ @'
  {v:'24.20',what:'his #39: in the demo drop-in hold after a respawn SPACE, and the pad A (the same raidKey Space press with no event), starts no roll and keeps the spawn shield up; with the hold over the same press rolls',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof raidKey!=='function'||typeof tryRoll!=='function') return 'SKIP: no arcade here';
     var bad=[], g, p, rs=say, ownS=false, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', po=(typeof pauseOpen!=='undefined')?pauseOpen:false;
     function prime(){ p.roll=0; p.rollCd=0; p.stam=100; p.downed=false; p.dying=0; p.arcSh=1; keys={}; G.paused=false; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; }catch(_b){} }
       say=function(){}; ownS=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g&&g.player; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       if(!g||!g.arcade||!p) return 'SKIP: no arcade raid';
       if(pauseOpen) return 'SKIP: the pause box is open';
       ARCADE.solo=0; ARCADE.holdT=3;
       prime(); raidKey('Space',false,{preventDefault:function(){}});
       if(p.roll>0) bad.push('SPACE in the drop-in hold started a roll');
       if(p.arcSh!==1) bad.push('SPACE in the drop-in hold took the spawn shield down');
       prime(); raidKey('Space',false,null);
       if(p.roll>0) bad.push('the pad A in the drop-in hold started a roll');
       if(p.arcSh!==1) bad.push('the pad A in the drop-in hold took the spawn shield down');
       ARCADE.holdT=0;
       prime(); raidKey('Space',false,null);
       if(!(p.roll>0)) bad.push('with the hold over the roll does not start');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.solo=0; ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
