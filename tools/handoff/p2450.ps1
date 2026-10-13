$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# FEEDBACK WITH A SCREENSHOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<textarea id="pausenote" rows="3" style="max-width:560px;font-size:13px"
'@ @'
<textarea id="pausenote" rows="3" style="display:none;max-width:560px;font-size:13px"
'@

SubRx @'
    <button id="pausesetbtn" style="padding:8px 22px">Settings</button>
'@ @'
    <button id="pausesetbtn" style="padding:8px 22px">Settings</button>
    <!-- v24.50, his answer 38: FEEDBACK, a typed note and a screenshot of this moment (the note box above is replaced by it) -->
    <button id="fbbtn" style="padding:8px 22px">FEEDBACK</button>
'@

SubRx @'
<div class="outcome" id="outcome">
'@ @'
<!-- v24.50, HIS ANSWER 38 (2026-10-12, "yes, keep it on esc/tab"): THE FEEDBACK WINDOW, over the pause box. -->
<div class="modal" id="fbmodal" style="align-items:center;justify-content:center;text-align:center">
  <h3>FEEDBACK</h3>
  <div class="msub" id="fbsub">WHAT WENT WRONG OR FELT WRONG? THIS SCREENSHOT GOES WITH IT.</div>
  <img id="fbshot" alt="" style="max-width:min(560px,90%);max-height:30vh;border:1px solid var(--steel-hi);margin:8px 0">
  <textarea id="fbnote" rows="5" style="max-width:560px;font-size:14px" placeholder="TYPE YOUR NOTE. CTRL+ENTER SAVES."></textarea>
  <div style="display:flex;gap:8px;margin-top:10px">
    <button id="fbsave" style="padding:8px 22px">SAVE</button>
    <button id="fbcancel" data-esc="1" style="padding:8px 22px">CANCEL</button>
  </div>
</div>
<div class="outcome" id="outcome">
'@

