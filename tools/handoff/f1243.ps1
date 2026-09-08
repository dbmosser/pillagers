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

# v12.43 CHECK, inserted before the v12.42 entry. The born profile is only
# reachable at file scope, so the check reads it out of the running page and then
# drives the REAL loader with it, rather than asserting on the text: what it
# proves is that the save a brand new player writes survives his own second load,
# which is the thing he loses. Every needle is assembled, because a check that
# writes the phrase it is looking for finds itself, which happened three times in
# two builds. The control loads a save that genuinely predates the fold and
# requires the fold to still happen, so a green arm cannot mean the migration was
# simply deleted.
SubRx @'
  {v:'12.42',what:'a gun that goes through the backpack keeps its magazine: loaded plus reserve is conserved across a stow and an equip, on a full gun and on an empty one, so stowing no longer throws the load away and re-equipping no longer conjures half a magazine, while a gun found in the field still arrives on half a magazine (2026-09-07 audit)',
'@ @'
  {v:'12.43',what:'a profile this build creates is born already migrated: the save a brand new player writes after one session on the second sector comes back from his own second load with the seal record and the explored map still on it, while a save that genuinely predates the one-map fold is still folded exactly as it was (2026-09-08 first-hour audit)',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot drive the loader synchronously';
     var bad=[], keep=null;
     try{
       __topClear(); __runPrep();
       keep=JSON.parse(JSON.stringify(__P()));
       // The literal a new profile is born from lives at file scope and nothing
       // returns it, so it is read out of the page and evaluated. The needle is
       // built here rather than written, or it would match this check.
       var SRC='', sc=document.getElementsByTagName('script'), i;
       for(i=0;i<sc.length;i++) SRC+=(sc[i].textContent||'');
       var NEED='var '+'P='+'{'+'cre'+'dits:';
       var a=SRC.indexOf(NEED);
       if(a<0) return 'SKIP: the born profile is not in this page';
       var lo=a+NEED.indexOf('{');
       var hi=SRC.indexOf('}'+';',lo);
       if(hi<0) return 'SKIP: the born profile has no end in this page';
       var born=null;
       try{ born=(new Function('return '+SRC.slice(lo,hi+1)))(); }catch(_b){ born=null; }
       if(!born||typeof born.credits!=='number') return 'SKIP: the born profile did not read back as a profile';
       // ONE SESSION ON THE SECOND SECTOR. The seal record and the explored
       // bitmap are both stored under the sector index, and the fog is banked at
       // the end of every raid whatever the outcome, so this is what his profile
       // holds when he closes the tab on day one.
       born.seals={}; born.seals['1']={cut:25,tot:40};
       born.mapSeen={}; born.mapSeen['1']='what he walked on the mile';
       if(!(born.seals['1']&&born.mapSeen['1'])) return 'SKIP: the first session could not be staged';
       var hadStamp=!!born.mig739;
       // HIS SECOND LOAD, through the real loader.
       __applyLoaded(born);
       var P2=__P();
       if(!(P2.seals&&P2.seals['1']))
         bad.push('the cutting he did at the great door on the second sector was deleted by his own second load, and the run report had told him it was banked'+(hadStamp?'':': the profile he was born with carries no stamp for the one-map fold, so a repair meant for old saves ran once on his brand new one'));
       if(!(P2.mapSeen&&P2.mapSeen['1']))
         bad.push('the map he explored on the second sector was deleted by his own second load, which happens on any outcome because the fog is banked at the end of every raid');
       // CONTROL: a save that really is older than the fold must still be folded,
       // or a green arm above would only mean the migration had been removed.
       var old=(new Function('return '+SRC.slice(lo,hi+1)))();
       delete old.mig739;
       old.seals={}; old.seals['2']={cut:11,tot:40};
       old.mapSeen={}; old.mapSeen['2']='an old two-map save';
       __applyLoaded(old);
       var P3=__P();
       if(!(P3.seals&&P3.seals['0']&&P3.seals['0'].cut===11))
         bad.push('control: a save from before the one-map fold was not folded, so its cutting did not move down to the sector that survived');
       if(P3.seals&&P3.seals['2'])
         bad.push('control: a save from before the one-map fold kept its third sector record, so the fold did not run at all');
       if(!P3.mig739)
         bad.push('control: a save from before the one-map fold was not stamped afterwards, so it would be folded again on every load');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(keep) __applyLoaded(keep); saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.42',what:'a gun that goes through the backpack keeps its magazine: loaded plus reserve is conserved across a stow and an equip, on a full gun and on an empty one, so stowing no longer throws the load away and re-equipping no longer conjures half a magazine, while a gun found in the field still arrives on half a magazine (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
