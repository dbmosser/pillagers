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
  {v:'14.85',what:
'@ @'
  {v:'14.86',what:'a drag on the belt in a raid keeps the keys for what stayed home: deployed with key 7 on a Stim left at home, unbinding a Medkit key mid-raid saves a plan that still has the Stim on key 7 (belt audit finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mouse==='undefined'||!ITEMS.stim||!ITEMS.medkit) return 'SKIP: no mouse state or items in this build';
     var bad=[], g0=null, _sp=saveProfile;
     var release=function(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var prof=__P(); prof.hotAssign={6:'stim'};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g; saveProfile=function(){};
       prof=__P();
       // CONTROL: the raid's copy let go of the key on the Stim that stayed home.
       if(g.hotAssign&&g.hotAssign[6]==='stim') return 'SKIP: the raid kept a key on a Stim it did not carry, so nothing was set aside';
       g.bagOpen=false; g.hotCells=[]; g.bagPanel=null;
       g.hotAssign=g.hotAssign||{}; g.hotAssign[4]='medkit';
       g.drag={key:'medkit',fromHot:4,px:300,py:300}; mouse.x=500; mouse.y=300; release();
       if(g.hotAssign[4]==='medkit') return 'SKIP: the drag off the belt did not unbind the Medkit key here';
       if(!prof.hotAssign||prof.hotAssign[6]!=='stim') bad.push('unbinding a key mid-raid saved his plan without key 7 on the Stim he left at home ('+JSON.stringify(prof.hotAssign)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp;
       try{ if(g0){ g0.drag=null; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
