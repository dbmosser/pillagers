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

# A RESTORE CODE KEEPS LOCKS AND TROPHIES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
         j:P.junk||{},mi:P.mapIx||0,cd:P.cond||'day',wq:P.wxPick||'any',
'@ @'
         j:P.junk||{},mi:P.mapIx||0,cd:P.cond||'day',wq:P.wxPick||'any',
         // v27.72 (cloud-menus-restore-keeps-locks), CLOUD HUNT 2026-10-15: the stash locks and the trophy case travel with the code, kept short: the locks as a list of
         // item ids, each trophy as the local calendar day it was earned (the case shows only month and day)
         kp:(function(){ var a=[], k; if(P.keep&&typeof P.keep==='object') for(k in P.keep) if(P.keep[k]&&Object.prototype.hasOwnProperty.call(ITEMS,k)) a.push(k); return a; })(),
         tr:(function(){ var q={}, k, t; if(P.trophies&&typeof P.trophies==='object'&&!Array.isArray(P.trophies)) for(k in P.trophies) if(P.trophies[k]&&trophyOf(k)){ t=+P.trophies[k]; if(!(t>864e5)) t=Date.now(); q[k]=Math.floor((t-new Date(t).getTimezoneOffset()*6e4)/864e5); } return q; })(),
'@

SubRx @'
  P.junk=o.j||{}; P.mapIx=o.mi|0; P.cond=(o.cd==='night')?'night':'day';
'@ @'
  P.junk=o.j||{}; P.mapIx=o.mi|0; P.cond=(o.cd==='night')?'night':'day';
  // v27.72 (cloud-menus-restore-keeps-locks), CLOUD HUNT 2026-10-15: THE LOCKS AND THE TROPHIES ARE THE RESTORED CHARACTER'S. Neither was carried nor cleared, so his own
  // code on a fresh browser lost every lock and GOLD HUNTER and OVERSEER DOWN for good, and a code pasted over another character kept that character's locks.
  // Only items and trophies this build knows come through; an older code with neither starts both clean (the v15.00 rule). The locks come as a list of item ids
  // (an object of them is read too); a trophy comes as a day number, set to noon of that day so the case shows the same date in any time zone (a value of 1e7
  // or more is a time in ms and is kept as it is).
  P.keep={}; P.trophies={}; (function(){ var _kk, _kv, _ka=[]; if(o.kp&&typeof o.kp==='object'){ if(Array.isArray(o.kp)) _ka=o.kp.slice(0,500); else for(_kk in o.kp) if(o.kp[_kk]) _ka.push(_kk); }
    for(_kk=0;_kk<_ka.length;_kk++) if(typeof _ka[_kk]==='string'&&Object.prototype.hasOwnProperty.call(ITEMS,_ka[_kk])) P.keep[_ka[_kk]]=1;
    if(o.tr&&typeof o.tr==='object'&&!Array.isArray(o.tr)) for(_kk in o.tr) if(Object.prototype.hasOwnProperty.call(o.tr,_kk)&&trophyOf(_kk)&&o.tr[_kk]){ _kv=+o.tr[_kk]; P.trophies[_kk]=!(_kv>0)?Date.now():(_kv<1e7?_kv*864e5+432e5:_kv); } })();
'@

SubRx @'
var VER='27.71';
'@ @'
var VER='27.72';
'@

$pat = "(?m)^  now:'v27\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.72: A restore code now brings back your stash locks and your trophies. Check 27.72 fails on v27.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
