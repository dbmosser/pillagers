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

if ($s.Contains("  {v:'24.42',what:")) { throw "check 24.42 is in the fixture already" }

SubRx @'
  {v:'24.41',what:
'@ @'
  {v:'24.42',what:'his #50 (UI redesign ui5q1m, from the AAA judge of the Wirt shot): GAMBLE is a full width button at least 46px tall with a 16px or larger label, and greyed out it keeps its words in the second text colour',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], b, sec, s, br, sr;
     try{
       __topClear(); __hubEnter(); __station('gamble','KeyE');
       b=document.getElementById('gamblebtn'); sec=document.getElementById('wirtsec_gamble');
       if(!b||!sec||!b.getClientRects().length) return 'SKIP: Wirt did not open';
       s=getComputedStyle(b);
       if(!(parseFloat(s.minHeight)>=46)) bad.push('GAMBLE is held to '+s.minHeight);
       if(!(parseFloat(s.fontSize)>=16)) bad.push('GAMBLE is '+s.fontSize);
       br=b.getBoundingClientRect(); sr=sec.getBoundingClientRect();
       if(br.width<sr.width*0.8) bad.push('GAMBLE is '+Math.round(100*br.width/sr.width)+' percent of its box, not full width');
       if(b.disabled&&s.color==='rgb(122, 118, 110)') bad.push('a greyed GAMBLE is in the faint third text colour');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
