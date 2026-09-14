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
function applyLoadedProfile(r){
      if(r&&r.value){ var d=JSON.parse(r.value);
'@ @'
function applyLoadedProfile(r){
      // v14.43, title and saves audit finding 3: A SAVE THE LOADER CANNOT READ IS KEPT BEFORE IT IS REPLACED. Stored data that
      // will not parse, or has no numeric credits, is ignored below, and boot then saves the fresh character over that key, so
      // the old data was gone with no message. The raw value is copied aside under its own key first.
      if(r&&r.value){ var _rdOk=false; try{ var _rd0=JSON.parse(r.value); _rdOk=!!(_rd0&&typeof _rd0.credits==='number'); }catch(_rpe){}
        if(!_rdOk){ try{ localStorage.setItem(SKEY+':unreadable',String(r.value)); }catch(_rue){} } }
      if(r&&r.value){ var d=JSON.parse(r.value);
'@
SubRx @'
        return {name:(d.pname||'PILLAGER'),runs:d.runs||0,credits:d.credits||0,xp:d.xp||0};
      }catch(e){ return null; }
'@ @'
        if(!d||typeof d.credits!=='number') return {name:'UNREADABLE',runs:0,credits:0,xp:0};
        return {name:(d.pname||'PILLAGER'),runs:d.runs||0,credits:d.credits||0,xp:d.xp||0};
      }catch(e){
        // v14.43: a save holding something unreadable is not an empty save. It is listed as UNREADABLE, so CREATE A NEW SAVE
        // does not pick it and write a fresh character over it.
        try{ if(localStorage.getItem(slotKey(sn))) return {name:'UNREADABLE',runs:0,credits:0,xp:0}; }catch(_se){}
        return null; }
'@
SubRx @'
var VER='14.42';
'@ @'
var VER='14.43';
'@

$pat = "(?m)^  now:'v14\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.43: A SAVE THE GAME CANNOT READ IS NOT QUIETLY REPLACED. Data in a save that would not parse was ignored, boot saved a fresh character over it, and the title listed that save as empty so CREATE A NEW SAVE picked it. The loader now copies unreadable data aside first, and the title lists such a save as UNREADABLE. Check 14.43 loads unreadable data through the loader and lists a save holding it; it fails on v14.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
