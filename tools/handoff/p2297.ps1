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

# WEAK SPOT ONCE PER TARGET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
                  label(en.x,en.y-Math.round(en.r*1.3),'WEAK SPOT',WK.c,0,true);   /* v21.64, HIS NOTE (2026-10-09): OPTIC 2X read as a scope, not a weak point; it says WEAK SPOT, in the weak point colour */
'@ @'
                  /* v22.xx, the raid text rewrite (R46): WEAK SPOT ONCE PER TARGET. A shotgun blast or a fast burst on a vent pushed one
                     WEAK SPOT label per pellet, eight stacked words in one frame that also pushed the loot names out of the 40-label
                     list. The label now shows at most once per target every 0.5 s (en.weakLblT); the damage, the spark, the clank, the
                     hit tick and the count of weak hits stay per pellet. */
                  if(!(en.weakLblT>(G.t||0)-0.5)){ en.weakLblT=(G.t||0); label(en.x,en.y-Math.round(en.r*1.3),'WEAK SPOT',WK.c,0,true); }   /* v21.64, HIS NOTE (2026-10-09): OPTIC 2X read as a scope, not a weak point; it says WEAK SPOT, in the weak point colour */
'@

SubRx @'
  if(G.labels.length>40) G.labels.shift();
'@ @'
  // v22.xx, the raid text rewrite (R46): LOOT NAMES ARE KEPT. At the 40-label cap the oldest label went, and a loot name (his 6 s, v3.51)
  // is usually the oldest, so a fight that called out targets and weak spots pushed out the name of what he had just found. The oldest
  // label without an item is dropped first; only when every older label is a loot name does the oldest loot name go.
  if(G.labels.length>40){
    var _ev=0, _li;
    for(_li=0;_li<G.labels.length-1;_li++) if(!G.labels[_li].ik){ _ev=_li; break; }
    G.labels.splice(_ev,1);
  }
'@

SubRx @'
var VER='22.96';
'@ @'
var VER='22.97';
'@

$pat = "(?m)^  now:'v22\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.97: A shotgun blast on a weak spot now shows WEAK SPOT once instead of once per pellet, and loot names stay up during a fight. Check 22.97 fails on v22.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
