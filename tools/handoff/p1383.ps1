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

# COMBAT AND PLAYER STATE AUDIT OF 2026-09-14, finding 4: THE RELOAD STOPPED WHILE YOU ROLLED, AND
# WAITED FOR YOU WHILE YOU WERE DOWN. The only reload tick sits on the standing path of
# updatePlayer, below the roll return and the downed return, so every 0.38 second roll froze the
# bar and a reload started before going down finished after he stood up again. Healing was kept
# running through a roll at v3-era for this reason, and v11.83 and v13.75 moved the stim and
# drink clocks above both returns. The reload tick moves into tickReload, called where it was and
# again in the roll branch beside tickHeal; going down lets the reload go.
SubRx @'
  if(p.reloading>0){
    p.reloading-=dt*1000;
    if(p.reloading<=0){
      var take=Math.min(p.wep.mag-p.ammo,p.reserve);
      p.ammo+=take; p.reserve-=take; say('Reloaded');
      if(!G.sim) blip('reloadin');   // v10.56: the bolt goes home
    }
  }
'@ @'
  tickReload(dt);   // v13.83: also run from the roll branch, so a roll does not freeze it
'@
SubRx @'
function tickHeal(dt){
'@ @'
// v13.83, combat audit: the player's reload clock, in one place so the roll branch runs it too.
function tickReload(dt){
  var p=G.player;
  if(p.reloading>0){
    p.reloading-=dt*1000;
    if(p.reloading<=0){
      var take=Math.min(p.wep.mag-p.ammo,p.reserve);
      p.ammo+=take; p.reserve-=take; say('Reloaded');
      if(!G.sim) blip('reloadin');   // v10.56: the bolt goes home
    }
  }
}
function tickHeal(dt){
'@
SubRx @'
    // NOTHING, 30 stayed 30. Makes no seeded draw, so the stream is untouched.
    tickHeal(dt);
'@ @'
    // NOTHING, 30 stayed 30. Makes no seeded draw, so the stream is untouched.
    tickHeal(dt);
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
'@
SubRx @'
    if(G.trade){ G.trade=null; G.pedLock=1; }
'@ @'
    if(G.trade){ G.trade=null; G.pedLock=1; }
    p.reloading=0;   // v13.83, combat audit: a reload does not wait on the floor to finish after he stands
'@
SubRx @'
var VER='13.82';
'@ @'
var VER='13.83';
'@

$pat = "(?m)^  now:'v13\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.83: A ROLL DOES NOT FREEZE THE RELOAD. Combat and player state audit of 2026-09-14, finding 4: the only reload tick was on the standing path of updatePlayer, below the roll and downed returns, so each roll froze the reload bar and a reload started before going down finished after he stood up. The tick moves into tickReload, run where it was and again in the roll branch beside tickHeal, and going down lets the reload go. Check 13.83 starts an Auto Rifle reload and rolls through four frames, requiring the reload to count down, with the same frames standing as the control and going down clearing it; it fails on v13.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
