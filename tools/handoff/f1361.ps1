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
  {v:'13.60',what:
'@ @'
  {v:'13.61',what:'restoring a code replaces the whole save: the packed loadout, the belt keys, the saved packings and an armed Data Core are cleared along with the stash the code replaces (Undercroft audit 2026-09-14, finding 4)',
   run:function(){
     if(!window.__P||typeof restoreApply!=='function') return 'SKIP: no restore in this build';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[];
     try{
       __topClear(); __cleanProfile();
       P2.stash=['bandage','bandage']; P2.kit=['bandage']; P2.hotAssign={2:'bandage'};
       P2.kitSaved=['bandage']; P2.kitBeforeFree=['bandage']; P2.intel=1;
       var ok=restoreApply({v:1,n:'ZQXRESTORE61',c:4321,x:10,l:1,s:{scrap:3}});
       if(!ok) return 'SKIP: restoreApply refused the staged code';
       // CONTROL: the code did replace the stash.
       var sc=0; for(var i=0;i<P2.stash.length;i++) if(P2.stash[i]==='scrap') sc++;
       if(sc!==3||P2.stash.indexOf('bandage')>=0) bad.push('control: the restore did not replace the stash with the code (stash '+JSON.stringify(P2.stash)+')');
       if(P2.kit&&P2.kit.length) bad.push('the restored character kept the old loadout: '+JSON.stringify(P2.kit));
       if(P2.hotAssign&&Object.keys(P2.hotAssign).length) bad.push('the restored character kept the old belt keys: '+JSON.stringify(P2.hotAssign));
       if(P2.kitSaved) bad.push('the restored character kept the old saved packing');
       if(P2.kitBeforeFree) bad.push('the restored character kept the old packing from before the freebie kit');
       if(P2.intel) bad.push('the restored character kept intel armed from a core this save never spent');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var k; for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
