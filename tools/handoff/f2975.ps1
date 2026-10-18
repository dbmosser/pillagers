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

if ($s.Contains("  {v:'29.75',what:")) { throw "check 29.75 is in the fixture already" }

SubRx @'
  {v:'29.74',what:
'@ @'
  {v:'29.75',what:'Settings: each stepper is right-aligned in its row, the card is 15 x 48 wide, and the toast is not at the bottom while Settings is open',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], l, rows, i, r, b, gap, t, cs, c;
     try{
       openSettings('display'); l=document.getElementById('setlist');
       if(!l) return 'SKIP: no list';
       rows=l.querySelectorAll('.row:not(.setjump)');
       for(i=0;i<rows.length;i++){
         r=rows[i]; b=r.querySelector(':scope > button');
         if(!b||!b.offsetWidth||r.style.opacity||r.children.length!==2||r.querySelectorAll('button').length!==1) continue;
         gap=r.getBoundingClientRect().right-b.getBoundingClientRect().right;
         if(gap>40){ bad.push('stepper is '+Math.round(gap)+'px short of the row edge (limit 40) DBG iw='+innerWidth+' row='+Math.round(r.getBoundingClientRect().width)+' bl='+Math.round(b.getBoundingClientRect().left-r.getBoundingClientRect().left)+' bw='+b.offsetWidth+' ml='+getComputedStyle(b).marginLeft+' html='+r.outerHTML.slice(0,260).replace(/\s+/g,' ')); break; }
       }
       c=document.getElementById('settingsmodal'); cs=c?getComputedStyle(c).getPropertyValue('--cw'):'';
       if(c){ var w=l.getBoundingClientRect().width; if(w>760) bad.push('settings list is '+Math.round(w)+'px wide (limit 760)'); }
       t=document.getElementById('hubtoast');
       if(t){ var ts=getComputedStyle(t); if(ts.bottom!=='auto'&&parseFloat(ts.top)>200) bad.push('toast sits at the bottom while Settings is open'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
