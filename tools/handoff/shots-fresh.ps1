param([int]$Cdp=9346,[int]$Port=8806,[string]$Dir='C:\claudecode\dark raiders\tools\handoff\shots\fresh')
# THE FIRST FIVE MINUTES (2026-10-03): a brand-new save, as a stranger sees it. Storage cleared, the page reloaded, then the title,
# ENTER THE UNDERCROFT, whatever window greets him, the floor, the stash and the lift page. Jpegs in $Dir.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
New-Item -ItemType Directory -Force $Dir | Out-Null
function Ev([string]$e,[string]$shot='',[int]$t=60){ if($shot){ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec $t -Shot (Join-Path $Dir $shot) -Expr $e 2>$null } else { powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec $t -Expr $e 2>$null } }
function Ready(){ for($w=0;$w -lt 120;$w++){ Start-Sleep -Milliseconds 500; $ok=Ev "String(typeof __pinDPR==='function'&&typeof __station==='function')" '' 5; if($ok -eq 'true'){ return } } }
(Invoke-RestMethod ("http://127.0.0.1:$Cdp/json")) | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Port*" } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }catch{} }
$t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/fixture.html"); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
Ready
Ev "(function(){ try{ localStorage.clear(); }catch(e){} location.reload(); return 'reloading'; })()" '' 10 | Out-Null
Start-Sleep 3; Ready
$wait="await new Promise(function(r){ setTimeout(r,800); });"
Ev "(async function(){ __pinDPR(1); $wait return 'title'; })()" '1-title.jpg'
Ev "(async function(){ var b=document.getElementById('titlestart'); if(b) b.click(); $wait $wait return 'entered '+!!b; })()" '2-after-enter.jpg'
Ev "(async function(){ var m=document.querySelector('.modal.on'); var bs=m?m.querySelectorAll('button'):[]; var hit=null; for(var i=0;i<bs.length;i++){ if(/TAKE|OK|CLOSE|GOT IT|CONTINUE/i.test(bs[i].textContent)){ hit=bs[i]; break; } } if(hit) hit.click(); else if(m) m.classList.remove('on'); $wait return 'closed '+(hit?hit.textContent:'none'); })()" '3-floor.jpg'
Ev "(async function(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'Enter',key:'Enter',bubbles:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'Enter',key:'Enter',bubbles:true})); $wait return 'enter'; })()" '4-floor-after-enter.jpg'
Ev "(async function(){ var r=__station('term','KeyE'); $wait return JSON.stringify(r); })()" '5-stash.jpg'
Ev "(async function(){ document.querySelectorAll('.modal.on').forEach(function(m){ m.classList.remove('on'); }); __hubEnter(); var r=__station('lift','KeyE'); $wait return JSON.stringify(r); })()" '6-lift.jpg'
Ev "(async function(){ document.querySelectorAll('.modal.on').forEach(function(m){ m.classList.remove('on'); }); __hubEnter(); return 'done'; })()"
Get-ChildItem $Dir -Filter *.jpg | ForEach-Object { '{0} {1} KB' -f $_.Name,[math]::Round($_.Length/1KB) }
