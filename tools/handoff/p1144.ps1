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

# THE RIG-BUYBACK MIGRATION SAVED DEFAULTS OVER THE PLAYER'S CONFIG. mig945 runs
# during loadProfile, before the cfgv block below has loaded CFG from the saved
# P.cfg. It called saveProfile, which does P.cfg=CFG; P.cfgv=17 - and CFG is
# still the file-scope default at that point, so the player's saved dials were
# wiped and cfgv stamped 17, which then made the cfgv block skip every migration.
# REPRODUCED: a pre-mig945 profile carrying ambient 250 loaded back as 190, cfgv
# 12 became 17. storeSet persists the buyback and the stamp WITHOUT touching cfg,
# so the saved config reaches the cfgv block intact.
SubRx @'
if(!P.mig945){ rigBuyback(P); P.mig945=1; saveProfile(); }
'@ @'
if(!P.mig945){ rigBuyback(P); P.mig945=1;
  // v11.42: persist through storeSet, NOT saveProfile. saveProfile writes
  // P.cfg=CFG;P.cfgv=17, and here CFG is still the file-scope default because
  // the cfgv block below has not loaded the saved P.cfg yet, so saveProfile wiped
  // the player's dials and stamped cfgv 17, skipping every cfgv migration. storeSet
  // writes P as it stands, saved cfg and cfgv intact, and still locks in the buyback.
  storeSet(JSON.stringify(P)); }
'@

# EXTRACT the post-load body into a named function so a synchronous check can
# drive the REAL loader instead of a copy of it. Pure extraction: storeGet().
# then(applyLoadedProfile) runs the identical body. HEAD:
SubRx @'
function loadProfile(){
  try{
    return storeGet().then(function(r){
'@ @'
function applyLoadedProfile(r){
'@

# TAIL: close applyLoadedProfile and rebuild loadProfile around it.
SubRx @'
    }).catch(function(){});
  }catch(e){}
  return Promise.resolve();
}
'@ @'
}
function loadProfile(){
  try{
    return storeGet().then(applyLoadedProfile).catch(function(){});
  }catch(e){}
  return Promise.resolve();
}
'@

# STAMPS.
SubRx @'
var VER='11.43';
'@ @'
var VER='11.44';
'@
SubRx @'
var WHATSNEW_VER='11.43';
'@ @'
var WHATSNEW_VER='11.44';
'@
SubRx @'
  'THE IN-GAME WORDING IS UPDATED. A batch of edits to shop copy, item descriptions, settings and menus is now built into the game.',
'@ @'
  'YOUR SETTINGS SURVIVE A LOAD AGAIN. A one-time cleanup that runs when the game opens an older save was saving the default settings over yours before your own were read back, so a returning player could find the sliders reset. Your saved settings are kept now.',
  'THE IN-GAME WORDING IS UPDATED. A batch of edits to shop copy, item descriptions, settings and menus is now built into the game.',
'@
SubRx @'
  now:'v11.43: his text edits refreshed to the latest set from his export, 71 now, adding the four title-screen and tutorial lines he rewrote after the v11.42 snapshot (the intro card, the loot/extract/lift lines). Same bake as v11.42: TXSHIP default map plus derived TXPSHIP patterns, consulted by TX under his P.txt, encoding normalized. From his instruction to pick the edits up permanently while he was still editing.',
'@ @'
  now:'v11.44: the v9.45 rig-buyback migration (mig945) ran saveProfile during loadProfile, before the cfgv block had loaded CFG from the saved P.cfg; saveProfile writes P.cfg=CFG and P.cfgv=17, and CFG was still the file-scope default, so a returning saves config was wiped and cfgv stamped 17, skipping every cfgv migration. Reproduced: a pre-mig945 profile with ambient 250 loaded back as 190. It now persists through storeSet, which writes P as it stands with the saved cfg and cfgv intact, and still locks in the buyback. The load body was factored into applyLoadedProfile so a check drives the real loader. From the contract agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
