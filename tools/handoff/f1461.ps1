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
  {v:'14.60',what:
'@ @'
  {v:'14.61',what:'a click that slips off a belt key does not unbind it: a belt item drag released off the belt 10 units from its press point keeps its key, while one released 200 units away unbinds it (backpack audit finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mouse==='undefined') return 'SKIP: no mouse state in this build';
     var bad=[], g0=null, _sp=saveProfile, _say=(typeof say==='function')?say:null;
     var release=function(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g; saveProfile=function(){};
       var prof=__P();
       var stage=function(mx,my){ g.bagOpen=false; g.hotCells=[]; g.bagPanel=null; g.hotAssign={4:'medkit'}; prof.hotAssign={4:'medkit'}; g.drag={key:'medkit',fromHot:4,px:300,py:300}; mouse.x=mx; mouse.y=my; release(); };
       // CONTROL: released 200 units from the press point, off the belt, the key is unbound.
       stage(500,300);
       if(g.hotAssign[4]==='medkit') return 'SKIP: a belt drag released far off the belt did not unbind the key here, so an unbind cannot be seen';
       // THE FIX: released 10 units from the press point, the click keeps the key.
       stage(308,306);
       if(g.hotAssign[4]!=='medkit'||!prof.hotAssign||prof.hotAssign[4]!=='medkit') bad.push('a click on belt key 5 that slipped 10 units before release unbound the Medkit and saved the plan without it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp;
       try{ if(g0){ g0.drag=null; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
