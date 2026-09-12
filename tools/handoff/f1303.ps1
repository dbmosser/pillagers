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

# v13.03 CHECK, inserted before the v13.02 entry.
#
# IT READS THE FLOOR AS DRAWN, through the recorder that keeps both halves of every
# canvas string: what the code asked for, and what was painted after his wording was
# applied. That pairing is the only way to see an edit that is not landing, because
# the raw string and the finished one are otherwise indistinguishable from outside.
#
# THE WARNING IS NOT WRITTEN INTO THIS ROW. It is found as the entry in his own baked
# map whose key is all asterisks and one word, so if he rewords it again the check
# follows him.
#
# THE CONTROL IS THAT THE SIGN IS STILL THERE. Making two spellings into one could
# have been done by deleting one of them, which would pass any test that only asked
# whether the wrong spelling was gone.
SubRx @'
  {v:'13.02',what:'no screen shows the original of a line he has rewritten
'@ @'
  {v:'13.03',what:'the experimental warning on the Undercroft floor is spelled the way the hire tab spells it, so the wording he gave that warning reaches both features rather than one (found sweeping his edits for v13.02)',
   run:function(){
     if(!(window.__tx&&window.__tx.record&&window.__tx.ship)) return 'SKIP: this fixture cannot record what the floor draws';
     if(!(window.__hubFrame&&window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot draw the Undercroft floor';
     var M=null; try{ M=__tx.ship(); }catch(_m){}
     if(!M) return 'SKIP: his baked edits are not readable here';
     // HIS OWN ENTRY: the key that is asterisks around a single word.
     var key=null,k;
     for(k in M) if(/^\*+[A-Za-z]+\*+$/.test(k)){ key=k; break; }
     if(!key) return 'SKIP: he has no baked edit for that warning, so there is nothing of his to split';
     var want=String(M[key]||'');
     var bad=[], H=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __showScreen('hub'); __hubEnter();
       try{ H=__tx.record(function(){ __hubFrame(0.016); })||[]; }catch(_r){}
       if(!H.length) return 'SKIP: the floor drew no text at all, so there is no sign here to read';
       // The sign, found by its shape rather than its spelling, so the wrong spelling
       // is still found and reported rather than quietly missed.
       var sign=null,i;
       for(i=0;i<H.length;i++) if(/^\*+[A-Za-z]+\*+$/.test(String(H[i].o))) { sign=H[i]; break; }
       if(!sign){
         bad.push('control: the Undercroft floor draws no experimental warning at all, so the two spellings were made one by deleting the sign rather than by spelling it the same way');
       } else if(String(sign.t)!==want){
         bad.push('the warning on the floor is drawn as ['+String(sign.t).slice(0,40)+'] where he rewrote that warning to say ['+want.slice(0,50)+']: the hire tab carries the same warning and his wording reaches that one, because his edits are matched on the whole string and the floor spells it differently, so he walks past the game version of a warning he has already rewritten');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.02',what:'no screen shows the original of a line he has rewritten
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
