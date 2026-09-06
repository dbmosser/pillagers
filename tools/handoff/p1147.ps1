$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE CRASH CATCHER SAVED THE DEFAULT PROFILE OVER THE REAL SAVE. noteCrash ended
# with saveProfile, and P is the file-scope default until applyLoadedProfile sets
# P=d, which only happens when loadProfile resolves near the end of the file. Any
# uncaught error thrown at file scope between the catcher and that call, or
# during the read, wrote {credits:900,...} over the saved character. A crash
# before the read now goes to its own key and is merged in after the read.
SubRx @'
var CRASH_KEEP=12, CRASH_SAME_MS=5000, crashTold=false;
'@ @'
var CRASH_KEEP=12, CRASH_SAME_MS=5000, crashTold=false;
// v11.47: the profile is not READ until loadProfile resolves. A crash before
// that must never call saveProfile, which would write the file-scope default P
// over a real save. It goes to its own key and is merged in after the read.
var PLOADED=false, PRECRASH='salvagerun:precrash';
'@

SubRx @'
    where=String(where||'').replace(/\s+/g,' ').slice(0,200);
'@ @'
    where=String(where||'').replace(/\s+/g,' ').slice(0,200);
    if(!PLOADED){
      try{
        var _pc=[]; try{ _pc=JSON.parse(localStorage.getItem(PRECRASH)||'[]'); }catch(_p0){ _pc=[]; }
        if(!Array.isArray(_pc)) _pc=[];
        _pc.push({v:VER,t:Date.now(),kind:kind,screen:'boot',msg:msg,where:where,n:1});
        while(_pc.length>CRASH_KEEP) _pc.shift();
        localStorage.setItem(PRECRASH,JSON.stringify(_pc));
      }catch(_p1){}
      return;
    }
'@

# The BOOT read, not the re-read inside the restore path (32606): anchored on
# the boot call plus the comment that only it carries.
SubRx @'
loadProfile().then(function(){
  // Seed both the target and the eased value from the saved profile, or the
'@ @'
loadProfile().then(function(){
  // v11.47: the profile is read; the crash catcher may save from here on, and any
  // crash caught before the read is merged in now and its own key cleared.
  PLOADED=true;
  try{
    var _pcm=JSON.parse(localStorage.getItem(PRECRASH)||'[]');
    if(Array.isArray(_pcm)&&_pcm.length){
      if(!Array.isArray(P.crashes)) P.crashes=[];
      for(var _pi=0;_pi<_pcm.length;_pi++) P.crashes.push(_pcm[_pi]);
      while(P.crashes.length>CRASH_KEEP) P.crashes.shift();
      localStorage.removeItem(PRECRASH);
      try{ saveProfile(); }catch(_pm){}
    }
  }catch(_pc2){}
  // Seed both the target and the eased value from the saved profile, or the
'@

# STAMPS.
SubRx @'
var VER='11.46';
'@ @'
var VER='11.47';
'@
SubRx @'
var WHATSNEW_VER='11.46';
'@ @'
var WHATSNEW_VER='11.47';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CRASH WHILE THE GAME IS STILL LOADING CAN NO LONGER WIPE YOUR SAVE. If something broke before your character was read in, the crash catcher used to write a blank starting profile over the real one. It now keeps the note aside and adds it to your report once your character is loaded.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.46:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.46 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.46:[^']*'",{ param($m) "now:'v11.47: the crash catcher saved the default profile over the real save. noteCrash ended with saveProfile, and P is the file-scope default until applyLoadedProfile sets P=d when loadProfile resolves near the end of the file; any uncaught error at file scope between the catcher and that call, or during the read, wrote credits 900 over the saved character. A PLOADED flag is set when the read resolves; before it a crash is written to its own key, salvagerun:precrash, and merged into P.crashes after the read. From the v11.46 audit, P0.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
