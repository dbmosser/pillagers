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

if ($s.Contains("  {v:'24.83',what:")) { throw "check 24.83 is in the fixture already" }

SubRx @'
  {v:'24.82',what:
'@ @'
  {v:'24.83',what:'his #50 (UI redesign ui5q1q, from the lint of the Mainframe YOUR STATS shot): on the stats page a caption on the graphite is not in the dark ink of the cream cards, and the page is marked as a page that scrolls',
   run:function(){
     var p=document.getElementById('opane_rec'), bad=[], c, el;
     if(!p) return 'SKIP: no stats page here';
     el=p.querySelector('.crlab');
     if(!el){ el=document.createElement('div'); el.className='crlab'; el.textContent='A CAPTION '+'FOR THE CHECK'; p.appendChild(el); c=getComputedStyle(el).color; p.removeChild(el); }
     else c=getComputedStyle(el).color;
     if(c==='rgb(106, 101, 90)') bad.push('a caption on the stats page is in the dark card ink ('+c+')');
     if(!p.hasAttribute('data-lint-scroll')) bad.push('the stats page is not marked as a page that scrolls');
     return bad.length?bad.join('; '):null; }},
  {v:'24.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
