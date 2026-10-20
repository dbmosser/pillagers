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

# PRE-RAID: QUIETER WARNING, ONE GUN CHIP, TALLER PACK ROWS AND BIGGER STEPPERS, SOFTER MAP LABELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#sectormodal .srprow{ height:38px;
'@ @'
#sectormodal .srprow{ height:46px;
'@

SubRx @'
width:34px; height:30px; min-width:0; padding:0; display:grid;
'@ @'
width:36px; height:36px; min-width:0; padding:0; display:grid;
'@

SubRx @'
#sectormodal .srprow .held{ min-width:26px; font:500 16px var(--f-body); color:var(--tx-2); }
'@ @'
#sectormodal .srprow .held{ min-width:26px; font:500 16px var(--f-body); color:#c9c5bb; }
  #sectormodal .srprow:has(.padfocus){ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--srseat); }
'@

SubRx @'
border:1px solid var(--warn); background:rgba(245,183,59,.12); border-radius:4px; color:var(--warn);
'@ @'
border:1px solid var(--ui-line-hi); background:none; border-radius:4px; color:var(--warn);
'@

SubRx @'
<b>NO ARMOUR EQUIPPED</b><i>EQUIP PLATES</i>
'@ @'
<b>NO ARMOUR EQUIPPED</b>
'@

SubRx @'
var line='<div class="srsum">'+chip('gun',w?escHtml(w.name):'a scav pistol');
'@ @'
var _og=!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; });
  var line='<div class="srsum"><span class="gc" style="flex-basis:100%"><i>gun</i><b>'+(w?escHtml(w.name):'a scav pistol')+'</b>'+(_og?'<i style="margin-left:auto">own gun in stash</i>':'')+'</span>';
'@

SubRx @'

  if(!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; })) line+=chip('','NO GUN EQUIPPED');
'@ @'

'@

SubRx @'
+
    '<span class="sv">SAVES AS YOU GO</span>';
'@ @'
;
'@

SubRx @'
#sectormodal .srplate{ flex:none; height:72px; padding:3px; background:var(--srseat); border-radius:6px; }
'@ @'
#sectormodal .srplate{ flex:none; height:72px; padding:0; background:none; }
'@

SubRx @'
padding:0 12px 10px; background:var(--ui-panel); border:1px solid var(--ui-line);
'@ @'
padding:0 12px 10px; background:var(--ui-panel); border:0;
'@

SubRx @'
padding:10px 12px; background:var(--ui-panel); border:1px solid var(--ui-line);
'@ @'
padding:10px 12px; background:var(--ui-panel); border:0;
'@

SubRx @'
fs=20, cx=ox+(z.x+z.w/2)*sc
'@ @'
fs=18, cx=ox+(z.x+z.w/2)*sc
'@

SubRx @'
c.lineWidth=3; c.strokeStyle='rgba(8,18,28,.9)'
'@ @'
c.lineWidth=2; c.strokeStyle='rgba(8,18,28,.6)'
'@

SubRx @'
c.font='600 16px '+FF; c.textAlign='center'; c.fillStyle='#dcc3f4';
    a1=TX(String(b.name||'')); L=a1.split(' '); a2=L.length>1?L.slice(1).join(' '):''; a1=L[0];
    put(a1,ox+(b.x+b.w/2)*sc,oy+(b.y+b.h/2)*sc-(a2?2:-6)); if(a2) put(a2,ox+(b.x+b.w/2)*sc,oy+(b.y+b.h/2)*sc+16); n++; }
'@ @'
c.font='600 16px '+FF; c.textAlign='right'; c.fillStyle='#dcc3f4'; put(TX(String(b.name||'')),ox+b.x*sc-8,oy+(b.y+b.h/2)*sc+5); n++; }
'@

SubRx @'
var VER='32.50';
'@ @'
var VER='32.51';
'@

$pat = "(?m)^  now:'v32\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.51: The pre-raid page is calmer: one gun line, a quiet no armour row, taller pack rows with bigger plus and minus buttons, and softer map labels. Check 32.51 fails on v32.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
