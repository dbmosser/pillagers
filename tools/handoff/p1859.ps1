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

# PROMPTS NAME THE KEY YOU SET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return fallback===undefined?code:fallback;
}
'@ @'
  // v18.59, from the code comb (2026-10-07): on the keyboard every prompt drawn through here (16 of them name E) said the default
  // key even after CHANGE KEYS moved it; it now names the key the action is on. Unchanged keys read as before.
  try{ if(typeof code==='string'&&keysOf(code)!==code) return keyName(keysOf(code)); }catch(_kl){}
  return fallback===undefined?code:fallback;
}
// v18.59: the Undercroft footer, in the keys as set (WASD, SHIFT and E by default, word for word as before)
function hubFootKeys(s){
  var n=function(c){ try{ return keyName(keysOf(c)); }catch(_k){ return c; } };
  return String(s).replace('WASD WALK',n('KeyW')+n('KeyA')+n('KeyS')+n('KeyD')+' WALK').replace('SHIFT JOG',n('ShiftLeft')+' JOG').replace(/\bE (USE STATION|TAKE THE DROPPED ITEM)/g,function(_m,w){ return n('KeyE')+' '+w; });
}
'@

SubRx @'
ctx.fillText('WASD WALK  
'@ @'
ctx.fillText(hubFootKeys('WASD WALK  
'@

SubRx @'
E TAKE THE DROPPED ITEM':''),W/2,H-16);   // v18.25: and the trade key while a party is on
'@ @'
E TAKE THE DROPPED ITEM':'')),W/2,H-16);   // v18.25: and the trade key while a party is on; v18.59: in the keys as set
'@

SubRx @'
var VER='18.58';
'@ @'
var VER='18.59';
'@

$pat = "(?m)^  now:'v18\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.59: After you move a key in CHANGE KEYS, the on-screen prompts name the new key. Check 18.59 fails on v18.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
