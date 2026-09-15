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
        if(_rpk&&ITEMS[_rpk]){
          G.bag.push(_rpk);
'@ @'
        if(_rpk&&ITEMS[_rpk]){
          // v15.07, throwables audit finding 5: A GRENADE A PILLAGER PAYS FOR A REVIVE CAN BE THROWN. A Frag, Smoke or Decoy he
          // paid went into the backpack, but doThrow, startCook and the belt throw cell read only G.pouch, so the cell showed x0
          // and the key said none was left. A throwable goes into the pouch now, as it does from a container and the drop kit.
          if(ITEMS[_rpk].use==='throw'&&G.pouch&&G.pouch[ITEMS[_rpk].tk]!==undefined) G.pouch[ITEMS[_rpk].tk]++;
          else G.bag.push(_rpk);
'@
SubRx @'
var VER='15.06';
'@ @'
var VER='15.07';
'@

$pat = "(?m)^  now:'v15\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.07: A GRENADE A PILLAGER PAYS FOR A REVIVE CAN BE THROWN. When a downed pillager you picked up paid you a Frag Charge, Smoke Canister or Decoy Beacon, it went into the backpack, where no key could throw it: the tactical belt kept the old count and the key said none was left. It now adds to the grenade count on the tactical belt, as a grenade from a container does. Check 15.07 picks up a pillager carrying only a Frag Charge and reads the Frag count and the backpack; it fails on v15.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
