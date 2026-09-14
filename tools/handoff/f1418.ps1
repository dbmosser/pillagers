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
  {v:'14.17',what:
'@ @'
  {v:'14.18',what:'an armoury gun dropped on the stash grid goes into the stash: a spare owned gun leaves the armoury for the stash as its item form with a line said, and the gun in his hands stays in the armoury and says why (Undercroft audit finding 5)',
   run:function(){
     if(typeof rackToStash!=='function') return 'SKIP: no armoury drag in this build';
     var zone=document.getElementById('stashgrid');
     if(!zone) return 'SKIP: no stash grid in this document';
     var bad=[], got=[], _s2=say2, prof;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); __station('stash'); }catch(_h){}
       try{ renderHub(); }catch(_r){}
       if(typeof zone.__grabDrop!=='function') return 'SKIP: the stash grid is not a drop zone here (no __grabDrop)';
       prof.weapons=prof.weapons||[]; prof.stash=prof.stash||[];
       // A spare gun: an item form exists, and it is in neither hand.
       var gk=null;
       for(var k in ITEMS){ if(k.indexOf('gun_')!==0) continue; var g=k.slice(4); if(g!=='fists'&&g!==prof.equipped&&g!==prof.equippedSec){ gk=k; break; } }
       if(!gk) return 'SKIP: no spare gun item form to drag';
       var g0=gk.slice(4);
       prof.weapons=prof.weapons.filter(function(w){ return w!==g0; }); prof.weapons.push(g0);
       prof.stash=prof.stash.filter(function(x){ return x!==gk; });
       say2=function(t){ got.push(String(t)); };
       // ARM 1, THE FIX: the spare gun moves.
       zone.__grabDrop(gk,'rack');
       if(prof.weapons.indexOf(g0)>=0) bad.push('the '+g0+' dropped on the stash grid is still in the armoury');
       if(prof.stash.indexOf(gk)<0) bad.push('the '+g0+' dropped on the stash grid is not in the stash');
       if(!got.length) bad.push('the drop of an armoury gun on the stash grid said nothing');
       // ARM 2: the gun in his hands stays in the armoury and the drop says why.
       var eq=prof.equipped; got.length=0;
       if(eq&&eq!=='fists'&&ITEMS['gun_'+eq]){
         if(prof.weapons.indexOf(eq)<0) prof.weapons.push(eq);
         zone.__grabDrop('gun_'+eq,'rack');
         if(prof.stash.indexOf('gun_'+eq)>=0) bad.push('the gun in his hands went into the stash');
         if(prof.weapons.indexOf(eq)<0) bad.push('the gun in his hands left the armoury');
         if(!got.length) bad.push('dropping the gun in his hands on the stash grid said nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say2=_s2; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'14.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
