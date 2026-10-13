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

if ($s.Contains("  {v:'24.98',what:")) { throw "check 24.98 is in the fixture already" }

SubRx @'
  {v:'24.97',what:
'@ @'
  {v:'24.98',what:'his #50 (UI redesign ui5q2o): Settings has a detail pane right of the list that shows the row under the mouse (its name and description)',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], dt, sl, q, i, r=null, nm;
     try{
       __topClear(); __hubEnter(); __station('dev','KeyE');
       sl=document.getElementById('setlist'); dt=document.getElementById('setdetail');
       if(!sl||!sl.getClientRects().length) return 'SKIP: Settings did not open';
       if(!dt) return 'Settings has no detail pane';
       q=sl.querySelectorAll('.row');
       for(i=q.length-1;i>=0;i--){ var b=q[i].querySelector('div > b'), h=q[i].querySelector('.hint'); if(b&&h&&h.textContent&&!/opacity:\s*\.7/.test(q[i].getAttribute('style')||'')){ r=q[i]; break; } }
       if(!r) return 'SKIP: no settings row with a description';
       nm=r.querySelector('div > b').textContent;
       r.querySelector('div > b').dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
       if(window.__setDetailSync) window.__setDetailSync();
       if(dt.textContent.indexOf(nm)<0) bad.push('the detail pane does not show the row under the mouse ('+nm+')');
       if(dt.textContent.indexOf(r.querySelector('.hint').textContent.slice(0,20))<0) bad.push('the detail pane does not carry the description');
       if(!dt.getClientRects().length||dt.getBoundingClientRect().left<sl.getBoundingClientRect().right) bad.push('the detail pane is not beside the list');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
