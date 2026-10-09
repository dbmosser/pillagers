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

if ($s.Contains("  {v:'20.83',what:")) { throw "check 20.83 is in the fixture already" }

SubRx @'
  {v:'20.82',what:
'@ @'
  {v:'20.83',what:'player 2 is told the weather is turning: the host word that starts a turn says the line once on the linked window with the charge sound kept there, later words of the same turn and its end say nothing, and the host turn sound is no longer passed on as a second one',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netWorldTake!=='function'||typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSay=say, oSfx=sfx, oPick=pickWeather, kPick=P.wxPick, lines=[], heard=[], g, i, q, cur, W2=null, W3=null, peer={seat:0,state:'in'}, want, n1, T;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.wx||!g.player) return 'SKIP: no live raid';
       cur=g.wx.id;
       for(i=0;i<WEATHER.length;i++){ q=WEATHER[i]; if(q.id===cur||q.id==='partly'||!q.line) continue; if(!W2) W2=q; else if(!W3){ W3=q; break; } }
       if(!W2||!W3) return 'SKIP: staging: no two other skies';
       say=function(s){ lines.push(String(s)); };
       sfx=function(t){ heard.push({t:t,fx:!!NET.fxIn}); };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[peer]; NET.upSeed=g.seed>>>0; NET.fxIn=false;
       g.wxNext=null; g.wxT=0;
       want='The weather is turning. '+W2.line;
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,wx:cur,wn:W2.id,wt:0});
       if(!g.wxNext||g.wxNext.id!==W2.id) return 'SKIP: staging: the host turn did not reach the linked window';
       n1=lines.filter(function(s){ return s===want; }).length;
       if(n1!==1) bad.push('player 2 was told the weather is turning '+n1+' times, not once (said: '+JSON.stringify(lines)+')');
       if(!heard.some(function(h){ return h.t==='charge'&&h.fx; })) bad.push('player 2 heard no turn sound of his own');
       lines=[]; heard=[];
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,wx:cur,wn:W2.id,wt:0.3});
       if(lines.length) bad.push('the next host word about the same turn said it again: '+lines.join(' / '));
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,wx:W2.id,wn:'',wt:0});
       if(lines.length) bad.push('the end of the turn was said as a new turn: '+lines.join(' / '));
       lines=[]; heard=[];
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}];
       P.wxPick='any'; pickWeather=function(){ return W3; };
       g.wx=W2; g.wxNext=null; g.wxT=0; g.wxTurnsLeft=2; g.wxAt=0;
       wxTick(0.016);
       T=heard.filter(function(h){ return h.t==='charge'; });
       if(g.wxNext&&g.wxNext.id===W3.id){
         if(!T.length) bad.push('control: the host turn made no sound');
         else if(!T[0].fx) bad.push('the host turn sound is still passed on to the party, so player 2 hears it a second time from where the host stands');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; sfx=oSfx; pickWeather=oPick;
       if(kPick===undefined) delete P.wxPick; else P.wxPick=kPick;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
