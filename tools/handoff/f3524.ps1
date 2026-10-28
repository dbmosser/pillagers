$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'35.24',what:")) { throw "check 35.24 is in the fixture already" }

SubRx @'
  {v:'35.23',what:
'@ @'
  {v:'35.24',what:'cw-verat, his order 2026-10-27 (put the date and time of the update, in us eastern time): the title shows the build number and then the date and time the build shipped, us eastern, and the run report header carries the stamp; a copy with no stamp shows the number alone',
   run:function(){
     if(typeof VER_AT!=='string') return 'this build has no VER_AT stamp';
     if(typeof verAtSay!=='function'||typeof titleVerSync!=='function') return 'this build has no date label';
     var bad=[], keep=VER_AT, el=document.getElementById('titlever'), t, rep;
     try{
       if(!el) return 'no title version label';
       VER_AT='2026-10-27 19:40'; titleVerSync(); t=String(el.textContent);
       if(t!==verShown(VER)+' \u00b7 oct 27 7:40 pm et') bad.push('an evening build reads '+t);
       VER_AT='2026-11-02 00:05'; titleVerSync(); t=String(el.textContent);
       if(t!==verShown(VER)+' \u00b7 nov 2 12:05 am et') bad.push('a just after midnight build reads '+t);
       rep=String(buildExport()).split('\n')[0];
       if(rep.indexOf('build '+VER+', 2026-11-02 00:05 ET')<0) bad.push('the run report header has no build date: '+rep);
       VER_AT=''; titleVerSync(); t=String(el.textContent);
       if(t!==verShown(VER)) bad.push('a copy with no stamp reads '+t);
       if(keep&&!/^\d{4}-\d\d-\d\d \d\d:\d\d$/.test(keep)) bad.push('the shipped stamp is not a date and time: '+keep);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ VER_AT=keep; try{ titleVerSync(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'35.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
