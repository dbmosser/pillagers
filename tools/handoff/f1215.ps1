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

# v12.15 CHECK, inserted before the v12.14 entry. The WEAPONS rule of the
# controls card is read as the card reads it (a string, or a function of the
# pad state) and must name the belt keys and no X or Y swap.
SubRx @'
  {v:'12.14',what:'ESC over the open Undercroft backpack closes the backpack instead of raising the pause box, and ESC with it closed still pauses (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.15',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(typeof GEARRULES==='undefined'||!GEARRULES.length) return 'SKIP: no controls card rules in this build';
     var bad=[], row=null;
     for(var i=0;i<GEARRULES.length;i++) if(GEARRULES[i][0]==='WEAPONS'){ row=GEARRULES[i]; break; }
     if(!row) return 'SKIP: the card has no WEAPONS rule';
     var txt=(typeof row[1]==='function')?String(row[1]()):String(row[1]);
     if(/\bX swaps\b|\bY swaps\b/.test(txt)) bad.push('the WEAPONS rule still teaches a swap key that does not exist: "'+txt+'"');
     if(!/1 and 2/.test(txt)) bad.push('the WEAPONS rule does not name the belt keys: "'+txt+'"');
     return bad.length?bad.join('; '):null; }},
  {v:'12.14',what:'ESC over the open Undercroft backpack closes the backpack instead of raising the pause box, and ESC with it closed still pauses (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
