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

if ($s.Contains("  {v:'17.44',what:")) { throw "check 17.44 is in the fixture already" }

SubRx @'
  {v:'17.43',what:
'@ @'
  {v:'17.44',what:'trading in a raid: with the backpack open T offers the selected item to the teammate in reach, and it leaves only when he takes it; an offer to this player is taken with T and the item lands in his backpack; a stale yes moves nothing',
   run:function(){
     if(typeof netGiftKey!=='function'||typeof netGiftTake!=='function') return 'this build has no trading';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, sent=[], bad=[], oSend=netSend, oName=netSeatName, oShown=netUpShown, oSay=say, peer={seat:1,state:'in'}, S, i, sel=-1;
     for(k in NET) NK[k]=NET[k];
     function last(op){ var j; for(j=sent.length-1;j>=0;j--) if(sent[j]&&sent[j].t==='gift'&&sent[j].op===op) return sent[j]; return null; }
     function cnt(key){ return G.bag.filter(function(x){ return x===key; }).length; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; };
       netSeatName=function(s){ return s===0?'ZQX HOST':(s===1?'ZQX MATE':null); };
       netUpShown=function(g){ return !!g; };
       say=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       NET.up=[null,{seat:1,x:G.player.x+60,y:G.player.y,n:1,age:0,dn:0}];
       G.bag=['scrap','wire']; G.bagOpen=true;
       S=bagStacks(); for(i=0;i<S.length;i++) if(G.bag[S[i].idxs[0]]==='wire') sel=i;
       if(sel<0) return 'SKIP: staging: no Copper Wire stack';
       G.bagSel=sel;
       netGiftKey();
       var of=last('offer');
       if(!of||of.k!=='wire'||of.to!==1) bad.push('T with the backpack open did not offer the selected Copper Wire to the teammate in reach');
       if(cnt('wire')!==1) bad.push('the offered item left the backpack before it was taken');
       netGiftTake(peer,{t:'gift',op:'yes',id:'bogus',to:0});
       if(cnt('wire')!==1) bad.push('a yes for another offer took the item');
       if(of) netGiftTake(peer,{t:'gift',op:'yes',id:of.id,to:0});
       if(cnt('wire')!==0) bad.push('the item stayed in the backpack after the teammate took it');
       var gv=last('give'); if(!gv||gv.k!=='wire'||gv.to!==1) bad.push('no give word carried the Copper Wire to the teammate');
       G.bagOpen=false; sent.length=0;
       netGiftTake(peer,{t:'gift',op:'offer',id:'zqx1',k:'medkit',to:0});
       if(!G.giftIn||G.giftIn.k!=='medkit') bad.push('an offer to this player was not held for him to take');
       netGiftKey();
       var ys=last('yes'); if(!ys||ys.id!=='zqx1'||ys.to!==1) bad.push('T did not take the offer');
       var m0=cnt('medkit');
       netGiftTake(peer,{t:'gift',op:'give',id:'zqx1',k:'medkit',to:0});
       if(cnt('medkit')!==m0+1) bad.push('the item handed over did not land in the backpack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netSeatName=oName; netUpShown=oShown; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G){ G.bagOpen=false; G.giftIn=null; G.giftOut=null; } }catch(_g){}
       try{ __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
