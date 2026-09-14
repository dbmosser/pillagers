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
  {v:'14.68',what:
'@ @'
  {v:'14.69',what:'a restore code replaces the clothes, the saved looks and the all cosmetics flag: a code made from a character who never dressed, applied over one with a hat, saved looks and the flag on, leaves no hat, no saved look and the flag off (wardrobe audit finding 2)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreApply!=='function'||typeof COSKEY==='undefined'||!window.__applyLoaded) return 'SKIP: no restore codes in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var prof=__P();
       // Character B never dressed. Its code is taken now.
       for(var k0 in COSKEY) prof[COSKEY[k0]]=null;
       var code=restoreMake();
       // Character A: a hat, two saved looks and every rack unlocked.
       var hat=null; for(var i=0;i<COSMETICS.length;i++) if(COSMETICS[i].kind==='hat'&&COSMETICS[i].id!=='none'){ hat=COSMETICS[i].id; break; }
       if(!hat) return 'SKIP: no hat to wear';
       prof[COSKEY.hat]=hat; prof.looks=[{hat:hat},{hat:hat},null]; prof.cosAll=true;
       var ok=restoreApply(code);
       // CONTROL: the code applied.
       if(ok===false) return 'SKIP: restoreApply refused a code made a moment ago';
       var q=__P();
       if(q[COSKEY.hat]===hat) bad.push('after the restore the character still wears the hat of the character it replaced');
       if((q.looks||[]).some(function(L){ return !!L; })) bad.push('after the restore the saved looks of the replaced character are still there');
       if(q.cosAll) bad.push('after the restore every rack is still unlocked by the flag of the replaced character');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
