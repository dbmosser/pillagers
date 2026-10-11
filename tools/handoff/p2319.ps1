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

# THE ARMOUR NUMBER FITS ITS BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    bar(16,by-46,280,16,p.armor/armorCap(),'#5aa9e6');
    ctx.font=FS(TYPE.label); ctx.fillStyle='#FFF6DC';
    ctx.fillText('ARMOUR  '+Math.round(p.armor),24,by-33);
'@ @'
    bar(16,by-46,280,16,p.armor/armorCap(),'#5aa9e6');
    // v23.19, parked by the raid text audit of 2026-10-09: THE ARMOUR NUMBER FITS ITS BAR, as the HP number does. At a larger text size
    // the label face grew past the 16 unit bar and stuck out over its top edge into the posture chip. It is never taller than the
    // bar holds now, and then centred in it; at the usual text size nothing changes.
    var _apf=FS(TYPE.label), _apx=parseFloat((/([\d.]+)px/.exec(_apf)||[0,13])[1]), _apm=16*1.08;
    if(_apx>_apm) _apf=_apf.replace(/[\d.]+px/,(Math.round(_apm*10)/10)+'px');
    ctx.font=_apf; ctx.fillStyle='#FFF6DC';
    ctx.fillText('ARMOUR  '+Math.round(p.armor),24,(_apx>_apm)?Math.round(by-46+8+_apm*0.36):by-33);
'@

SubRx @'
var VER='23.18';
'@ @'
var VER='23.19';
'@

$pat = "(?m)^  now:'v23\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.19: At a large text size the ARMOUR number now fits inside its bar. Check 23.19 fails on v23.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
