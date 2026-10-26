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

# NO FROZEN DEATH IN SUPERHOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v6.73, his note; rewritten v7.23: time stops DEAD unless an input is live -
'@ @'
  var _dtLive=dt;   // v28.xx (cw-shdeath): the frame time before Superhot may stop it below; the death beat keeps its own clock on it
  // v6.73, his note; rewritten v7.23: time stops DEAD unless an input is live -
'@

SubRx @'
    // the death beat: the world keeps moving underwater-slow, you do not
    G.deathBeat-=dt;
    msgTick(dt);   // v22.36 (R12): the lanes keep time in the death beat
    var bdt=netUpShared()?dt:dt*0.25;   // v16.04: in a shared co-op raid the slow-down is not put on the world the party is still playing in
    G.t+=bdt;
    refreshVseg(); updateEnts(bdt); updateBullets(bdt); updateThrowables(bdt);
    if(G.shake>0) G.shake=Math.max(0,G.shake-dt*26);
'@ @'
    // the death beat: the world keeps moving underwater-slow, you do not
    // v28.xx (cw-shdeath), HIS NOTE (2026-10-25, played with Superhot on): "weird noise lingering". With Superhot on the gate above sets dt to 0 on
    // every frame with no input, and a dead man holds none, so the beat counted down by nothing: the screen held on its first frame, the card never
    // came and the room tone stayed under the death duck until he pressed something. The beat now keeps its own clock on the frame time (_dtLive),
    // so it ends in its 1.5 s with or without input. Solo, time moves as if he acts (the world underwater-slow and the frame draw, as with Superhot
    // off). In a shared raid the world under it stays on the party clock (dt): a dead man moves nobody's world, and the sa flag this window sends a
    // teammate is still its own input only. With Superhot off, or anyone acting, _dtLive is dt and nothing changes.
    var _dbt=_dtLive;
    if(!netUpShared()) dt=_dbt;
    G.deathBeat-=_dbt;
    msgTick(_dbt);   // v22.36 (R12): the lanes keep time in the death beat
    var bdt=netUpShared()?dt:dt*0.25;   // v16.04: in a shared co-op raid the slow-down is not put on the world the party is still playing in
    G.t+=bdt;
    refreshVseg(); updateEnts(bdt); updateBullets(bdt); updateThrowables(bdt);
    if(G.shake>0) G.shake=Math.max(0,G.shake-_dbt*26);
'@

SubRx @'
var VER='34.85';
'@ @'
var VER='34.86';
'@

$pat = "(?m)^  now:'v34\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.86: With Superhot on, a death no longer freezes until you press something: the death beat plays out and the card comes up on its own. Watch for: in Superhot the world now moves slowly under the death fade, as it does with Superhot off. Check 34.86 fails on v34.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
