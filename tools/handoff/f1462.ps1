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
  {v:'14.61',what:
'@ @'
  {v:'14.62',what:'a drag whose item has left the backpack binds nothing: a Medkit tile dragged onto belt key 6 binds it while the Medkit is carried, and binds nothing once the Medkit is gone from the backpack (backpack audit finding 7)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mouse==='undefined') return 'SKIP: no mouse state in this build';
     var bad=[], g0=null, _sp=saveProfile;
     var release=function(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g; saveProfile=function(){};
       var prof=__P();
       var stage=function(bag){ g.bagOpen=true; g.bag=bag; g.hotAssign={}; prof.hotAssign={}; g.hotCells=[{i:5,x:100,y:900,w:40,h:40}]; g.drag={key:'medkit',bagIx:0}; mouse.x=120; mouse.y=920; release(); };
       // CONTROL: with the Medkit carried, the drag binds belt key 6.
       stage(['medkit']);
       if(g.hotAssign[5]!=='medkit') return 'SKIP: a backpack drag released over a staged belt cell did not bind it here, so a bind cannot be seen';
       // THE FIX: the Medkit has been dropped; the same release binds nothing.
       stage([]);
       if(g.hotAssign[5]!==undefined||(prof.hotAssign&&prof.hotAssign[5]!==undefined)) bad.push('a drag whose Medkit had already been dropped bound belt key 6 to an item no longer carried');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp;
       try{ if(g0){ g0.drag=null; g0.bagOpen=false; g0.bag=[]; g0.hotCells=[]; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
