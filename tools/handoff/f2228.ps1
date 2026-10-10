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

if ($s.Contains("  {v:'22.28',what:")) { throw "check 22.28 is in the fixture already" }

SubRx @'
  {v:'22.27',what:
'@ @'
  {v:'22.28',what:'a loaner Bandage a teammate cannot take comes back a loaner: the aid word and the word back carry the loaner mark on every leg, the host passes it on, and the Bandage kept goes back on the issued count while a found one stays found',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netAidFinish!=='function'||typeof netAidTake!=='function'||typeof netAidBackTake!=='function'||typeof netAidKept!=='function'||typeof trackIssuedBandages!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, oShown=netUpShown, oGone=netUpGone, sent=[], g, p, i0, c0, r, w;
     function bc(){ var n=0, j; for(j=0;j<g.bag.length;j++) if(g.bag[j]==='bandage') n++; return n; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.downed=false; p.dying=false;
       netSend=function(q,m){ sent.push({to:q?q.seat:-1,m:JSON.parse(JSON.stringify(m))}); return true; };
       netUpShown=function(u){ return !!u; }; netUpGone=function(){ return false; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       NET.up=[{seat:0,x:p.x,y:p.y,dn:0,hp:60,mh:100}];
       sent=[]; netAidFinish({aid:0,key:'bandage',issB:1,kind:'heal'});
       w=sent.filter(function(s){ return s.m.t==='aid'; })[0];
       if(!w) bad.push('staging: no aid word went to the host');
       else if(w.m.ib!==1) bad.push('the aid word for a loaner Bandage carries no loaner mark');
       g.issuedBandages=1; c0=bc(); g.bandSeen=c0; i0=g.issuedBandages;
       r=netAidBackTake({seat:0,state:'in'},{t:'aidx',s:1,f:0,k:'bandage',w:'full',ib:1});
       if(r!=='kept') bad.push('staging: the word back said '+r);
       trackIssuedBandages();
       if(bc()!==c0+1) bad.push('the refused Bandage did not come back to the backpack');
       if(g.issuedBandages!==i0+1) bad.push('a loaner Bandage the teammate refused came back as a found one ('+i0+' issued before, '+g.issuedBandages+' after), so the extraction banks it');
       i0=g.issuedBandages; c0=bc(); g.bandSeen=c0;
       netAidBackTake({seat:0,state:'in'},{t:'aidx',s:1,f:0,k:'bandage',w:'full',ib:0}); trackIssuedBandages();
       if(g.issuedBandages!==i0) bad.push('a found Bandage refused came back as a loaner');
       p.hp=p.maxhp||100; p.healQ=0; p.prep=null; sent=[];
       r=netAidTake({seat:0,state:'in'},{t:'aid',s:1,by:0,k:'bandage',ib:1});
       w=sent.filter(function(s){ return s.m.t==='aidx'; })[0];
       if(r!=='full'||!w) bad.push('staging: a player at full health did not send the Bandage back ('+r+')');
       else if(w.m.ib!==1) bad.push('the word back for a refused loaner Bandage carries no loaner mark');
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'},{seat:2,state:'in'}]; sent=[];
       netAidTake({seat:2,state:'in'},{t:'aid',s:1,k:'bandage',ib:1});
       w=sent.filter(function(s){ return s.m.t==='aid'&&s.to===1; })[0];
       if(!w) bad.push('staging: the host passed no aid word on');
       else if(w.m.ib!==1) bad.push('the host passed the aid word on without the loaner mark');
       sent=[];
       netAidBackTake({seat:1,state:'in'},{t:'aidx',s:2,f:1,k:'bandage',w:'full',ib:1});
       w=sent.filter(function(s){ return s.m.t==='aidx'&&s.to===2; })[0];
       if(!w) bad.push('staging: the host passed no word back on');
       else if(w.m.ib!==1) bad.push('the host passed the word back on without the loaner mark');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netUpShown=oShown; netUpGone=oGone;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
