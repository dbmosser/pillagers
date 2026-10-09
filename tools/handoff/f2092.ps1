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

if ($s.Contains("  {v:'20.92',what:")) { throw "check 20.92 is in the fixture already" }

SubRx @'
  {v:'20.91',what:
'@ @'
  {v:'20.92',what:'the stash search box is as tall as the tabs and SORT beside it and level with them, and the pair fills the room left in the filter row',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], hub=document.getElementById('hub'), tb, tab, sq, sb, a, b, c, t, padR;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       tb=document.getElementById('stashtabs'); if(!tb||!tb.getBoundingClientRect().width) return 'SKIP: the stash did not open';
       tab=tb.querySelector('.invtab'); sq=document.getElementById('stashsearch'); sb=document.getElementById('stashsort');
       if(!tab||!sq||!sb) return 'SKIP: no filter row';
       a=sq.getBoundingClientRect(); b=sb.getBoundingClientRect(); c=tab.getBoundingClientRect(); t=tb.getBoundingClientRect();
       if(!(a.height>0&&b.height>0&&c.height>0&&t.width>0)) return 'SKIP: the filter row has no size here';
       if(Math.abs(a.height-b.height)>2) bad.push('the search box is '+Math.round(a.height)+' px tall beside a '+Math.round(b.height)+' px SORT button');
       if(Math.abs(a.top-b.top)>2) bad.push('the search box top is '+Math.round(a.top-b.top)+' px off the SORT button top');
       if(Math.abs(b.height-c.height)>2) bad.push('SORT is '+Math.round(b.height)+' px tall beside '+Math.round(c.height)+' px tabs');
       if(Math.abs(b.top-c.top)<c.height&&Math.abs(b.top-c.top)>2) bad.push('SORT sits '+Math.round(b.top-c.top)+' px lower than the tabs on the same line');
       padR=t.right-Math.max(a.right,b.right);
       if(padR>t.width*0.08) bad.push('the row ends '+Math.round(padR)+' px short of its right edge, of '+Math.round(t.width));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(hub) hub.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