SubRx @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
'@ @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
// v24.50, HIS ANSWER 38 (2026-10-12): "yes, keep it on esc/tab". IN-GAME FEEDBACK, A NOTE AND A SCREENSHOT. The pause box held a note
// field that went only into the run report, with no picture of what he was looking at, and on the floor it waited for the next report.
// The box (ESC or TAB, in a raid, on the floor and in the demo) now has FEEDBACK: it takes a screenshot of the game as it stands (the
// world and the HUD, before the window covers it), then opens a window with that picture, a note field (focused, so he can type at
// once; CTRL+ENTER saves, ESC cancels) and SAVE and CANCEL, which a pad reaches too. SAVE writes the note with the version, the time
// and where he was, and the picture: on his own machine through the collector into exports/ (feedback-STAMP.txt and .png), and
// anywhere else as two downloaded files, pillagers_feedback_STAMP.txt and .png; inside an itch page, which cannot save files, the
// note is copied instead. Nothing in the save changes, so it is safe in the demo too. The old note field is hidden.
var FB={png:'',last:'',n:0};
function fbShot(){
  try{
    var w=(cv&&cv.width)||0, h=(cv&&cv.height)||0, c, x;
    if(!(w>0&&h>0)) return '';
    c=document.createElement('canvas'); c.width=w; c.height=h; x=c.getContext('2d');
    x.fillStyle='#000'; x.fillRect(0,0,w,h);
    x.drawImage(cv,0,0,w,h);
    if(hcv&&hcv.width>0&&hcv.height>0) x.drawImage(hcv,0,0,w,h);
    return c.toDataURL('image/png');
  }catch(e){ return ''; }
}
function fbOpen(){
  var m=document.getElementById('fbmodal'), im=document.getElementById('fbshot'), ta=document.getElementById('fbnote');
  if(!m) return false;
  FB.png=fbShot();
  if(im){ im.src=FB.png||''; im.style.display=FB.png?'':'none'; }
  if(ta) ta.value='';
  m.classList.add('on');
  setTimeout(function(){ try{ if(ta&&m.classList.contains('on')) ta.focus(); }catch(_f){} },30);
  return true;
}
function fbClose(){
  var m=document.getElementById('fbmodal'), ta=document.getElementById('fbnote');
  if(m) m.classList.remove('on');
  try{ if(ta) ta.blur(); }catch(_b){}
  FB.png='';
  return true;
}
function fbStamp(){
  var d=new Date(), z=function(n){ return (n<10?'0':'')+n; };
  return d.getFullYear()+z(d.getMonth()+1)+z(d.getDate())+'-'+z(d.getHours())+z(d.getMinutes())+z(d.getSeconds());
}
function fbText(note){
  var where='THE UNDERCROFT', L;
  try{ if(G&&!G.over) where='IN A RAID'+(G.arcade?' (DEMO)':'')+', '+fmtDur(runElapsed())+' IN'; }catch(_w){}
  L=['PILLAGERS FEEDBACK','VERSION: '+((typeof verShown==='function')?verShown(VER):VER)+' (BUILD '+VER+')','TIME: '+new Date().toString(),'WHERE: '+where,'RUNS: '+((P&&P.runs)||0),'',String(note||'').slice(0,4000)||'(NO NOTE)'];
  return L.join('\r\n')+'\r\n';
}
function fbPost(url,body){ try{ return fetch(url,{method:'POST',headers:{'Content-Type':'text/plain'},body:body}); }catch(e){ return null; } }
function fbFiles(txt,png,st){
  if(reportEmbedded()){ try{ if(navigator.clipboard) navigator.clipboard.writeText(txt); }catch(_c){} return 'embedded'; }
  function dl(name,href){ var a=document.createElement('a'); a.href=href; a.download=name; document.body.appendChild(a); a.click(); setTimeout(function(){ try{ document.body.removeChild(a); }catch(_r){} },800); }
  try{
    var u=URL.createObjectURL(new Blob([txt],{type:'text/plain'}));
    dl('pillagers_feedback_'+st+'.txt',u); setTimeout(function(){ try{ URL.revokeObjectURL(u); }catch(_u){} },3000);
    if(png) dl('pillagers_feedback_'+st+'.png',png);
    return 'downloaded';
  }catch(e){ return 'failed'; }
}
function fbSaid(){
  var t=(FB.last==='embedded')?'FEEDBACK COPIED':((FB.last==='failed')?'FEEDBACK NOT SAVED':'FEEDBACK SAVED');
  try{ if(G&&!G.over) say(t,'info'); else hubToast(t); }catch(_s){}
}
function fbSave(note,png){
  var txt=fbText(note), st=fbStamp(), url=(typeof LOCAL_DROP==='string'&&LOCAL_DROP&&DROP===LOCAL_DROP)?LOCAL_DROP.replace(/telemetry$/,'feedback'):null, pr;
  FB.n++;
  if(url){
    pr=fbPost(url,txt+'\n----PILLAGERS-PNG----\n'+(png||''));
    if(pr&&pr.then){
      pr.then(function(r){ FB.last=(r&&r.ok)?'posted':fbFiles(txt,png,st); fbSaid(); },function(){ FB.last=fbFiles(txt,png,st); fbSaid(); });
      return 'post';
    }
  }
  FB.last=fbFiles(txt,png,st); fbSaid();
  return FB.last;
}
document.getElementById('fbbtn').onclick=function(){ fbOpen(); };
document.getElementById('fbsave').onclick=function(){ var ta=document.getElementById('fbnote'), png=FB.png; fbClose(); fbSave(ta?ta.value:'',png); };
document.getElementById('fbcancel').onclick=function(){ fbClose(); };
// the game ignores keys typed into a text field, so the note field answers its own two: CTRL+ENTER saves, ESC cancels
document.getElementById('fbnote').addEventListener('keydown',function(e){
  if((e.ctrlKey||e.metaKey)&&(e.code==='Enter'||e.code==='NumpadEnter')){ e.preventDefault(); document.getElementById('fbsave').click(); }
  else if(e.code==='Escape'&&!e.repeat){ e.preventDefault(); e.stopPropagation(); document.getElementById('fbcancel').click(); }
});
'@

SubRx @'
var VER='24.49';
'@ @'
var VER='24.50';
'@

$pat = "(?m)^  now:'v24\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.50: FEEDBACK in the pause menu saves a typed note with a screenshot. Check 24.50 fails on v24.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
