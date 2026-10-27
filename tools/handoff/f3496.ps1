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

if ($s.Contains("  {v:'34.96',what:")) { throw "check 34.96 is in the fixture already" }

SubRx @'
  {v:'34.95',what:
'@ @'
  {v:'34.96',what:'cw-p2nan, robot report p2:nan: a machine copy in the player 2 window whose spot went broken (not a number) snaps back to where the host last put it on the next frame; a copy at a good spot still eases toward the host spot instead of jumping',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netEntsEase!=='function'||typeof netEntMake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g, a, b, tx, ty;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0; NET.entMap={};
       tx=g.player.x+220; ty=g.player.y+40;
       a=netEntMake(953,'sentry',tx,ty); a.nIn=1; a.nT=1; a.ntx=tx; a.nty=ty; a.ntf=1.2; NET.entMap[953]=a; g.ents.push(a);
       b=netEntMake(954,'crawler',tx,ty+60); b.nIn=1; b.nT=1; b.ntx=tx; b.nty=ty+60; b.ntf=0; NET.entMap[954]=b; g.ents.push(b);
       a.x=NaN; a.y=NaN; a.face=NaN;
       b.x=tx-100;
       netEntsEase(1/60);
       if(g.ents.indexOf(a)<0) bad.push('the broken copy was taken off instead of put back');
       if(!isFinite(a.x)||!isFinite(a.y)) bad.push('the broken copy is still at a broken spot ('+a.x+', '+a.y+') after a frame');
       else if(Math.abs(a.x-tx)>1||Math.abs(a.y-ty)>1) bad.push('the broken copy came back at '+Math.round(a.x)+', '+Math.round(a.y)+', not the host spot '+Math.round(tx)+', '+Math.round(ty));
       if(!isFinite(a.face)) bad.push('the broken copy still faces a broken way');
       if(!(b.x>tx-99&&b.x<tx-50)) bad.push('a copy 100 px off its host spot moved to '+Math.round(b.x-tx)+' px in one frame (it should ease, not jump)');
       netEntsEase(1/60);
       if(!isFinite(a.x)||!isFinite(a.y)) bad.push('the broken copy went broken again on the next frame');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
