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

# TAB CLOSES THE KEYS WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ev.repeat&&ev.code==='Escape') return;
  if(KEYS.pad){ if(ev.code==='Escape'){ if(PADB.waiting!==null){ PADB.waiting=null; keysRender(); } else m.classList.remove('on'); } return; }   // v26.xx (padbind): in pad mode only ESC means anything on the keyboard
  if(KEYS.waiting){ if(ev.code!=='Escape'){ if(!keysBind(KEYS.waiting,ev.code)){ keysRender(); return; } } KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r3){} }   // v25.xx (keyremap): a reserved key says so and the press keeps waiting
  else if(ev.code==='Escape'){ m.classList.remove('on'); }
'@ @'
  // v27.76 (cloud-menus-tab-closes-keys), CLOUD HUNT 2026-10-15: his v13.44 ruling is TAB DOES WHAT ESCAPE DOES, but this window swallowed TAB and acted only on ESC, so TAB
  // could not shut the Keys or Pad buttons window or cancel a waiting press. TAB is reserved (keysBind), so it now means exactly what ESC means here.
  var _kEsc=(ev.code==='Escape'||ev.code==='Tab');
  if(ev.repeat&&_kEsc) return;
  if(KEYS.pad){ if(_kEsc){ if(PADB.waiting!==null){ PADB.waiting=null; keysRender(); } else m.classList.remove('on'); } return; }   // v26.xx (padbind): in pad mode only ESC (or TAB) means anything on the keyboard
  if(KEYS.waiting){ if(!_kEsc){ if(!keysBind(KEYS.waiting,ev.code)){ keysRender(); return; } } KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r3){} }   // v25.xx (keyremap): a reserved key says so and the press keeps waiting
  else if(_kEsc){ m.classList.remove('on'); }
'@

SubRx @'
var VER='27.75';
'@ @'
var VER='27.76';
'@

$pat = "(?m)^  now:'v27\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.76: TAB now closes the Keys and Pad buttons windows, as ESC does. Check 27.76 fails on v27.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
