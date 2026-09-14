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

SubRx @'
        if(!Array.isArray(_pc)) _pc=[];
        _pc.push({v:VER,t:Date.now(),kind:kind,screen:'boot',msg:msg,where:where,n:1});
        while(_pc.length>CRASH_KEEP) _pc.shift();
        localStorage.setItem(PRECRASH,JSON.stringify(_pc));
'@ @'
        if(!Array.isArray(_pc)) _pc=[];
        // v14.55, report audit finding 7: A BOOT CRASH REPEATING EVERY FRAME IS ONE ENTRY TOO. Before the profile loads a crash
        // goes to its own list, which never merged a repeat: an error repeating each frame while a slow host storage loaded
        // wrote a new entry and a storage write every frame, and after load up to twelve copies pushed real crashes out. A
        // repeat of the last entry within the window, numbers ignored, is counted on it. The list is read back from storage on
        // every call, so every call writes it, or the count would be lost.
        var _pl=_pc[_pc.length-1], _pnow=Date.now();
        if(_pl&&_pl.kind===kind&&(_pnow-_pl.t)<CRASH_SAME_MS&&String(_pl.msg).replace(/\d+/g,'#')===msg.replace(/\d+/g,'#')){ _pl.n=(_pl.n||1)+1; _pl.t=_pnow; }
        else _pc.push({v:VER,t:_pnow,kind:kind,screen:'boot',msg:msg,where:where,n:1});
        while(_pc.length>CRASH_KEEP) _pc.shift();
        localStorage.setItem(PRECRASH,JSON.stringify(_pc));
'@
SubRx @'
var VER='14.54';
'@ @'
var VER='14.55';
'@

$pat = "(?m)^  now:'v14\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.55: A BOOT CRASH REPEATING EVERY FRAME IS ONE ENTRY TOO. A crash before the profile loads goes to its own list, which added a new entry and a storage write for every repeat, so a fault repeating while slow storage loaded filled the list and pushed real crashes out once merged. A repeat of the last entry, numbers ignored, is now counted on that entry instead. Check 14.55 reports one boot crash repeating eight times with a changing number; it fails on v14.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
