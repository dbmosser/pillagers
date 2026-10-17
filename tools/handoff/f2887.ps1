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

if ($s.Contains("  {v:'28.87',what:")) { throw "check 28.87 is in the fixture already" }

SubRx @'
  {v:'28.86',what:
'@ @'
  {v:'28.87',what:'cloud-coop-overseer-phase-shake: when THE OVERSEER changes phase, player 2 window says the phase line and shakes like the host (shake at least 6)',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netOnMsg!=='function'||typeof ovPhaseLine!=='function') return 'SKIP: no arcade, party or Overseer in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, lines=[], h={seat:0,state:'in'}, staged=false, oIv=null, r, want;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,m){ return true; }; netSend=function(q,m){ return true; };
       say=function(t){ lines.push(String(t)); };
       want=ovPhaseLine(2); g.shake=0;
       r=netOnMsg(h,JSON.stringify({t:'mark',k:'phase',nid:0,n:2,seat:0}));
       if(lines.indexOf(want)<0) return 'player 2 window did not say the phase line ('+r+'; said: '+lines.join(' | ')+')';
       if(!((g.shake||0)>=6)) return 'player 2 window said the Overseer phase line but did not shake (shake '+g.shake+', the host shakes 6)';
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
