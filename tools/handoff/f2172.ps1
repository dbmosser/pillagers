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

if ($s.Contains("  {v:'21.72',what:")) { throw "check 21.72 is in the fixture already" }

SubRx @'
  {v:'21.71',what:
'@ @'
  {v:'21.72',what:'in co-op a Peddler sale is told across the party: a row player 2 buys reads SOLD on the host (so it cannot be bought twice or drop again from the PEDLAR STOCK cache), and a row the host buys reads SOLD for player 2',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof pedBuy!=='function'||typeof netOnMsg!=='function'||typeof netEntsInit!=='function') return 'SKIP: no raid, stall or party in this fixture';
     var NK={}, k, bad=[], oSend=netSend, oSay=say, sent=[], ped=null, i, a=-1, b=-1, W, p0={seat:0,state:'in'}, p1={seat:1,state:'in'}, p2={seat:2,state:'in'}, cr0=P.credits, nm;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       for(i=0;i<G.ents.length;i++) if(G.ents[i].kind==='peddler'){ ped=G.ents[i]; break; }
       if(!ped||!Array.isArray(ped.stock)) return 'SKIP: staging: no Peddler in this raid';
       for(i=0;i<ped.stock.length;i++){ var it=ITEMS[ped.stock[i].k]; if(!it||it.use==='ammo'||ped.stock[i].sold) continue; if(a<0) a=i; else if(b<0){ b=i; break; } }
       if(a<0||b<0) return 'SKIP: staging: fewer than two stall rows to buy';
       say=function(){}; netSend=function(q,m){ sent.push({q:q,m:JSON.parse(JSON.stringify(m))}); return true; };
       P.credits=987654; G.bag=[]; G.player.downed=false;
       NET.on=true; NET.max=4; NET.upSeed=G.seed>>>0; NET.specG=null; netEntsInit(G);
       NET.role='join'; NET.seat=1; NET.peers=[p0];
       G.trade=ped; sent=[]; pedBuy(a);
       if(!ped.stock[a].sold) return 'SKIP: staging: player 2 could not buy the row';
       nm=ITEMS[ped.stock[a].k].name;
       W=sent.filter(function(s){ return s.q===p0; }).map(function(s){ return s.m; });
       if(!W.length) bad.push('player 2 bought the '+nm+' and the host was told nothing');
       ped.stock[a].sold=false; G.trade=null;
       NET.role='host'; NET.seat=0; NET.peers=[p1,p2]; sent=[];
       for(i=0;i<W.length;i++) netOnMsg(p1,JSON.stringify(W[i]));
       if(!ped.stock[a].sold) bad.push('the host still sells the '+nm+' player 2 bought, so it can be bought twice and drops again from the PEDLAR STOCK cache');
       else if(!sent.some(function(s){ return s.q===p2; })) bad.push('the host did not pass the sale on to the rest of the party');
       G.trade=ped; sent=[]; pedBuy(b);
       if(!ped.stock[b].sold) return 'SKIP: staging: the host could not buy the row';
       nm=ITEMS[ped.stock[b].k].name;
       W=sent.filter(function(s){ return s.q===p1; }).map(function(s){ return s.m; });
       ped.stock[b].sold=false; G.trade=null;
       NET.role='join'; NET.seat=1; NET.peers=[p0]; sent=[];
       for(i=0;i<W.length;i++) netOnMsg(p0,JSON.stringify(W[i]));
       if(!ped.stock[b].sold) bad.push('the '+nm+' the host bought still shows for sale to player 2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay;
       try{ if(G) G.trade=null; }catch(_t){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P.credits=cr0; saveProfile(); }catch(_c){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
