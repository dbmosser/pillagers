param([string]$Src='C:\claudecode\dark raiders\dark_raiders.html',[string]$Out='C:\claudecode\dark raiders\tools\handoff\drafts\draft-uic7.json')
. 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\uiclib.ps1'
# every row hint that is written in capitals goes to sentence case, like the rows of THE RAID (his own words stay as they are: they are not in capitals)
function Sent([string]$s){
  $t=$s.ToLower()
  $t=[regex]::Replace($t,'(^|\.\s+)([a-z])',{ param($m) $m.Groups[1].Value+$m.Groups[2].Value.ToUpper() })
  foreach($a in 'HUD','FPS','TV','PC','UI','LMB','RMB','MK'){ $t=[regex]::Replace($t,'\b'+$a+'\b',$a,[System.Text.RegularExpressions.RegexOptions]::IgnoreCase) }
  return $t
}
$ms=[regex]::Matches($g,"hint:'([^'\\r\n]*)'")
$seen=@{}; $n=0
foreach($m in $ms){
  $old=$m.Groups[1].Value
  if($old -cmatch '[a-z]'){ continue }
  if(($old -creplace '[^A-Z]','').Length -lt 10){ continue }
  if($seen.ContainsKey($old)){ continue }; $seen[$old]=1
  $new=Sent $old
  if($new -ceq $old){ continue }
  Add ("hint:'"+$old+"'") ("hint:'"+$new+"'")
  $n++
}
if($n -lt 20){ throw "only $n capital hints found" }
$chk=@'
  {v:'VER',what:'his 2026-10-14 note (UI cleanup uic7): the Settings row descriptions are in one voice, sentence case like the rows of THE RAID: none of the rows is a line in capitals (38 of them were, in CONTROLS, DISPLAY, AUDIO, CONTROLLER and ACCESSIBILITY)',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings window in this build';
     var m=document.getElementById('settingsmodal'), was=m&&m.classList.contains('on');
     if(!m) return 'SKIP: no Settings window';
     var bad=[];
     try{
       try{ __topClear(); }catch(_t){}
       openSettings();
       var hs=document.querySelectorAll('#setlist .row .hint'), i, t, n=0, caps=[];
       for(i=0;i<hs.length;i++){ t=String(hs[i].textContent||'').trim(); if(t.length<12) continue; n++; if(t===t.toUpperCase()&&/[A-Z]{4}/.test(t)) caps.push(t.slice(0,48)); }
       if(n<20) return 'SKIP: only '+n+' row descriptions are drawn here';
       if(caps.length) bad.push(caps.length+' of '+n+' row descriptions are in capitals, such as: '+caps.slice(0,3).join(' | '));
       return bad.length?bad.join('; '):null;
     } finally { try{ __topClear(); }catch(_c){} if(!was) m.classList.remove('on'); } }},
'@
Draft 'SETTINGS TEXT IN ONE VOICE' 'His note after playing: the UI is not as clean as it should be. In the pictures, the row descriptions in Settings came in two voices: sentence case under THE RAID (his words and the older rows), and long lines in capitals under CONTROLS, DISPLAY, AUDIO, CONTROLLER and ACCESSIBILITY, about forty rows shouting at once. They are all sentence case now. No wording changed, and none of his own lines was touched.' 'Every Settings row description is in sentence case.' $chk
