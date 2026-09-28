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

if ($s.Contains("  {v:'16.97',what:")) { throw "check 16.97 is in the fixture already" }

SubRx @'
  {v:'16.96',what:
'@ @'
  {v:'16.97',what:'on player 2 the search bar of a box that was on the map from the start counts the items the host says are left, and after a restock it counts the new items, not the list player 2 rolled at the build',
   run:function(){
     if(typeof netContInit!=='function'||typeof netSrchAnswer!=='function'||typeof netContWord!=='function'||typeof drawHUD!=='function'||!ctx||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no shared box count';
     var keep={}, oSend=netSend, oShown=netUpShown, oRef=netRefresh, bad=[], ct=null, i, k, c, r, L, want, t, peer={state:'in',seat:0}, texts=[], oF=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText');
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function draw(){ texts=[]; ctx.fillText=function(s){ texts.push(String(s)); return oF.apply(ctx,arguments); }; try{ drawHUD(); }catch(e){ texts.push('THREW '+e); } finally{ if(own) ctx.fillText=oF; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oF; } } } return texts; }
     function label(n){ return n+(n===1?' item left':' items left'); }
     function counts(a){ var o=[], j; for(j=0;j<a.length;j++) if(/ items? left$/.test(a[j])) o.push(a[j]); return o; }
     function ask(n){ G.searching=ct; NET.srch={cid:ct.cid,ok:0}; return netSrchAnswer(peer,{t:'srch',cid:ct.cid,ok:1,prog:0,n:n}); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid';
       netSend=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.up=[];
       NET.roster=[{seat:0,name:'CHECKHOST'},{seat:1,name:'CHECKTWO'}];
       netContInit(G);
       for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(!c.opened&&c.loot&&c.loot.length>=2){ ct=c; break; } }
       if(!ct) return 'SKIP: staging: no unopened box with two or more items';
       L=ct.loot.length; G.player.downed=false;
       r=ask(L-1);
       if(r!=='srch:ok') return 'SKIP: staging: the host ok was not taken ('+r+')';
       t=counts(draw());
       if(texts.join(' | ').indexOf('THREW ')>=0) return 'SKIP: staging: drawHUD threw ('+texts.join(' | ').slice(0,120)+')';
       want=label(L-1);
       if(t.indexOf(want)<0) bad.push('the host says '+(L-1)+' left in a box on the map from the start, but player 2 bar reads '+(t.length?t.join(', '):'no count')+' (his own list holds '+L+')');
       r=netContWord(peer,{t:'cont',st:'shut',cid:ct.cid});
       if(r!=='cont:shut') bad.push('staging: the restock word was not taken ('+r+')');
       else {
         r=ask(2);
         t=counts(draw());
         if(r!=='srch:ok') bad.push('staging: the host ok after the restock was not taken ('+r+')');
         else if(t.indexOf(label(2))<0) bad.push('after a restock the host says 2 left, but player 2 bar reads '+(t.length?t.join(', '):'no count'));
       }
     } finally {
       if(own) ctx.fillText=oF; else { try{ delete ctx.fillText; }catch(_d){ ctx.fillText=oF; } }
       try{ if(G){ G.searching=null; G.searchT=0; } }catch(e){}
       netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
