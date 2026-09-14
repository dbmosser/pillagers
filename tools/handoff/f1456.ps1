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
  {v:'14.55',what:
'@ @'
  {v:'14.56',what:'a drag held when the raid ends writes nothing: a belt item released off the belt in a live raid unbinds it in the plan, and the same release after the raid has ended leaves the emptied plan alone (backpack audit finding 1)',
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
       // CONTROL: in a live raid, belt key 4 dragged off the belt and let go unbinds it in the plan.
       g.bagOpen=false; g.hotCells=[]; g.bagPanel=null;
       g.hotAssign={3:'medkit',5:'frag'}; prof.hotAssign={3:'medkit',5:'frag'};
       g.drag={key:'medkit',fromHot:3}; mouse.x=5; mouse.y=5;
       release();
       if(g.drag) return 'SKIP: the release did not reach the raid drag here';
       if(prof.hotAssign&&prof.hotAssign[3]==='medkit') return 'SKIP: releasing a belt drag off the belt did not unbind it in the plan here, so a write cannot be seen';
       // THE FIX: the raid has ended and the plan was emptied; the same drag is released on the outcome card.
       g.hotAssign={3:'medkit',5:'frag'}; prof.hotAssign={};
       g.drag={key:'medkit',fromHot:3}; g.over='dead';
       release();
       var keys=Object.keys(prof.hotAssign||{});
       if(keys.length) bad.push('a belt drag released after the raid ended wrote '+keys.length+' key'+(keys.length>1?'s':'')+' back into the emptied plan ('+JSON.stringify(prof.hotAssign)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp;
       try{ if(g0){ g0.drag=null; if(g0.over==='dead'&&!g0.tel) g0.over=false; } }catch(_d){}
       try{ var g3=__state(); if(g3&&g3===g0){ g3.over=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
