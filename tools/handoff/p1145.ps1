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

# THE FLOOR KEYS ANSWERED ON THE TITLE SCREEN. state is 'hub' from boot and the
# title is on via its HTML class - showScreen('title') is never called - so the
# hub keydown branch was live over the title: P or ESC opened the pause box over
# it, and ENTER stamped WNSEEN (dismissing the NEW IN card before it was shown)
# in the same press that the title's own listener used to start the game.
# REPRODUCED on the boot title: one KeyP on window, pause box opens, title stays.
# A title guard on both branches. The title's own ENTER/Space listener (33237)
# is separate and still starts the game.
SubRx @'
    keys[e.code]=true;
    // v6.67, his note: ENTER dismisses the update log. Taken before anything else on
    // the floor, and it returns, so the key cannot also do the thing behind the card.
    if((e.code==='Enter'||e.code==='NumpadEnter')&&!WNSEEN&&!e.repeat){
'@ @'
    keys[e.code]=true;
    // v11.45: the title screen sits over the floor with state still 'hub', so the
    // floor keys below must not answer while it is up. ENTER there belongs to the
    // title's own start listener; P and ESC must not raise the pause box over it.
    var _titleUp=!!(document.getElementById('title')&&document.getElementById('title').classList.contains('on'));
    // v6.67, his note: ENTER dismisses the update log. Taken before anything else on
    // the floor, and it returns, so the key cannot also do the thing behind the card.
    if((e.code==='Enter'||e.code==='NumpadEnter')&&!WNSEEN&&!e.repeat&&!_titleUp){
'@
SubRx @'
    if((e.code==='Escape'||e.code==='KeyP')&&!e.repeat&&!document.querySelector('.modal.on')&&
       !document.querySelector('.imenu')&&!document.getElementById('hub').classList.contains('on')){
'@ @'
    if((e.code==='Escape'||e.code==='KeyP')&&!e.repeat&&!_titleUp&&!document.querySelector('.modal.on')&&
       !document.querySelector('.imenu')&&!document.getElementById('hub').classList.contains('on')){
'@

# STAMPS.
SubRx @'
var VER='11.44';
'@ @'
var VER='11.45';
'@
SubRx @'
var WHATSNEW_VER='11.44';
'@ @'
var WHATSNEW_VER='11.45';
'@
SubRx @'
  'YOUR SETTINGS SURVIVE A LOAD AGAIN. A one-time cleanup that runs when the game opens an older save was saving the default settings over yours before your own were read back, so a returning player could find the sliders reset. Your saved settings are kept now.',
'@ @'
  'THE TITLE SCREEN NO LONGER ANSWERS THE FLOOR KEYS. Pressing P or ESC on the title screen used to open the pause box over it, and ENTER to start could quietly dismiss the NEW IN card before you saw it. The title keeps its own keys now: ENTER or SPACE starts, nothing else.',
  'YOUR SETTINGS SURVIVE A LOAD AGAIN. A one-time cleanup that runs when the game opens an older save was saving the default settings over yours before your own were read back, so a returning player could find the sliders reset. Your saved settings are kept now.',
'@
SubRx @'
  now:'v11.44: the v9.45 rig-buyback migration (mig945) ran saveProfile during loadProfile, before the cfgv block had loaded CFG from the saved P.cfg; saveProfile writes P.cfg=CFG and P.cfgv=17, and CFG was still the file-scope default, so a returning saves config was wiped and cfgv stamped 17, skipping every cfgv migration. Reproduced: a pre-mig945 profile with ambient 250 loaded back as 190. It now persists through storeSet, which writes P as it stands with the saved cfg and cfgv intact, and still locks in the buyback. The load body was factored into applyLoadedProfile so a check drives the real loader. From the contract agent.',
'@ @'
  now:'v11.45: the floor keys answered on the title screen. state is hub from boot and the title is on via its HTML class (showScreen(title) is never called), so the hub keydown branch was live over the title: P or ESC opened the pause box over it, and ENTER stamped WNSEEN in the same press the title listener used to start. The earlier not-reproduced verdict was the probe calling __showScreen(title), which sets state=title and disarms the branch. Reproduced on the boot title with one KeyP on window. A _titleUp guard on both branches; the title keeps its own ENTER/Space start. Closes the STILL OPEN title-keys line.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
