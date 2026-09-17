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
    var rState=(p.jam>0)?'jam':(p.reloading>0?'reload':(p.ammo<=0?(p.reserve<=0?'dry':'empty'):''));
'@ @'
    // v15.41, hud audit finding: WITH BARE HANDS UP THE RETICLE NEVER SAYS EMPTY - R OR NO AMMO. The state read only the rounds
    // loaded, and Bare Hands load none (a magazine of 0). Carrying one gun and pressing 2, or putting the only gun in the
    // backpack, leaves Bare Hands up with nothing loaded and the gun's rounds still in reserve, so the reticle turned into the
    // struck-through cross saying EMPTY - R (NO AMMO once the reserve ran out) while the corner read MELEE and the punch worked.
    // R does nothing there, because a reload needs fewer rounds loaded than the magazine holds and 0 is not below 0. A weapon
    // with no magazine is never empty now, so Bare Hands keep the plain cross. JAMMED, the reload ring and every gun are unchanged.
    var rState=(p.jam>0)?'jam':(p.reloading>0?'reload':((p.ammo<=0&&!(p.wep&&p.wep.mag===0))?(p.reserve<=0?'dry':'empty'):''));
'@
SubRx @'
var VER='15.40';
'@ @'
var VER='15.41';
'@

$pat = "(?m)^  now:'v15\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.41: WITH BARE HANDS UP THE RETICLE NEVER SAYS EMPTY - R OR NO AMMO. Carrying one gun and pressing 2 brought Bare Hands up with nothing loaded, and the reticle turned into the struck-through cross saying EMPTY - R, or NO AMMO once the reserve ran out, while the corner read MELEE, the punch worked and R did nothing. A weapon with no magazine is never empty now, so Bare Hands keep the plain cross and every gun still warns as before. Check 15.41 presses key 2 with one gun carried, presses R and reads the drawn HUD with rounds in reserve and with none, the empty gun on key 1 as the control; it fails on v15.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
