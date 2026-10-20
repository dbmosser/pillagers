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

# DAILY SAVE BACKUPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function storeSet(v){
'@ @'
// v28.xx (cw-cx-dailysave), his Tech answer (2026-10-12): "An automatic daily save backup."
// Raw copies live beside each numbered save, never inside it. Local calendar dates survive reloads and DST.
var DAILY_SAVE_REPORT={state:'not checked',bytes:0,used:0};
function dailySaveAllowed(){
  return !NETP2&&!NETSLOT&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)&&/^salvagerun:profile(?::[2-8])?$/.test(SKEY);
}
function dailySaveDate(d){
  d=d||new Date();
  return d.getFullYear()+'-'+('0'+(d.getMonth()+1)).slice(-2)+'-'+('0'+d.getDate()).slice(-2);
}
function dailySaveKeys(all){
  var out=[],i,k;
  for(i=0;i<localStorage.length;i++){
    k=localStorage.key(i);
    if(k&&/^salvagerun:profile(?::[2-8])?:daily:\d{4}-\d{2}-\d{2}$/.test(k)&&(all||k.indexOf(SKEY+':daily:')===0)) out.push(k);
  }
  return out.sort(function(a,b){ return a.slice(-10).localeCompare(b.slice(-10))||a.localeCompare(b); });
}
function dailySaveDrop(all){
  try{ var ks=dailySaveKeys(all); if(ks.length){ localStorage.removeItem(ks[0]); return true; } }catch(_e){}
  return false;
}
function dailySaveClear(all){
  try{ dailySaveKeys(all).forEach(function(k){ localStorage.removeItem(k); }); }catch(_e){}
}
function dailySaveBytes(){
  var n=0,i,k,v;
  for(i=0;i<localStorage.length;i++){ k=localStorage.key(i); v=localStorage.getItem(k); n+=2*(k.length+(v||'').length); }
  return n;
}
function dailySaveQuota(e){ return !!(e&&(e.name==='QuotaExceededError'||e.name==='NS_ERROR_DOM_QUOTA_REACHED'||e.code===22||e.code===1014)); }
function dailySaveCopy(r,now){
  var info=DAILY_SAVE_REPORT={state:'skipped: separate window or demo',bytes:0,used:0},raw,d,k,ks,i,attempt,reason;
  if(!dailySaveAllowed()) return false;
  try{
    raw=r&&r.value;
    if(typeof raw!=='string'||!raw){ info.state='no saved profile'; return false; }
    info.bytes=raw.length*2;
    d=JSON.parse(raw);
    if(!d||typeof d.credits!=='number'||!isFinite(d.credits)||localStorage.getItem(SKEY)!==raw){ info.state='skipped: unreadable or different save'; return false; }
    k=SKEY+':daily:'+dailySaveDate(now);
    if(localStorage.getItem(k)!==null){ info.state='already kept '+k.slice(-10); info.used=dailySaveBytes(); return false; }
    for(attempt=0;attempt<2;attempt++){
      info.used=dailySaveBytes(); reason='storage full';
      // v28.xx (cw-cx-dailysave): count UTF-16 keys and values, with one profile of headroom (at least 64 KiB) for the next main save.
      if(info.used+2*(k.length+raw.length)+Math.max(65536,info.bytes)<=5*1024*1024){
        try{
          localStorage.setItem(k,raw);
          ks=dailySaveKeys(false);
          for(i=0;i<ks.length-3;i++) localStorage.removeItem(ks[i]);
          info.state='kept '+k.slice(-10); info.used=dailySaveBytes(); return true;
        }catch(e){ if(!dailySaveQuota(e)) throw e; }
      }
      if(attempt===0&&dailySaveDrop(false)) continue;
      break;
    }
    info.state='skipped: '+reason; info.used=dailySaveBytes();
  }catch(_e){ info.state='skipped: storage unavailable or unreadable save'; }
  return false;
}
function dailySaveChoices(now){
  var out=[],ks,i,raw,d,age,today=now||new Date();
  if(!dailySaveAllowed()) return out;
  try{
    ks=dailySaveKeys(false).reverse();
    for(i=0;i<ks.length;i++){
      raw=localStorage.getItem(ks[i]);
      try{ d=JSON.parse(raw); }catch(_e){ continue; }
      if(!d||typeof d.credits!=='number'||!isFinite(d.credits)) continue;
      d=ks[i].slice(-10).split('-');
      age=Math.round((Date.UTC(today.getFullYear(),today.getMonth(),today.getDate())-Date.UTC(+d[0],+d[1]-1,+d[2]))/86400000);
      out.push({key:ks[i],label:age===0?'today':age===1?'yesterday':age>1?age+' days ago':ks[i].slice(-10)});
    }
  }catch(_e2){}
  return out;
}
function storeSet(v){
'@

SubRx @'
  try{ localStorage.setItem(SKEY,v); }catch(e2){ storeWarn(); }
'@ @'
  try{ localStorage.setItem(SKEY,v); }catch(e2){
    // v28.xx (cw-cx-dailysave): the main save always wins, even if a later save grows beyond the reserved headroom.
    if(dailySaveQuota(e2)){
      dailySaveClear(true); DAILY_SAVE_REPORT.state='copies removed: main save needed space';
      try{ localStorage.setItem(SKEY,v); return; }catch(_retry){}
    }
    storeWarn();
  }
'@

SubRx @'
    return storeGet().then(applyLoadedProfile).catch(function(){});
'@ @'
    return storeGet().then(function(r){ dailySaveCopy(r); applyLoadedProfile(r); }).catch(function(){}); // v28.xx (cw-cx-dailysave): keep the stored bytes before migrations.
'@

SubRx @'
  var _rOff=((typeof G!=='undefined'&&G&&!G.over&&!G.sim)||(typeof NET==='object'&&NET&&NET.on&&NET.specG))?' disabled':'';   // v16.64: and while the host runs the raid for his party
'@ @'
  var _rOff=((typeof G!=='undefined'&&G&&!G.over&&!G.sim)||(typeof NET==='object'&&NET&&NET.on&&NET.specG))?' disabled':'';   // v16.64: and while the host runs the raid for his party
  // v28.xx (cw-cx-dailysave): the existing restore row cycles file and the three daily copies; mouse and pad use the same button.
  var _dailyChoices=dailySaveChoices(), _dailyAt=-1;
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">Load a backup file to restore your profile. UNDO brings back the profile you replaced.</div></div>'+
    '<button id="set_restore" style="padding:6px 12px"'+_rOff+'>PICK FILE</button>'+
'@ @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">file or daily copy; undo available</div></div>'+
    (_dailyChoices.length?'<button id="set_restore_source" aria-label="backup source: file" title="choose backup" style="padding:6px 12px;margin-right:8px"'+_rOff+'>file</button>':'')+
    '<button id="set_restore" style="padding:6px 12px"'+_rOff+'>PICK FILE</button>'+
'@

SubRx @'
  document.getElementById('set_restore').onclick=function(){
    var inp=document.createElement('input');
    inp.type='file'; inp.accept='.txt,.json';
    inp.onchange=function(){
      var f=inp.files&&inp.files[0]; if(!f) return;
      var rd=new FileReader();
      rd.onload=function(){
        var d2=null;
        try{ d2=JSON.parse(String(rd.result)); }catch(e2){}
        if(!d2||typeof d2.credits!=='number'){ say('That is not a Pillagers backup.'); return; }
        try{ localStorage.setItem(RESTORE_BACKUP_KEY,JSON.stringify(P)); }catch(e3){}
        storeSet(JSON.stringify(d2));
        // v12.86: the read-back stays, so the profile in memory is the profile in
        // storage even on a host where the reload never happens.
        loadProfile().then(function(){
          finishRestore('Restored. '+(P.runs||0)+' runs, '+'$'+(P.credits||0).toLocaleString()+'.');
        });
      };
      rd.readAsText(f);
    };
    inp.click();
  };
'@ @'
  // v28.xx (cw-cx-dailysave): file and daily restores share validation, the outgoing undo copy and the existing reload path.
  function applyBackupRaw(raw){
    if(_rOff||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return;
    var d2=null,back=JSON.stringify(P);
    try{ d2=JSON.parse(raw); }catch(_e){}
    if(!d2||typeof d2.credits!=='number'||!isFinite(d2.credits)){ say('unreadable backup'); return; }
    try{ localStorage.setItem(RESTORE_BACKUP_KEY,back); }
    catch(_undo){
      if(!dailySaveQuota(_undo)){ say('restore unavailable'); return; }
      dailySaveClear(true);
      try{ localStorage.setItem(RESTORE_BACKUP_KEY,back); }catch(_again){ say('restore skipped: storage full'); return; }
    }
    storeSet(JSON.stringify(d2));
    loadProfile().then(function(){ finishRestore('restored'); });
  }
  var _src=document.getElementById('set_restore_source');
  if(_src) _src.onclick=function(){
    _dailyAt++; if(_dailyAt>=_dailyChoices.length) _dailyAt=-1;
    _src.textContent=_dailyAt<0?'file':_dailyChoices[_dailyAt].label;
    _src.setAttribute('aria-label','backup source: '+_src.textContent);
    document.getElementById('set_restore').textContent=_dailyAt<0?'pick file':'restore';
  };
  document.getElementById('set_restore').onclick=function(){
    if(_rOff||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return;
    if(_dailyAt>=0){
      if(!dailySaveAllowed()) return;
      try{ applyBackupRaw(localStorage.getItem(_dailyChoices[_dailyAt].key)); }catch(_daily){ say('restore unavailable'); }
      return;
    }
    var inp=document.createElement('input');
    inp.type='file'; inp.accept='.txt,.json';
    inp.onchange=function(){
      var f=inp.files&&inp.files[0]; if(!f) return;
      var rd=new FileReader();
      rd.onload=function(){ applyBackupRaw(String(rd.result)); };
      rd.readAsText(f);
    };
    inp.click();
  };
'@

SubRx @'
  L.push('Profile: '+P.runs+' runs, '+P.ext+' extracted, '+P.died+' died, best haul '+P.best+'c, credits '+P.credits+', XP '+(P.xp||0)+', racks '+(P.racks||0)+', pack T'+(P.pack+1)+
    ', notoriety '+(P.notoriety||0)+', stash '+P.stash.length);
'@ @'
  L.push('Profile: '+P.runs+' runs, '+P.ext+' extracted, '+P.died+' died, best haul '+P.best+'c, credits '+P.credits+', XP '+(P.xp||0)+', racks '+(P.racks||0)+', pack T'+(P.pack+1)+
    ', notoriety '+(P.notoriety||0)+', stash '+P.stash.length);
  // v28.xx (cw-cx-dailysave): report skipped copies and the real loaded profile size without changing the profile itself.
  L.push('daily save backup: '+DAILY_SAVE_REPORT.state+'; profile '+DAILY_SAVE_REPORT.bytes+' bytes; local storage '+DAILY_SAVE_REPORT.used+' bytes');
'@

SubRx @'
        try{ localStorage.removeItem(slotKey(armed)+':prerestore'); }catch(e){}
'@ @'
        try{ localStorage.removeItem(slotKey(armed)+':prerestore'); }catch(e){}
        // v28.xx (cw-cx-dailysave): erasing a character also erases its daily copies, as it already erases its undo copy.
        try{ dailySaveKeys(true).forEach(function(k){ if(k.indexOf(slotKey(armed)+':daily:')===0) localStorage.removeItem(k); }); }catch(_dailyErase){}
'@

SubRx @'
var VER='32.91';
'@ @'
var VER='32.92';
'@

$pat = "(?m)^  now:'v32\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.92: Each career save keeps up to three daily copies. Settings restores a daily copy or a file with undo. Full storage quietly skips copies and leaves room for the main save. Check 32.92 fails on v32.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
