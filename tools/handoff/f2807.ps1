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

if ($s.Contains("  {v:'28.07',what:")) { throw "check 28.07 is in the fixture already" }

SubRx @'
  {v:'28.06',what:
'@ @'
  {v:'28.07',what:'cloud review finding 4: the explosive barrels are laid the same whatever the player stands, a barrel lit in one window is told to the others (and passed on by the host), a told barrel runs its fuse and goes up, a word for a barrel already lit or one that is not there is dropped',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof brlPlace!=='function') return 'SKIP: no barrels here';
     if(typeof brlNetTake!=='function'||typeof brlNetOut!=='function') return 'there is no barrel net word in this build';
     var bad=[], g=null, p=null, i, pos1, pos2, B, B2, B3, B4, r, sent=[], oUp=netUpShared, oSend=netSend, peers0=NET.peers, role0=NET.role, pa={state:'in'}, pb={state:'in'};
     function pos(){ var a=[], q; for(q=0;q<g.brl.length;q++) a.push(Math.round(g.brl[q].x)+','+Math.round(g.brl[q].y)); return a.join(';'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!Array.isArray(g.brl)||g.brl.length<4) return 'SKIP: staging: no barrels';
       p.iv=99; g.ents.length=0;
       pos1=pos();
       p.x=140; p.y=140; brlPlace(g); pos2=pos();
       if(pos1!==pos2) bad.push('the barrels laid with the player somewhere else are not the same set');
       p.x=g.map.spawns[0].x; p.y=g.map.spawns[0].y;
       netUpShared=function(){ return true; }; netSend=function(pe,m){ sent.push({to:pe,m:m}); return true; };
       NET.peers=[pa,pb]; NET.role='join';
       B=g.brl[0]; r=brlLight(B,0,0.2);
       if(!r||!sent.length||sent[0].m.t!=='brl'||sent[0].m.i!==B.id||sent[0].m.by!==0) bad.push('lighting a barrel here sent no barrel word naming it and the seat ('+JSON.stringify(sent[0]&&sent[0].m)+')');
       sent.length=0;
       B2=g.brl[1]; r=brlNetTake(pa,{t:'brl',i:B2.id,by:1,f:0.2});
       if(r!=='brl'||!(B2.fuse>=0)||B2.by!==1) bad.push('a barrel word did not light the barrel ('+r+', fuse '+B2.fuse+', by '+B2.by+')');
       if(sent.length) bad.push('a joined window passed a barrel word on ('+sent.length+' sent)');
       r=brlNetTake(pa,{t:'brl',i:B2.id,by:1,f:0.2});
       if(r!=='dup') bad.push('a word for a barrel already lit answered '+r+', not dup');
       r=brlNetTake(pa,{t:'brl',i:99999,by:1,f:0.2});
       if(r!=='gone') bad.push('a word for a barrel that is not there answered '+r+', not gone');
       NET.role='host'; sent.length=0;
       B3=g.brl[2]; r=brlNetTake(pa,{t:'brl',i:B3.id,by:1,f:0.2});
       if(r!=='brl'||!(B3.fuse>=0)) bad.push('the host did not light a barrel from a word ('+r+')');
       if(sent.length!==1||sent[0].to!==pb||sent[0].m.i!==B3.id) bad.push('the host did not pass the word on to the other window only ('+sent.length+' sent)');
       sent.length=0; B4=g.brl[3];
       r=brlNetTake(pa,{t:'brl',i:B4.id,by:'x',f:'y'});
       if(r!=='brl'||B4.by!==-1) bad.push('a word with a strange seat and fuse was not tamed ('+r+', by '+B4.by+')');
       NET.role='join'; sent.length=0;
       for(i=0;i<30;i++) brlTick(0.05);
       if(!B2.gone||!B3.gone) bad.push('barrels lit by word did not go up after their fuse');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       netUpShared=oUp; netSend=oSend; NET.peers=peers0; NET.role=role0;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'28.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
