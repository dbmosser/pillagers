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

# v11.73 CHECK, inserted before the v11.72 entry.
SubRx @'
  {v:'11.72',what:'a note typed in the pause box on the floor is banked to the profile when the box closes, cleared from the box, and printed in the run report under FLOOR NOTES',
'@ @'
  {v:'11.73',what:'a character who has never saved still has a name, and the character screen does not read undefined beside their first raid',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
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
     return bad.length?bad.join('; '):null; }},
  {v:'11.72',what:'a note typed in the pause box on the floor is banked to the profile when the box closes, cleared from the box, and printed in the run report under FLOOR NOTES',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
