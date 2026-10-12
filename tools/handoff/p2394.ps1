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

# THE HUD SPEAKS IN THE MENU TYPEFACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
.avnum{ position:absolute; left:0; right:0; top:11px; text-align:center; font:900 20px/1 Impact,'Arial Black',sans-serif; color:#f4f2ec; letter-spacing:1px; pointer-events:none; }   /* v10.46 */
'@ @'
.avnum{ position:absolute; left:0; right:0; top:11px; text-align:center; font:800 20px/1 var(--f-cond); color:#f4f2ec; letter-spacing:1px; pointer-events:none; }   /* v10.46 */
'@

SubRx @'
var TYPE={
  micro:'600 10px "Rubik",system-ui,sans-serif',  // 13.0 rendered: pips, counters, tags
  label:'600 12px "Rubik",system-ui,sans-serif',  // 15.6 rendered: world labels, prompts
  head: '700 15px "Rubik",system-ui,sans-serif',  // 19.5 rendered: callouts
  title:'800 20px "Rubik",system-ui,sans-serif',  // 26.0 rendered: screen titles
  huge: '800 30px "Rubik",system-ui,sans-serif'   // 39.0 rendered: the one big number
'@ @'
// v23.94, UI REDESIGN ui4 (his #35 and #50, 2026-10-12): the HUD speaks in the same voice as the menus. Every role is Barlow Condensed,
// a DIN-like industrial condensed face (the genre look: about 20% more characters per plate than Rubik), with the menu fallbacks
// until ui1 embeds it (Bahnschrift SemiCondensed is built into Windows). Two roles join the five: num, the big tabular ammo figure,
// and body, sentence-case sub-lines in plain Barlow. Plates measured with measureText shrink with the narrower face by themselves.
var HUDF='"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow","Roboto Condensed",sans-serif';
var HUDFB='"Barlow","Bahnschrift","Segoe UI",system-ui,sans-serif';
var TYPE={
  micro:'600 10px '+HUDF,  // 13.0 rendered: pips, counters, tags
  label:'600 12px '+HUDF,  // 15.6 rendered: world labels, prompts
  head: '700 15px '+HUDF,  // 19.5 rendered: callouts
  title:'800 20px '+HUDF,  // 26.0 rendered: screen titles
  huge: '800 30px '+HUDF,  // 39.0 rendered: the one big number
  num:  '700 34px '+HUDF,  // 44.2 rendered: the ammo figure (v23.94, ui4)
  body: '500 12px '+HUDFB  // 15.6 rendered: sentence-case sub-lines (v23.94, ui4)
'@

SubRx @'
    c.font='700 '+Math.round(Math.min(b3.w,b3.h)*(_bf===2?.52:.42))+'px "Rubik",system-ui,sans-serif';   // v10.95, his note: one family
'@ @'
    c.font='700 '+Math.round(Math.min(b3.w,b3.h)*(_bf===2?.52:.42))+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';   // v10.95, his note: one family
'@

SubRx @'
    wc.font='700 9px "Rubik",system-ui,sans-serif'; wc.textAlign='center';
'@ @'
    wc.font='700 9px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; wc.textAlign='center';
'@

SubRx @'
    c.fillStyle=col; c.font='bold '+Math.round(8*u)+'px sans-serif'; c.textAlign='center'; c.fillText('REC',0,3*u);
'@ @'
    c.fillStyle=col; c.font='bold '+Math.round(8*u)+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; c.textAlign='center'; c.fillText('REC',0,3*u);
'@

SubRx @'
    c.fillStyle='rgba(236,226,190,.85)'; c.font='bold '+Math.round(11*u)+'px sans-serif'; c.textAlign='center'; c.fillText('AMMO',-6*u,24*u);
'@ @'
    c.fillStyle='rgba(236,226,190,.85)'; c.font='bold '+Math.round(11*u)+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; c.textAlign='center'; c.fillText('AMMO',-6*u,24*u);
'@

SubRx @'
    c.fillStyle='rgba(240,240,240,.85)'; c.font='bold '+Math.round(9*u)+'px sans-serif'; c.textAlign='center'; c.fillText('SMK',0,12*u);
'@ @'
    c.fillStyle='rgba(240,240,240,.85)'; c.font='bold '+Math.round(9*u)+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; c.textAlign='center'; c.fillText('SMK',0,12*u);
'@

SubRx @'
    '#attract .attpress{position:absolute;left:0;right:0;bottom:15%;padding:.28em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.72) 22%,rgba(0,0,0,.72) 78%,transparent);text-align:center;font:800 clamp(26px,3.6vw,84px) "Rubik",system-ui,sans-serif;'+
'@ @'
    '#attract .attpress{position:absolute;left:0;right:0;bottom:15%;padding:.28em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.72) 22%,rgba(0,0,0,.72) 78%,transparent);text-align:center;font:800 clamp(26px,3.6vw,84px) var(--f-cond);'+
'@

SubRx @'
    '#attract .attname{position:absolute;left:0;right:0;top:9%;padding:.18em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.62) 22%,rgba(0,0,0,.62) 78%,transparent);text-align:center;font:800 clamp(30px,5vw,120px) "Rubik",system-ui,sans-serif;'+
'@ @'
    '#attract .attname{position:absolute;left:0;right:0;top:9%;padding:.18em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.62) 22%,rgba(0,0,0,.62) 78%,transparent);text-align:center;font:800 clamp(30px,5vw,120px) var(--f-cond);'+
'@

SubRx @'
      'color:#ff5a4a;font:800 15px "Rubik",system-ui,sans-serif;letter-spacing:.1em;pointer-events:none';
'@ @'
      'color:#ff5a4a;font:800 15px var(--f-cond);letter-spacing:.1em;pointer-events:none';
'@

SubRx @'
      'font:800 clamp(12px,1.15vw,30px) "Rubik",system-ui,sans-serif;letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center}'+
'@ @'
      'font:800 clamp(12px,1.15vw,30px) var(--f-cond);letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center}'+
'@

SubRx @'
      'font:800 clamp(15px,1.6vw,38px) "Rubik",system-ui,sans-serif;letter-spacing:.1em;color:#7fe3d4;text-shadow:0 2px 0 #000}';
'@ @'
      'font:800 clamp(15px,1.6vw,38px) var(--f-cond);letter-spacing:.1em;color:#7fe3d4;text-shadow:0 2px 0 #000}';
'@

SubRx @'
    'font:800 clamp(16px,1.9vw,46px) "Rubik",system-ui,sans-serif;letter-spacing:.08em;color:#f2e6c8;text-shadow:0 3px 0 #000,0 0 18px rgba(0,0,0,.9)}'+
'@ @'
    'font:800 clamp(16px,1.9vw,46px) var(--f-cond);letter-spacing:.08em;color:#f2e6c8;text-shadow:0 3px 0 #000,0 0 18px rgba(0,0,0,.9)}'+
'@

SubRx @'
      c.font='bold '+fs+'px Rubik, system-ui, sans-serif';
      while(fs>8&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px Rubik, system-ui, sans-serif'; }
'@ @'
      c.font='bold '+fs+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';
      while(fs>8&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; }
'@

SubRx @'
      'color:var(--bone);font-size:11px;font-family:Rubik,system-ui,sans-serif;white-space:nowrap';
'@ @'
      'color:var(--bone);font-size:11px;font-family:var(--f-body);white-space:nowrap';
'@

SubRx @'
    else { pcx.fillStyle='#8a96a1'; pcx.font='600 14px "Rubik",system-ui,sans-serif'; pcx.textAlign='center'; pcx.fillText('--',17,22); }   // v10.95, his note: one family
'@ @'
    else { pcx.fillStyle='#8a96a1'; pcx.font='600 14px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; pcx.textAlign='center'; pcx.fillText('--',17,22); }   // v10.95, his note: one family
'@

SubRx @'
           '<span style="position:absolute;left:0;right:0;top:8px;text-align:center;font:900 15px/1 Impact,sans-serif;color:#f4f2ec">23</span></span>';
'@ @'
           '<span style="position:absolute;left:0;right:0;top:8px;text-align:center;font:800 15px/1 var(--f-cond);color:#f4f2ec">23</span></span>';
'@

SubRx @'
var VER='23.93';
'@ @'
var VER='23.94';
'@

$pat = "(?m)^  now:'v23\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.94: HUD and raid text now use the same condensed caps face as the menus. Check 23.94 fails on v23.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
