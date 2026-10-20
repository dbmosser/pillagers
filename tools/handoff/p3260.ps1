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

# BETTER COPY IN HAND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!h||h.o.gk===gk||!beltGunLow(h.o.w,found)) return null;
'@ @'
  if(!h||!beltGunLow(h.o.w,found)) return null;   // v28.xx (cw-cx-heldcopy-o06): his 3.18 c: a better copy swaps in at once, including the same model in DEMO.
'@

SubRx @'
  // v8.04, audit: a duplicate of the gun in your HANDS never takes a slot.
'@ @'
  // v28.xx (cw-cx-heldcopy-o06): his 3.18 c: a better same-model find uses the class swap before duplicate guards.
  if(xo&&xo.found&&it.use==='gun'&&it.gk&&!G.hubFloor){
    var _copySlots=hotbarSlots(), _copyHeld=gunClassHeld(_copySlots,gunClassOf(it.gk));
    if(_copyHeld&&_copyHeld.o.gk===it.gk&&beltGunLow(_copyHeld.o.w,xo.found)){
      G.hotAssign=G.hotAssign||{};
      return gunClassPlace(key,quiet,_copySlots,xo);
    }
  }
  // v8.04, audit: a duplicate of the gun in your HANDS never takes a slot.
'@

SubRx @'
var VER='32.59';
'@ @'
var VER='32.60';
'@

$pat = "(?m)^  now:'v32\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.60: A better copy upgrades the gun in hand immediately in DEMO and CAREER. Check 32.60 fails on v32.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
