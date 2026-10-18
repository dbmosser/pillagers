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

if ($s.Contains("  {v:'30.41',what:")) { throw "check 30.41 is in the fixture already" }

SubRx @'
  {v:'30.40',what:
'@ @'
  {v:'30.41',what:'the title shows one line, Ascend. Pillage. Extract., with no story paragraph, no step cards and nothing beside the logo (his Q51 and Q53)',
   run:function(){
     var t=document.getElementById('title'), tg=document.getElementById('titletag'), wm=t&&t.querySelector('.wordmark'), bad=[], was;
     if(!t||!wm) return 'SKIP: no title here';
     was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       if(!tg) return 'the title has no one line';
       if((tg.textContent||'').trim()!=='Ascend. Pillage. Extract.') bad.push('the line reads '+(tg.textContent||'').trim());
       if(t.querySelectorAll('.tcard').length) bad.push('the step cards are still there');
       if(/elites left|Take the lift up/.test(t.textContent||'')) bad.push('the story paragraph is still there');
       if(wm.parentNode.querySelector('img,canvas,svg')) bad.push('something sits beside the logo');
       if(tg.getBoundingClientRect().width<=0) bad.push('the line is not shown');
     } finally { if(!was) t.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
