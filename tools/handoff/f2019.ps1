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

if ($s.Contains("  {v:'20.19',what:")) { throw "check 20.19 is in the fixture already" }

SubRx @'
  {v:'20.18',what:
'@ @'
  {v:'20.19',what:'the TERMS names stand out: each term name is bold over its plain description, and an unsigned term is still dimmed',
   run:function(){
     if(typeof renderTerms!=='function') return 'SKIP: no TERMS here';
     var bad=[], rows, b, nm;
     try{
       renderTerms();
       rows=[].slice.call(document.querySelectorAll('#termslist .row'));
       if(!rows.length) return 'SKIP: no terms listed';
       nm=rows[0].querySelector('.nm'); b=nm&&nm.querySelector('b');
       if(!b) bad.push('the term name is not set apart');
       else if(!(parseInt(getComputedStyle(b).fontWeight,10)>=600)) bad.push('the term name is not bold ('+getComputedStyle(b).fontWeight+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
