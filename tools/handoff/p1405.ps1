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

# SAVING, PROFILE AND SETTINGS AUDIT OF 2026-09-15, finding 4: THE CRASH CATCHER SAVED THE WHOLE PROFILE ON EVERY REPEAT
# OF AN ERROR, AND TWO ALTERNATING ERRORS PUSHED THE OLDER CRASH RECORDS OUT. A repeat within five seconds only bumps
# the count on the last entry, but saveProfile ran every time, and the frame loop re-arms before it runs, so an error
# thrown inside a frame serialised the whole profile, sixty log rows included, about sixty times a second, and the game
# stuttered for as long as it lasted. And the merge compared only the last entry, so two errors taking turns added a new
# entry every frame and within twelve frames pushed out every earlier, different crash, which are the entries the
# report exists to carry. A repeat now merges with any matching entry inside the window, and the profile is saved when
# a new entry is added, or at most once a window for repeats.
SubRx @'
    var now=Date.now(), last=P.crashes[P.crashes.length-1];
    if(last&&last.msg===msg&&last.kind===kind&&(now-last.t)<CRASH_SAME_MS){ last.n=(last.n||1)+1; last.t=now; }
    else{
      P.crashes.push({v:VER,t:now,kind:kind,screen:(typeof state!=='undefined'&&state)?state:'?',msg:msg,where:where,n:1});
      while(P.crashes.length>CRASH_KEEP) P.crashes.shift();
    }
    try{ saveProfile(); }catch(_sp){}
'@ @'
    // v14.05, save audit: a repeat merges with ANY matching entry in the window, not only the last, so two errors taking
    // turns cannot push every earlier crash out; and a repeat saves at most once a window instead of once a frame.
    var now=Date.now(), hit=null;
    for(var _ci=P.crashes.length-1;_ci>=0;_ci--){
      var _ce=P.crashes[_ci];
      if(_ce&&_ce.msg===msg&&_ce.kind===kind&&(now-_ce.t)<CRASH_SAME_MS){ hit=_ce; break; }
    }
    if(hit){ hit.n=(hit.n||1)+1; hit.t=now; }
    else{
      P.crashes.push({v:VER,t:now,kind:kind,screen:(typeof state!=='undefined'&&state)?state:'?',msg:msg,where:where,n:1});
      while(P.crashes.length>CRASH_KEEP) P.crashes.shift();
    }
    if(!hit||!(noteCrash.savedAt>0)||(now-noteCrash.savedAt)>=CRASH_SAME_MS){ noteCrash.savedAt=now; try{ saveProfile(); }catch(_sp){} }
'@
SubRx @'
var VER='14.04';
'@ @'
var VER='14.05';
'@

$pat = "(?m)^  now:'v14\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.05: THE CRASH CATCHER STOPS SAVING EVERY FRAME AND KEEPS OLDER CRASHES. Saving, profile and settings audit of 2026-09-15, finding 4: noteCrash merged a repeat only with the last entry and saved the whole profile on every call, so an error thrown each frame wrote the profile about sixty times a second and two alternating errors pushed every earlier crash out of the twelve kept. A repeat now merges with any matching entry in the window and repeats save at most once a window. Check 14.05 alternates two errors twenty times and requires at most three saves and the older crash kept, with a genuinely new error still saved as the control; it fails on v14.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
