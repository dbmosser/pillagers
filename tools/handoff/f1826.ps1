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

if ($s.Contains("  {v:'18.26',what:")) { throw "check 18.26 is in the fixture already" }

SubRx @'
  {v:'18.25',what:
'@ @'
  {v:'18.26',what:'short dark hair is the default look, his order of 2026-10-03: a character with no hair or cut picked wears dark hair in a crop, and Dark hair is open to a new character so the mirror does not show the default as locked',
   run:function(){
     if(typeof COSDEF==='undefined'||typeof cosWorn!=='function'||typeof COSKEY==='undefined') return 'SKIP: no looks here';
     var bad=[], h0=P[COSKEY.hair], c0=P[COSKEY.cut], r0=P.runs, d;
     if(COSDEF.hair!=='dark') bad.push('the default hair is '+COSDEF.hair);
     if(COSDEF.cut!=='crop') bad.push('the default cut is '+COSDEF.cut);
     try{
       delete P[COSKEY.hair]; delete P[COSKEY.cut]; P.runs=0;
       if(cosWorn('hair')!=='dark') bad.push('a character with no pick wears '+cosWorn('hair')+' hair');
       if(cosWorn('cut')!=='crop') bad.push('a character with no pick wears the '+cosWorn('cut')+' cut');
       d=(typeof cosFind==='function')?cosFind('dark'):null;
       if(!d) bad.push('there is no Dark hair');
       else if(typeof cosOwned==='function'&&!cosOwned(d)) bad.push('Dark hair is locked for a new character, so the mirror shows the default as something he does not own');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(h0===undefined) delete P[COSKEY.hair]; else P[COSKEY.hair]=h0; if(c0===undefined) delete P[COSKEY.cut]; else P[COSKEY.cut]=c0; P.runs=r0; }
     return bad.length?bad.join('; '):null; }},
  {v:'18.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
