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

# A RESTORE CODE KEEPS THE CODEX AND GUN KILLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
         ac:achForCode(), an:{r:(P.achN&&P.achN.raider)|0,m:(P.achN&&P.achN.mach)|0},
'@ @'
         ac:achForCode(), an:{r:(P.achN&&P.achN.raider)|0,m:(P.achN&&P.achN.mach)|0},
         // v27.71 (cloud-menus-restore-keeps-codex), CLOUD HUNT 2026-10-15: the ARMORY codex (found guns) and the kills with each gun travel with the code in one short
         // field: every found gun is a key, its value the kills with it (0 for found with no kills), plus any other gun that has kills
         gk:(function(){ var q={}, k, n; if(P.codex&&typeof P.codex==='object') for(k in P.codex) if(P.codex[k]&&k!=='fists'&&Object.prototype.hasOwnProperty.call(WEAPONS,k)&&ITEMS['gun_'+k]) q[k]=0;
           if(P.gunKills&&typeof P.gunKills==='object') for(k in P.gunKills){ n=(+P.gunKills[k])|0; if(n>0&&Object.prototype.hasOwnProperty.call(WEAPONS,k)) q[k]=n; } return q; })(),
'@

SubRx @'
  P.ach={}; P.achN={raider:Math.max(0,(o.an&&o.an.r)|0),mach:Math.max(0,(o.an&&o.an.m)|0)}; P.achScan=1; P.gambleLog=[];
'@ @'
  // v27.71 (cloud-menus-restore-keeps-codex), CLOUD HUNT 2026-10-15: THE ARMORY CODEX AND THE GUN KILLS ARE THE RESTORED CHARACTER'S. Neither was carried nor cleared,
  // so a code pasted over another character kept that character's found guns and gun kills (CENTURION earned again from them), and his own code on a fresh
  // browser lost every found gun he no longer holds and all his gun kills. The code's gk holds both: every gun key this build knows that the codex lists is filed
  // as found, and each count above 0 is its kills. An older code with none starts both clean. A restored entry is an old find (1), so the codex does not mark
  // it NEW against the replaced character's last look.
  P.codex={}; P.gunKills={}; (function(){ var _ck, _cn; if(o.gk&&typeof o.gk==='object'&&!Array.isArray(o.gk)) for(_ck in o.gk) if(Object.prototype.hasOwnProperty.call(o.gk,_ck)&&Object.prototype.hasOwnProperty.call(WEAPONS,_ck)){
    if(_ck!=='fists'&&ITEMS['gun_'+_ck]) P.codex[_ck]=1; _cn=Math.floor(+o.gk[_ck]); if(_cn>0&&_cn<1e7) P.gunKills[_ck]=_cn; } })();
  P.ach={}; P.achN={raider:Math.max(0,(o.an&&o.an.r)|0),mach:Math.max(0,(o.an&&o.an.m)|0)}; P.achScan=1; P.gambleLog=[];
'@

SubRx @'
var VER='27.70';
'@ @'
var VER='27.71';
'@

$pat = "(?m)^  now:'v27\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.71: A restore code now brings back your ARMORY codex and the kills with each gun. Check 27.71 fails on v27.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
