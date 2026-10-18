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

if ($s.Contains("  {v:'30.45',what:")) { throw "check 30.45 is in the fixture already" }

SubRx @'
  {v:'30.44',what:
'@ @'
  {v:'30.45',what:'his Q71: no live rank readout and no scoreboard during a run; NEW HIGH SCORE does not fire mid-run and a window that is out of a live run never shows the board page',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     if(typeof arcadeDeploy!=='function'||typeof arcadeHiTick!=='function'||typeof arcadeAttLoop!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], BK=ARCADE_BOARD_KEY, bk=null, hadB=false, rs=say, own=false, nsp=netSamePost, lines=[], g, ph, r, a0;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       try{ bk=localStorage.getItem(BK); hadB=true; localStorage.removeItem(BK); }catch(_b){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.solo=0;
       say=function(m){ lines.push(String(m)); }; own=true; netSamePost=function(){ return true; };
       arcadeBoardSave([{run:'tq71old',i:'AAA',s:100,x:0,k:0,t:Date.now(),m:2,u:'cr'}]);
       ARCADE.run={id:'tq71'}; ARCADE.hiRun=''; ARCADE.mine=5000; ARCADE.mate=0;
       r=arcadeHiTick();
       if(r||lines.some(function(l){ return l.indexOf('NEW HIGH')===0; })) bad.push('NEW HIGH SCORE fired in the middle of a run ('+lines.join(' / ')+')');
       // a benched window must not cycle to the board page
       g.player.specOut=1; ARCADE.att={t:0,at:Date.now(),ph:'',ov:0};
       ph=arcadeAttLoop(false);
       if(ph==='board') bad.push('a window that is out of a live run shows the board page');
       g.player.specOut=0;
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs; netSamePost=nsp;
       try{ if(__state()&&__state().player) __state().player.specOut=0; }catch(_s){}
       try{ ARCADE.run=null; ARCADE.mine=0; ARCADE.hiRun=''; ARCADE.att=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
