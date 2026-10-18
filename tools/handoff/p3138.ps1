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

# ARMOUR AND STAMINA BARS ONE HEIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    bar(16,by-46,HBW,16,p.armor/armorCap(),'#5aa9e6');
'@ @'
    bar(16,by-50,HBW,16,p.armor/armorCap(),'#5aa9e6');   /* v28.xx (cw-barheight), the critic (2026-10-19): 'use three bars of the same height with the same gaps'. Armour and stamina are both 16 high with a 5 gap (stamina was 12), health stays the tall hero bar */
'@

SubRx @'
  bar(16,by-25,HBW,12,p.stam/100,_stc);
'@ @'
  bar(16,by-29,HBW,16,p.stam/100,_stc);   /* v28.xx (cw-barheight): 16 high like the armour bar, same bottom edge as before */
'@

SubRx @'
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+HBW+8,by-15);
'@ @'
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+HBW+8,by-17);   /* v28.xx (cw-barheight): centred on the taller bar */
'@

SubRx @'
  var _up=(p.armor>0)?(46+LH(5)):(25+LH(5));
'@ @'
  var _up=(p.armor>0)?(50+LH(5)):(29+LH(5));   /* v28.xx (cw-barheight): the taller bars lift the chip 4 */
'@

SubRx @'
    ctx.fillText('ARMOUR  '+Math.round(p.armor),24,(_apx>_apm)?Math.round(by-46+8+_apm*0.36):by-33);
'@ @'
    ctx.fillText('ARMOUR  '+Math.round(p.armor),24,(_apx>_apm)?Math.round(by-50+8+_apm*0.36):by-37);   /* v28.xx (cw-barheight): follows the bar */
'@

SubRx @'
var VER='31.37';
'@ @'
var VER='31.38';
'@

$pat = "(?m)^  now:'v31\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.38: Armour and stamina bars are both 16 high with the same gap; health stays the tall hero bar. Check 31.38 fails on v31.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
