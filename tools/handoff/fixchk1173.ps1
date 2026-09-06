$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 11.73 could not fail on the old build: it asked whether a CLEANED
# profile has a name, and __cleanProfile rebuilds the profile through the
# loader, which is precisely the thing that hands out a name. So the state it
# meant to test, a profile that has never met the loader, was unreachable and
# the control passed. It now MAKES that state by taking the name off a live
# profile, then reads the line a player actually sees.
$files = @('C:\claudecode\dark raiders\tools\mkfixture.ps1',
           'C:\claudecode\dark raiders\tools\handoff\f1173.ps1')
$old = @'
     var bad=[], prof, keepRuns, keepCred;
     try{
       __topClear(); __cleanProfile();
       prof=__P();
       // THE FIX: the name is born with the profile, not handed out by the loader.
       if(typeof prof.pname!=='string'||!prof.pname) bad.push('a profile that has never been saved has no name (pname is '+(typeof prof.pname)+'), so the loader is the only thing that can give it one and a brand new player never meets the loader');
       // AND THE CONSEQUENCE: the line that names him once he has a raid behind him.
       if(typeof titleRefresh==='function'){
         keepRuns=prof.runs; keepCred=prof.credits;
         prof.runs=1; prof.credits=900;
         try{ titleRefresh(); }catch(_t){}
         var sub=document.getElementById('titlesub'), txt=sub?String(sub.textContent||''):'';
         if(txt&&txt.indexOf('undefined')>=0) bad.push('the character screen reads "'+txt.slice(0,60)+'"');
         // CONTROL: that line really is the one that carries the name, or the
         // absence of "undefined" above proves nothing.
         if(txt&&txt.indexOf(String(prof.pname))<0) bad.push('control: the character screen does not carry the name at all, so this line is not the one that shows it: "'+txt.slice(0,60)+'"');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var pf=__P(); if(keepRuns!==undefined) pf.runs=keepRuns; if(keepCred!==undefined) pf.credits=keepCred; }catch(_r){}
       __topClear(); __cleanProfile();
     }
'@
$new = @'
     if(typeof titleRefresh!=='function') return 'SKIP: no character screen to refresh here';
     var bad=[], prof, keepRuns, keepCred, keepName;
     try{
       __topClear(); __cleanProfile();
       prof=__P();
       keepName=prof.pname; keepRuns=prof.runs; keepCred=prof.credits;
       // THE STATE A FIRST-TIME PLAYER IS IN: no name on the profile, because
       // the line that hands one out lives in the loader and he has never
       // saved. __cleanProfile cannot leave the profile in that state, since it
       // rebuilds through the loader, so the check makes it.
       try{ delete prof.pname; }catch(_d){ prof.pname=undefined; }
       prof.runs=1; prof.credits=900;
       try{ titleRefresh(); }catch(_t){}
       var sub=document.getElementById('titlesub'), txt=sub?String(sub.textContent||''):'';
       if(!txt) bad.push('control: the character screen line is empty, so nothing was measured');
       else {
         // THE FIX: a nameless character is still called something.
         if(txt.indexOf('undefined')>=0) bad.push('with no name on the profile the character screen reads "'+txt.slice(0,60)+'"');
         // CONTROL: this really is the line that names him, or the absence of
         // "undefined" above proves nothing.
         if(txt.indexOf('1 raid logged')<0) bad.push('control: that is not the line that names the character: "'+txt.slice(0,60)+'"');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var pf=__P(); if(keepName!==undefined) pf.pname=keepName; if(keepRuns!==undefined) pf.runs=keepRuns; if(keepCred!==undefined) pf.credits=keepCred; }catch(_r){}
       __topClear(); __cleanProfile();
     }
'@
foreach ($f in $files) {
  $s = [IO.File]::ReadAllText($f)
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne 1) { throw "$f : matched $c" }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
  Write-Output "patched $f"
}
