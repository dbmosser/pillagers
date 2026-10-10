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

if ($s.Contains("  {v:'22.27',what:")) { throw "check 22.27 is in the fixture already" }

SubRx @'
  {v:'22.26',what:
'@ @'
  {v:'22.27',what:'the raid a host keeps for his party reads the Terms it was built with: Terms he signs or drops on the floor meanwhile are for his next run only',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netSpecStart!=='function'||typeof hasTerm!=='function'||typeof toggleTerm!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, oShown=netUpShown, oSave=saveProfile, g=null, ok;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       P.terms=['silence'];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       netSend=function(){ return true; }; netUpShown=function(u){ return !!u; }; saveProfile=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.upSeed=g.seed>>>0; NET.specG=null; NET.specTick=false; NET.upOut={};
       NET.peers=[{seat:1,state:'in'}]; NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQK MATE'}];
       NET.up=[{seat:1,n:1,age:0,sd:g.seed>>>0,tx:g.player.x,ty:g.player.y,tf:0,dn:0}];
       ok=netSpecStart('extract');
       if(!ok||NET.specG!==g) return 'SKIP: staging: the raid was not kept for the party';
       g.over='extract'; G=null;   // past his run card: he is on the floor and the raid runs on for player 2
       toggleTerm('silence'); toggleTerm('known');
       if(!(P.terms.indexOf('known')>=0&&P.terms.indexOf('silence')<0)) bad.push('on the floor the host next run Terms read '+JSON.stringify(P.terms));
       G=g;   // as netSpecTick runs the kept raid
       if(hasTerm('known')) bad.push('THEY KNOW YOU, signed on the floor after the host was out, is live in the raid kept for player 2');
       if(!hasTerm('silence')) bad.push('SILENT RUNNING, which the raid was built with, went off in the raid kept for player 2 when the host dropped it on the floor');
       NET.specG=null;
       if(!hasTerm('known')||hasTerm('silence')) bad.push('once no raid is kept, a raid that is over does not read the host own list');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netUpShown=oShown; saveProfile=oSave;
       try{ if(g){ G=g; G.over=false; } }catch(_o){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; G.player.specOut=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
