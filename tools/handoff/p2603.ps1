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

# BELT: SELECTED GRENADE AND HEAL RINGED IN GOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.strokeStyle=dragOver?'#ffc04a':(on?'#ffc04a':((_hr&&RCOL[_hr]&&!_bgDim)?hexA(RCOL[_hr],.55):'rgba(140,152,163,.35)'));
      ctx.lineWidth=(dragOver||on)?2:1;
'@ @'
      // v26.xx (beltselring), HIS ORDER 2026-10-13: "selected throwables/heals should be outlined in gold just like the selected gun is". The gold ring of
      // the gun in hand (on) is now also drawn on the grenade G throws (_gSel, the cell wearing the G cap) and on the heal H uses (_mSel, the cell wearing
      // the H cap), so up to three keys wear it at once: the gun in hand, the chosen grenade and the chosen heal. Same colour, width and corner. The other
      // grenade, the other heal, the plate and a key with nothing on it get none, and the Undercroft floor belt (no G or H there) keeps the gun ring alone.
      var _selOut=on||(state!=='hub'&&(S.count|0)>0&&((S.kind==='throw'&&!!S.icon&&!!_gSel&&S.icon===_gSel)||((S.kind==='heal'||S.kind==='stim')&&q===_mSel)));
      ctx.strokeStyle=dragOver?'#ffc04a':(_selOut?'#ffc04a':((_hr&&RCOL[_hr]&&!_bgDim)?hexA(RCOL[_hr],.55):'rgba(140,152,163,.35)'));
      ctx.lineWidth=(dragOver||_selOut)?2:1;
'@

SubRx @'
var VER='26.02';
'@ @'
var VER='26.03';
'@

$pat = "(?m)^  now:'v26\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.03: The belt now rings the chosen grenade and the chosen heal in gold, like the gun in hand. Check 26.03 fails on v26.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
