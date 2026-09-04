$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ==== MY NEW CHECK BROKE TWO OTHERS, AND BOTH FAILURES WERE FAIR.
# ==== v11.11 rewrote the profile to a fresh one, restored a LIST of fields, and
# ==== then called saveProfile, which wrote whatever survived that list to disk.
# ==== Two checks downstream read the fields it did not think to name.
# ==== A check may borrow the profile. It may not persist what it borrowed, and
# ==== it may not restore it field by field, because the next check depends on a
# ==== field this one has never heard of. It takes a whole snapshot now and puts
# ==== the whole thing back.
SubRx @'
     var bad=[], prof=__P(), keep={}, k, i;
     var F=['runs','ext','died','best','credits','xp','xpLevel','stash','kit','log',
            'contracts','racks','arrays','notoriety','cstand','spClaimed','kills',
            'cosBought','junk','weapons','equipped','pack','cosAll','stashTab'];
     for(i=0;i<F.length;i++) keep[F[i]]=prof[F[i]];
'@ @'
     var bad=[], prof=__P(), keep={}, k, i;
     // THE WHOLE PROFILE, not a list of the fields I happened to think of. The
     // first version of this named twenty-four and broke two checks that read a
     // twenty-fifth.
     for(k in prof) keep[k]=prof[k];
'@
SubRx @'
       for(i=0;i<F.length;i++) prof[F[i]]=keep[F[i]];
       try{ var op=document.querySelectorAll('.modal.on'); for(i=0;i<op.length;i++) op[i].classList.remove('on'); }catch(_cl){}
       try{ saveProfile(); }catch(_sp){}
'@ @'
       for(k in prof) if(!(k in keep)) delete prof[k];
       for(k in keep) prof[k]=keep[k];
       try{ var op=document.querySelectorAll('.modal.on'); for(i=0;i<op.length;i++) op[i].classList.remove('on'); }catch(_cl){}
       // AND IT DOES NOT SAVE. Borrowing the profile in memory is fair; writing
       // the borrowed version to disk is what made this permanent.
'@
# ==== AND v10.99 LEANED ON PROGRESS IT NEVER ASKED FOR. Its hero arm sets the
# ==== worn cosmetic and trusts cosWorn to return it, but cosWorn asks cosOwned,
# ==== which derives ownership from runs, extracts, level and warden kills. Any
# ==== check that lowers those makes her hat vanish and v10.99 reports that the
# ==== rack was taken off her. It unlocks the rack for its own arm now.
SubRx @'
       var was=prof[R.pk];
       prof[R.pk]=R.h0; var H1=shot({hero:1});
       prof[R.pk]=R.hv; var H2=shot({hero:1});
       prof[R.pk]=was;
'@ @'
       var was=prof[R.pk], wasAll=prof.cosAll;
       prof.cosAll=1;   // v11.11: own the rack for this arm, or a profile with no
                        // runs on it hides the hat and this reads as her losing it
       prof[R.pk]=R.h0; var H1=shot({hero:1});
       prof[R.pk]=R.hv; var H2=shot({hero:1});
       prof[R.pk]=was; prof.cosAll=wasAll;
'@
# ==== AND THE JERSEY NUMERAL IS ART, NOT MENU TEXT. The 23 on the Fashion figure
# ==== is set in Impact on purpose, the way a number on a shirt is; the canvas
# ==== draws its own 23 as rectangles rather than as text at all. It is named as
# ==== an exception, like the wordmark, rather than quietly allowed.
SubRx @'
       var c=el.className;
       if(typeof c==='string'&&c.indexOf('brand')>=0) return true;
'@ @'
       var c=el.className;
       if(typeof c==='string'&&c.indexOf('brand')>=0) return true;
       if(typeof c==='string'&&c.indexOf('avnum')>=0) return true;   // the 23 on the shirt
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
