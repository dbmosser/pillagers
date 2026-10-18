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

if ($s.Contains("  {v:'29.39',what:")) { throw "check 29.39 is in the fixture already" }

SubRx @'
  {v:'29.38',what:
'@ @'
  {v:'29.39',what:'the pause box and Settings (screens 18, 25-32, 42, 49, 68-75) run on the shared look: the pause title is 32px in light text, the key legend 16px, a Settings row name is 20px with its sentence moved to the detail pane, the stepper is 48px high, the section chips are text tabs with a 3px underline',
   run:function(){
     var h3=document.querySelector('#pausebox h3'), pk=document.getElementById('pausekeys'), sl=document.getElementById('setlist'), tmp=null, cs, b, hint, btn, jb, bad=[];
     if(!h3||!pk||!sl) return 'no pause title, key legend or settings list';
     cs=getComputedStyle(h3);
     if(parseFloat(cs.fontSize)!==32) bad.push('pause title is '+cs.fontSize+', not 32px');
     if(cs.color===getComputedStyle(document.documentElement).getPropertyValue('--acc').trim()||cs.color==='rgb(245, 183, 59)') bad.push('pause title is amber');
     if(parseFloat(getComputedStyle(pk).fontSize)!==16) bad.push('key legend is '+getComputedStyle(pk).fontSize+', not 16px');
     tmp=document.createElement('div'); tmp.className='row'; tmp.innerHTML='<div><b>x</b><div class="hint">y</div></div><button>z</button>';
     var tj=document.createElement('div'); tj.className='setjump'; tj.innerHTML='<div class="sj"><button class="on">a</button></div>';
     sl.appendChild(tmp); sl.appendChild(tj);
     try{
       b=tmp.querySelector('b'); hint=tmp.querySelector('.hint'); btn=tmp.querySelector('button'); jb=tj.querySelector('button');
       if(parseFloat(getComputedStyle(b).fontSize)!==20) bad.push('row name is '+getComputedStyle(b).fontSize+', not 20px');
       if(getComputedStyle(hint).display!=='none') bad.push('the row sentence still sits in the list');
       if(parseFloat(getComputedStyle(btn).minHeight)!==48) bad.push('stepper min height is '+getComputedStyle(btn).minHeight+', not 48px');
       if(!(parseFloat(getComputedStyle(jb).borderBottomWidth)>=2&&parseFloat(getComputedStyle(jb).borderBottomWidth)<=3.5)||parseFloat(getComputedStyle(jb).borderTopWidth)!==0) bad.push('section chip is not a text tab with a 3px underline: bottom '+getComputedStyle(jb).borderBottomWidth+' top '+getComputedStyle(jb).borderTopWidth+' style '+getComputedStyle(jb).borderBottomStyle);
     } finally { try{ tmp.remove(); tj.remove(); }catch(_r){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'29.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
