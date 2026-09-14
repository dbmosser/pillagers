$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.94',what:
'@ @'
  {v:'13.95',what:'a Stray clearing your notoriety clears its fade count: helped at notoriety 1 with three extractions counted, both go to zero, while at notoriety 2 the count keeps running (contracts, notoriety and waves audit 2026-09-14, finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkStray!=='function'||typeof strayGive!=='function') return 'SKIP: no Stray in this build';
     var bad=[], P2=__P(), keep={no:P2.notoriety,ne:P2.notExt,cr:P2.credits};
     function help(noto){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       g.ents.length=0; g.hotAssign={}; p.downed=false; p.iv=99;
       var e=mkStray(p.x+20,p.y); e.found=1; g.ents.push(e);
       if(e.want==='ammobox'){ g.bag=[]; p.reserve=400; } else g.bag=[e.want];
       P2.notoriety=noto; P2.notExt=3;
       strayGive(e);
       return {helped:!!e.helped, noto:P2.notoriety, ext:P2.notExt};
     }
     try{
       // THE FINDING: the Stray clears the last point with three extractions counted.
       var A=help(1);
       if(A===null) return 'SKIP: no live raid';
       if(!A.helped) return 'SKIP: the Stray would not take what he asked for';
       if(A.noto!==0) return 'SKIP: helping the Stray did not clear notoriety 1 in this build';
       if(A.ext!==0) bad.push('the Stray cleared the last point of notoriety and left '+A.ext+' extractions counted toward the next fade');
       // CONTROL: at notoriety 2 the count keeps running.
       var B=help(2);
       if(B&&B.helped&&(B.noto!==1||B.ext!==3)) bad.push('control: at notoriety 2 the Stray left notoriety '+B.noto+' and count '+B.ext+', not 1 and 3');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.notoriety=keep.no; P2.notExt=keep.ne; P2.credits=keep.cr; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
