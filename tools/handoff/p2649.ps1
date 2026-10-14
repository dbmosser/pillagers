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

# COLOUR-BLIND MODES FOR RARITY AND SIDES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings8), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): COLOUR-BLIND MODES for the rarity colours and the enemy and ally
  // marks, in the new ACCESSIBILITY section. OFF is the game as it was. Each mode swaps two tables (cbApply): the five rarity colours (the world, the
  // belt, the menus) and the team marks (pillagers against your party, the minimap dots). The sets were chosen by simulating each kind of colour
  // blindness and keeping every rarity and the two sides far apart in what that eye sees.
  {k:'cb', label:'COLOUR-BLIND MODE', sec:'ACCESSIBILITY',
   hint:'RECOLOURS RARITY AND THE ENEMY AND ALLY MARKS: DEUTERANOPIA AND PROTANOPIA (RED-GREEN), TRITANOPIA (BLUE-YELLOW).',
   opts:[
     {n:'OFF',          cfg:{cb:0}},
     {n:'DEUTERANOPIA', cfg:{cb:1}},
     {n:'PROTANOPIA',   cfg:{cb:2}},
     {n:'TRITANOPIA',   cfg:{cb:3}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
var BRT={v:1};
'@ @'
// v26.xx (settings8): COLOUR-BLIND MODE. CB_NORM is the game as drawn (the five rarity colours, then the team marks and the HUD ally and danger); the three
// sets below it are what the row swaps in. cbApply runs every frame and writes only when the mode changed, so it also puts a mode right after a session
// overlay (the DEMO) comes and goes. It changes the tables the drawing reads at draw time (RCOL, TEAMCOL, TEAMHI, UIC, HUDC) and the stylesheet tokens
// (--r-*, --ally) on the page element, and empties the icon cache that painted rarity rims.
var CBM={m:0,done:0};
var CB_KEYS=['common','uncommon','rare','elite','gold'];
var CB_NORM={rar:['#9da3a8','#5fbf6a','#3f9de9','#a866e0','#ffc72e'],ally:'#5fb0ff',allyHi:'#b4dcff',foe:'#e5482f',foeHi:'#ff9a84',uiAlly:'#9cc7ff',danger:'#e5482f'};
var CB_SETS=[CB_NORM,
  {rar:['#9da3a8','#6ff0e0','#4f8bff','#ff7a1a','#ffe85a'],ally:'#4fa8ff',allyHi:'#a9d4ff',foe:'#ff7a1a',foeHi:'#ffc08a',uiAlly:'#9cc7ff',danger:'#ff7a1a'},
  {rar:['#9da3a8','#6ff0e0','#4f8bff','#ff7a1a','#ffe85a'],ally:'#4fa8ff',allyHi:'#a9d4ff',foe:'#ff8a2a',foeHi:'#ffc08a',uiAlly:'#9cc7ff',danger:'#ff8a2a'},
  {rar:['#9da3a8','#6ff0e0','#3a5fe0','#ff7a1a','#f5f56a'],ally:'#35e0b0',allyHi:'#a6f0dc',foe:'#ff8a2a',foeHi:'#ffc08a',uiAlly:'#9cf0d8',danger:'#ff8a2a'}];
function cbApply(){
  var m=(CFG.cb|0), S, i, k, root;
  if(m<0||m>3) m=0;
  if(CBM.done&&CBM.m===m) return false;
  S=CB_SETS[m]||CB_NORM; root=document.documentElement;
  for(i=0;i<5;i++){
    k=CB_KEYS[i]; RCOL[k]=S.rar[i]; UIC['r_'+k]=S.rar[i];
    if(m) root.style.setProperty('--r-'+k,S.rar[i]); else root.style.removeProperty('--r-'+k);
  }
  HUDC.special=UIC.r_elite;
  TEAMCOL.ally=S.ally; TEAMCOL.foe=S.foe; TEAMHI.ally=S.allyHi; TEAMHI.foe=S.foeHi;
  UIC.ally=S.uiAlly; HUDC.ally=S.uiAlly; HUDC.danger=S.danger;
  if(m) root.style.setProperty('--ally',S.uiAlly); else root.style.removeProperty('--ally');
  try{ ICONSPR.m={}; ICONSPR.n=0; }catch(_ic){}
  CBM.m=m; CBM.done=1;
  return true;
}
var BRT={v:1};
'@

SubRx @'
try{ brightApply(); }catch(_br){}   // v26.xx (settings5): BRIGHTNESS, applied at once
'@ @'
try{ brightApply(); }catch(_br){}   // v26.xx (settings5): BRIGHTNESS, applied at once
  try{ cbApply(); }catch(_cb){}   // v26.xx (settings8): COLOUR-BLIND MODE, applied at once
'@

SubRx @'
var VER='26.48';
'@ @'
var VER='26.49';
'@

$pat = "(?m)^  now:'v26\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.49: Accessibility has colour-blind modes for rarity and for the two sides. Check 26.49 fails on v26.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
