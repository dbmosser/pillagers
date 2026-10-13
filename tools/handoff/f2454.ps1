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

if ($s.Contains("  {v:'24.54',what:")) { throw "check 24.54 is in the fixture already" }

SubRx @'
  {v:'24.53',what:
'@ @'
  {v:'24.54',what:'his #50 (UI redesign ui5q1h, from the AAA judge of the shop and Mainframe shots): in the shop the item grid starts within 90px under the tabs, and in the shop and the Mainframe the detail card ends on the right edge of the window heading line (within 8px)',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], m, h, d, tb, gr, z, k, st=[['trader','tradermodal','shopdetail'],['mf','opmodal',null]];
     try{
       for(k=0;k<st.length;k++){
         __topClear(); __hubEnter(); __station(st[k][0],'KeyE');
         m=document.getElementById(st[k][1]);
         if(!m||!m.classList.contains('on')){ bad.push('control: '+st[k][1]+' did not open'); continue; }
         z=(((typeof menuScale==='function')&&menuScale())||1);
         h=m.querySelector('h3');
         d=st[k][2]?document.getElementById(st[k][2]):[].filter.call(m.querySelectorAll('.vdet'),function(e){ return e.getClientRects().length>0; })[0];
         if(!h||!d||!d.getClientRects().length){ bad.push('control: no heading or detail card in '+st[k][1]); continue; }
         if(Math.abs(h.getBoundingClientRect().right-d.getBoundingClientRect().right)/z>8) bad.push(st[k][1]+': the detail card ends '+Math.round((h.getBoundingClientRect().right-d.getBoundingClientRect().right)/z)+'px short of the heading line');
         if(k===0){
           tb=document.getElementById('tradertabs'); gr=document.getElementById('shopgrid');
           if(tb&&gr&&gr.getClientRects().length&&(gr.getBoundingClientRect().top-tb.getBoundingClientRect().bottom)/z>90) bad.push('the shop grid starts '+Math.round((gr.getBoundingClientRect().top-tb.getBoundingClientRect().bottom)/z)+'px under the tabs');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
