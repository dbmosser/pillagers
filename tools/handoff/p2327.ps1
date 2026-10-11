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

# ARCADE: EVERY DIAL PUT BACK ON LEAVING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeSandboxIn(role){
  if(ARCADE.on) return false;
'@ @'
// v23.27 (arcfixb), from the review of the arcade core: EVERY DIAL IS PUT BACK WHEN THE ARCADE IS LEFT. The sandbox kept his profile
// aside but not the live dials (CFG), and only the two arcade overlay dials were put back at leave. A guest who opened Settings
// from the pause box (damage, kid mode, volume, text size, a preset) or moved a tuning console slider changed the live dials, and
// the save at leave wrote every one of them into his profile. Now the whole set of dials is copied when the sandbox goes on and
// put back in place (keys added in the arcade removed) before that save, and the volume is applied again.
function arcadeCfgCopy(c){ var o={}, k; for(k in c) if(Object.prototype.hasOwnProperty.call(c,k)) o[k]=(c[k]&&typeof c[k]==='object')?JSON.parse(JSON.stringify(c[k])):c[k]; return o; }
function arcadeCfgPut(o){
  var k;
  for(k in CFG) if(Object.prototype.hasOwnProperty.call(CFG,k)&&!Object.prototype.hasOwnProperty.call(o,k)) delete CFG[k];
  for(k in o) if(Object.prototype.hasOwnProperty.call(o,k)) CFG[k]=o[k];
  return true;
}
function arcadeSandboxIn(role){
  if(ARCADE.on) return false;
'@

SubRx @'
  ARCADE.realJs=js; ARCADE.on=1;
'@ @'
  ARCADE.cfgAll=arcadeCfgCopy(CFG);   // v23.27 (arcfixb)
  ARCADE.realJs=js; ARCADE.on=1;
'@

SubRx @'
    ARCADE.cfg0=null;
  }
  ARCADE.on=0;
'@ @'
    ARCADE.cfg0=null;
  }
  if(ARCADE.cfgAll){ arcadeCfgPut(ARCADE.cfgAll); ARCADE.cfgAll=null; try{ volApply(); }catch(_va){} }   // v23.27 (arcfixb): every dial as it was before the arcade
  ARCADE.on=0;
'@

SubRx @'
var VER='23.26';
'@ @'
var VER='23.27';
'@

$pat = "(?m)^  now:'v23\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.27: Leaving the arcade puts every game dial back as it was, whatever a guest changed in Settings. Check 23.27 fails on v23.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
