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

if ($s.Contains("  {v:'17.22',what:")) { throw "check 17.22 is in the fixture already" }

SubRx @'
  {v:'17.21',what:
'@ @'
  {v:'17.22',what:'a teammate who hired a man and then went up on a party raid keeps his own hire when that raid ends: it carried the host hire, so his own is not settled, left out there or spent',
   run:function(){
     if(typeof netUpStart!=='function'||typeof netUpFpSame!=='function'||typeof NET!=='object'||!NET||!window.__endRaid||!window.__hubEnter||!window.__applyLoaded||!window.__identityIds||!window.__P) return 'SKIP: this build has no party ascent';
     var ids=__identityIds(); if(ids.length<2) return 'SKIP: fewer than two identities to hire';
     var nk={}, k, snap=null, g0=G, st0=state, k0=keys, oSend=netSend, oRef=netRefresh, oSame=netUpFpSame, bad=[], r, i, host=null, mine=null;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nk[k]=NET[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; keys={}; __hubEnter();
       if(state!=='hub') return 'SKIP: staging: not on the Undercroft floor (state '+state+')';
       snap=JSON.parse(JSON.stringify(__P()));
       netSend=function(){ return true; }; netRefresh=function(){}; netUpFpSame=function(a){ return !!a; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}]; NET.specG=null; NET.upHold=false;
       P.kit=[]; P.hotAssign={}; P.freeKit=0; P.kitChosen=0; P.dropKit=[];
       P.merc=ids[1]; P.credits=77777;
       r=netUpStart({t:'up',seed:4242,mapIx:0,cond:'day',fp:{e:0},merc:ids[0]});
       if(r!=='up'||!G||state!=='raid') return 'SKIP: staging: the host word did not carry this window up ('+r+')';
       for(i=0;i<G.ents.length;i++){ var e=G.ents[i]; if(e.merc){ if(e.ident===ids[0]) host=e; else mine=e; } }
       if(!host) return 'SKIP: staging: the host hire did not drop into the party raid';
       if(mine) bad.push('control: the teammate own hire dropped into the party raid too');
       if(P.merc!==ids[1]) return 'SKIP: staging: the build did not put the teammate own hire back ('+P.merc+')';
       G.tel.distance=100; G.tel.shots=1;
       NET.on=false;
       __endRaid('abandon');
       if(P.merc!==ids[1]) bad.push('a party raid that carried the host hire spent the teammate own paid hire ('+ids[1]+' became '+P.merc+'), so his fee is gone for a man who never went up');
     } finally {
       try{ NET.on=false; if(G&&!G.over) __endRaid('abandon'); }catch(e1){}
       netSend=oSend; netRefresh=oRef; netUpFpSame=oSame;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nk,k)) delete NET[k];
       for(k in nk) NET[k]=nk[k];
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(e2){}
       G=g0; state=st0; keys=k0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
