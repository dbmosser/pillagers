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

if ($s.Contains("  {v:'21.71',what:")) { throw "check 21.71 is in the fixture already" }

SubRx @'
  {v:'21.70',what:
'@ @'
  {v:'21.71',what:'in co-op an item player 2 lets go over the host hire is never lost into his copy of that hire: it drops as a pile the host makes, or stays in his backpack',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__identityIds||typeof NET!=='object'||!NET||typeof netEntsPeer!=='function'||typeof w2s!=='function'||typeof mouse!=='object') return 'SKIP: no raid, hire or party in this fixture';
     var ids=__identityIds(), NK={}, k, bad=[], M=null, i, oSend=netSend, oSay=say, sent=[], b0, h0, hc0, bp0, s, mx0=mouse.x, my0=mouse.y, m0=P.merc, mo0=P.mercOut, staged=false;
     function cnt(a){ var n=0, j; for(j=0;j<(a||[]).length;j++) if(a[j]==='medkit') n++; return n; }
     if(!ids.length) return 'SKIP: no man to hire';
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       P.merc=ids[0];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       for(i=0;i<G.ents.length;i++){ var e=G.ents[i]; if(e.kind==='raider'&&e.merc&&!e.downed){ M=e; break; } }
       if(!M) return 'SKIP: staging: the hire did not come up';
       say=function(){}; netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=G.seed>>>0; NET.specG=null;
       if(!netEntsPeer()) return 'SKIP: staging: this window is not linked';
       M.x=G.player.x+60; M.y=G.player.y; M.bag=M.bag||[];
       G.bag.push('medkit'); b0=cnt(G.bag); h0=cnt(M.bag);
       hc0=G.hotCells; bp0=G.bagPanel; staged=true;
       G.hotCells=[]; G.bagPanel={x:-9000,y:-9000,w:1,h:1};
       s=w2s(M.x,0,M.y); mouse.x=s.x; mouse.y=s.y;
       G.drag={key:'medkit',bagIx:G.bag.length-1,px:s.x+200,py:s.y};
       window.dispatchEvent(new MouseEvent('mouseup',{button:0}));
       if(G.drag) return 'SKIP: staging: the release was not taken';
       var toHire=cnt(M.bag)-h0, kept=(cnt(G.bag)===b0), piled=sent.some(function(m){ return m&&m.t==='pile'&&m.k==='medkit'; });
       if(toHire>0) bad.push('the Medkit went into the copy of the host hire on player 2 window, which the host never sees');
       if(!kept&&!piled) bad.push('the Medkit left the backpack with no pile asked of the host, so it is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; say=oSay; mouse.x=mx0; mouse.y=my0;
       try{ if(G){ G.drag=null; if(staged){ G.hotCells=hc0; G.bagPanel=bp0; } } }catch(_h){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P.merc=m0; if(mo0===undefined) delete P.mercOut; else P.mercOut=mo0; saveProfile(); }catch(_m){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
