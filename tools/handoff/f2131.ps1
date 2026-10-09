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

if ($s.Contains("  {v:'21.31',what:")) { throw "check 21.31 is in the fixture already" }

SubRx @'
  {v:'21.30',what:
'@ @'
  {v:'21.31',what:'on the stash screen the counts beside LOADOUT, BACKPACK and TACTICAL BELT end at the right edge of the backpack slots, as the names start at their left edge',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], hub=document.getElementById('hub'), col, kg, i, r, lo=1e9, hi=-1e9, cr, sc, el, er, n=0,
         ids=['kitval','kitn','quickn'], nm=['the LOADOUT value','the BACKPACK count','the TACTICAL BELT count'];
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       col=document.getElementById('kitcol'); kg=document.getElementById('kitgrid');
       if(!col||!kg||!(col.getBoundingClientRect().width>0)) return 'SKIP: the stash did not open';
       for(i=0;i<kg.children.length;i++){ r=kg.children[i].getBoundingClientRect(); if(r.width>0&&r.height>0){ if(r.left<lo) lo=r.left; if(r.right>hi) hi=r.right; } }
       if(!(hi>lo)) return 'SKIP: the backpack drew no slots here';
       cr=col.getBoundingClientRect(); sc=kg.scrollHeight>kg.clientHeight+2;
       for(i=0;i<ids.length;i++){
         el=document.getElementById(ids[i]); el=el?el.parentNode:null;
         if(!el){ bad.push('no '+nm[i]+' on the screen'); continue; }
         er=el.getBoundingClientRect(); if(!(er.width>0)) continue;
         n++;
         if(!sc){ if(Math.abs(er.right-hi)>2) bad.push(nm[i]+' ends '+Math.round(hi-er.right)+' px short of the right edge of the backpack slots'); }
         else if(Math.abs((cr.right-er.right)-(lo-cr.left))>3) bad.push(nm[i]+' ends '+Math.round(cr.right-er.right)+' px in from the right of the column while the slots start '+Math.round(lo-cr.left)+' px in from the left');
       }
       if(!n) return 'SKIP: the counts have no size here';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(hub) hub.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
