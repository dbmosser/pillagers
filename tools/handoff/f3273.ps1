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

if ($s.Contains("  {v:'32.73',what:")) { throw "check 32.73 is in the fixture already" }

SubRx @'
  {v:'32.72',what:
'@ @'
  {v:'32.73',what:'a press has a low body under the click, and a score count-up plays a hit a step and one landing hit (his Q48: punchy hits on confirm and score)',
   run:function(){
     if(typeof uiSndPick!=='function'||typeof SND_UI_LOG==='undefined'||typeof arcadeOverCount!=='function') return 'SKIP: no UI sound helpers';
     var realNow=Date.now, realSI=window.setInterval, T=0, T0=0, o, c, el, n, hits, lands, res=null, p, host, e2, cb, e1, cbs;
     function cnt(kind){ var i, k=0; for(i=0;i<SND_UI_LOG.length;i++) if(SND_UI_LOG[i].kind===kind) k++; return k; }
     function card(team){ var d=document.createElement('div'), s=document.createElement('div'); s.className='aos'; s.textContent='TEAM SCORE '+arcadeCr(team); d.appendChild(s); return d; }
     function reset(){ SND_UI_LOG.length=0; SCORE_HIT_AT=0; SCORE_LAND_AT=0; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       p=uiSndPick('ok',10,-1,0);
       if(!p||!p.body||!(p.body.f1<=200)||!(p.body.d<=0.12)) return 'the ok sound has no low body under the click ('+JSON.stringify(p&&p.body)+')';
       if(uiSndPick('back',10,-1,0).body||uiSndPick('deny',10,-1,0).body) return 'back or deny got a body';
       // 1: a run over card with a team score counts up with hits and one landing
       reset(); T0=realNow.call(Date); Date.now=function(){ return T; };
       o={at:T0,team:4321}; c=card(4321);
       for(T=T0;T<=T0+2000;T+=16) arcadeOverCount(c,o);
       hits=cnt('hit'); lands=cnt('land');
       if(hits<8||hits>25) return 'the run over count-up logged '+hits+' score hits, not 8 to 25';
       if(lands!==1) return 'the run over count-up logged '+lands+' landing hits, not 1';
       for(T=T0+2000;T<=T0+4000;T+=500) arcadeOverCount(c,o);   // the card is rebuilt or re-synced after the count: nothing plays again
       if(cnt('hit')!==hits||cnt('land')!==1) return 'a re-synced card played the hits again';
       // 2: a skip to the final score plays only the landing hit
       reset(); o={at:T0-9000,team:4321}; c=card(4321); T=T0+100;
       for(n=0;n<5;n++){ T+=16; arcadeOverCount(c,o); }
       if(cnt('hit')!==0||cnt('land')!==1) return 'a skipped count logged '+cnt('hit')+' hits and '+cnt('land')+' landings, not 0 and 1';
       // 3: a score of 0 is silent
       reset(); o={at:T0,team:0}; c=card(0);
       for(T=T0;T<=T0+2000;T+=16) arcadeOverCount(c,o);
       if(SND_UI_LOG.length) return 'a score of 0 played '+SND_UI_LOG.length+' sounds';
       // 4: a ledger figure on the career end card counts with hits, and a skip lands once
       Date.now=realNow; reset();
       host=document.createElement('div'); document.body.appendChild(host);
       e1=document.createElement('span'); e1.setAttribute('data-to','3000'); host.appendChild(e1);
       cbs=[]; window.setInterval=function(f){ cbs.push(f); return 77; };
       T0=realNow.call(Date); T=T0; Date.now=function(){ return T; };
       lbCountStart(e1,3000,0,900);
       window.setInterval=realSI;
       for(T=T0;T<=T0+1200;T+=40) cbs[0]();
       if(cnt('hit')<5) return 'the career ledger count-up logged only '+cnt('hit')+' hits';
       if(cnt('land')!==1) return 'the career ledger count-up logged '+cnt('land')+' landings, not 1';
       reset(); e2=document.createElement('span'); e2.setAttribute('data-to','3000'); host.appendChild(e2);
       window.setInterval=function(f){ return 78; }; T=T0+5000; lbCountStart(e2,3000,0,900); window.setInterval=realSI;
       e1.parentNode.removeChild(e1);
       lbCountEnd(host);
       if(cnt('hit')!==0||cnt('land')!==1) return 'a skipped ledger count logged '+cnt('hit')+' hits and '+cnt('land')+' landings, not 0 and 1';
       return null;
     } finally {
       Date.now=realNow; window.setInterval=realSI;
       try{ if(host&&host.parentNode) host.parentNode.removeChild(host); }catch(_h){}
       try{ SCORE_HIT_AT=0; SCORE_LAND_AT=0; SND_UI_LOG.length=0; }catch(_r){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
