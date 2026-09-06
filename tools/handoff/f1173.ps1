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
     return bad.length?bad.join('; '):null; }},
  {v:'11.72',what:'a note typed in the pause box on the floor is banked to the profile when the box closes, cleared from the box, and printed in the run report under FLOOR NOTES',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
