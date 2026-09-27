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

if ($s.Contains("  {v:'16.69',what:")) { throw "check 16.69 is in the fixture already" }

SubRx @'
  {v:'16.68',what:
'@ @'
  {v:'16.69',what:'a teammate whose pause box or Undercroft backpack was open when the host took the party up arrives with both shut, and his first B in the raid shuts his raid backpack instead of saving the old packing over his loadout',
   run:function(){
     if(typeof netUpStart!=='function'||typeof netUpSnapP!=='function'||typeof netUpPutP!=='function'||typeof hubBagOpenSet!=='function'||typeof togglePauseBox!=='function'||typeof backOut!=='function'||!window.__endRaid||!window.__hubEnter) return 'SKIP: this build has no party ascent or no Undercroft backpack';
     var pb=document.getElementById('pausebox'), pn=document.getElementById('pausenote');
     if(!pb) return 'SKIP: there is no pause box in this document';
     var nk={}, k, snap=null, g0=G, st0=state, k0=keys, md0=mouse.down, pn0=pn?pn.value:'', oSend=netSend, oRef=netRefresh, oSame=netUpFpSame, bad=[], r, s0,
         mark=['bandage','bandage','bandage','bandage','bandage','bandage','bandage'];
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nk[k]=NET[k];
     try{
       __runPrep(); __topClear();
       G=null; keys={}; __hubEnter();
       if(state!=='hub') return 'SKIP: staging: not on the Undercroft floor (state '+state+')';
       snap=netUpSnapP();
       if(pn) pn.value='';
       netSend=function(){ return true; }; netRefresh=function(){}; netUpFpSame=function(a){ return !!a; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}]; NET.specG=null; NET.upHold=false;
       P.kit=[]; P.hotAssign={}; P.freeKit=0; P.kitChosen=0; P.dropKit=[];
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: staging: the Undercroft backpack did not open';
       hubBagG.bag=mark.slice(); hubBagG.hotAssign={0:'bandage'};
       togglePauseBox(true);
       if(!pauseOpen||!pb.classList.contains('on')) return 'SKIP: staging: the pause box did not open on the Undercroft floor';
       r=netUpStart({t:'up',seed:4242,mapIx:0,cond:'day',fp:{e:0}});
       if(r!=='up'||!G||state!=='raid') return 'SKIP: staging: the host word did not carry this window up ('+r+')';
       if(pauseOpen||pb.classList.contains('on')) bad.push('the pause box opened on the Undercroft floor stayed open over the raid start');
       if(hubBagOpen||hubBagG) bad.push('the Undercroft backpack went up into the raid still open, unseen');
       G.bagOpen=true; s0=JSON.stringify([P.kit||[],P.hotAssign||{}]);
       backOut();
       if(G.bagOpen) bad.push('the first B in the raid did not shut the raid backpack');
       if(JSON.stringify([P.kit||[],P.hotAssign||{}])!==s0) bad.push('the first B in the raid saved the old Undercroft packing over the loadout ('+JSON.stringify(P.kit||[])+')');
     } finally {
       try{ if(G) G.bagOpen=false; }catch(e){}
       try{ hubBagOpen=false; hubBagG=null; }catch(e){}
       try{ NET.on=false; if(G&&!G.over) __endRaid('abandon'); }catch(e){}
       try{ if(pauseOpen||pb.classList.contains('on')) togglePauseBox(false); }catch(e){}
       netSend=oSend; netRefresh=oRef; netUpFpSame=oSame;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nk,k)) delete NET[k];
       for(k in nk) NET[k]=nk[k];
       try{ if(pn) pn.value=pn0; }catch(e){}
       try{ if(snap){ netUpPutP(snap); saveProfile(); } }catch(e){}
       try{ __topClear(); }catch(e){}
       G=g0; state=st0; keys=k0; mouse.down=md0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
