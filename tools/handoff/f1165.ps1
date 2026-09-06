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

# v11.65 CHECK, inserted before the v11.64 entry.
SubRx @'
  {v:'11.64',what:'a tag and a note chosen after Copy report reach the run that Copy already logged when Log run and return is pressed afterwards, and the run is not logged twice',
'@ @'
  {v:'11.65',what:'the restore code carries the armoury (guns owned, the one in hand, the second slot, the wear on each) and applying it brings them back; a gun this build does not know is dropped',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     if(typeof restoreCode!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function') return 'SKIP: this build has no restore code';
     var bad=[], prof;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       // DISTINCTIVE: three guns no fresh profile owns, the marksman rifle in hand,
       // the magnum second, and worn figures nothing rolls.
       prof.weapons=['dmr','magnum','sniper']; prof.equipped='dmr'; prof.equippedSec='magnum'; prof.wear={dmr:137,magnum:41};
       var code=restoreCode();
       if(!code) bad.push('no restore code was made');
       var o=code?restoreRead(code):null;
       if(code&&!o) bad.push('the code cannot be read back');
       else if(o&&!o.g) bad.push('the code carries no armoury: three owned guns, the one in hand and their wear are not in it, while the card promises what you have unlocked');
       else if(o){
         // Wipe to a fresh armoury, then apply the code.
         prof.weapons=['pistol']; prof.equipped='pistol'; prof.equippedSec='none'; prof.wear={};
         var ok=restoreApply(o);
         if(!ok) bad.push('control: the code was refused');
         if((prof.weapons||[]).join(',')!=='dmr,magnum,sniper') bad.push('the guns came back as '+((prof.weapons||[]).join(',')||'nothing')+' and not dmr,magnum,sniper');
         if(prof.equipped!=='dmr') bad.push('the gun in hand came back as '+prof.equipped+' and not dmr');
         if((prof.equippedSec||'none')!=='magnum') bad.push('the second slot came back as '+(prof.equippedSec||'none')+' and not magnum');
         if(((prof.wear||{}).dmr|0)!==137) bad.push('the wear on the marksman rifle came back as '+((prof.wear||{}).dmr|0)+' and not 137');
         // CONTROL: a gun the build does not know is dropped, not restored.
         o.g.w.push('zqxgun'); restoreApply(o);
         if((prof.weapons||[]).indexOf('zqxgun')>=0) bad.push('control: a gun this build does not have was restored into the armoury');
         if((prof.weapons||[]).join(',')!=='dmr,magnum,sniper') bad.push('control: after the unknown gun the armoury reads '+(prof.weapons||[]).join(','));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.64',what:'a tag and a note chosen after Copy report reach the run that Copy already logged when Log run and return is pressed afterwards, and the run is not logged twice',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
