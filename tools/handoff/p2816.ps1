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

# SIX NEW HEADGEARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {id:'ghostmask', name:'Ghost Mask',     how:'warden:3',    kind:'hat', crowd:0},
'@ @'
  {id:'ghostmask', name:'Ghost Mask',     how:'warden:3',    kind:'hat', crowd:0},
  // v28.16 (cosm3), HIS ORDER (2026-10-15): "player cosmetics still need major improvements". HEAD LAYER: six headgears that change the head
  // SHAPE at raid size, not a tint (a wide brim, a taller dome, ear pro, a lamp, a crest). Trimmed in the scheme accent. Yours alone, like the
  // Spartan Helmet: nobody in the crowd and no pillager wears them (crowd:0).
  {id:'boonie',    name:'Boonie Hat',       how:'runs:7',      kind:'hat', crowd:0},
  {id:'tachelm',   name:'Tactical Helmet',  how:'extracts:6',  kind:'hat', crowd:0},
  {id:'hardhat',   name:'Hard Hat',         how:'runs:9',      kind:'hat', crowd:0},
  {id:'goggles',   name:'Goggle Cap',       how:'level:3',     kind:'hat', crowd:0},
  {id:'gasmask',   name:'Gas Mask',         how:'extracts:12', kind:'hat', crowd:0},
  {id:'heavyhelm', name:'Heavy Helmet',     how:'warden:2',    kind:'hat', crowd:0},
'@

SubRx @'
      wc.fillStyle='#1a1c22'; rrF(hx2-9.2,ty-40.6,18.4,3.2,2);
    }
'@ @'
      wc.fillStyle='#1a1c22'; rrF(hx2-9.2,ty-40.6,18.4,3.2,2);
    } else if(HAT==='boonie'){
      // v28.16 (cosm3): a floppy brim far wider than the head, a soft crown, a band in the accent.
      var _hA=_SCH?_SCH.a:'#c8b060';
      wc.fillStyle=INK;       rrF(hx2-13.6,ty-39.6,27.2,5.4,2.6);
      wc.fillStyle='#6a6a48'; rrF(hx2-13.0,ty-39.1,26.0,4.2,2.1);
      wc.fillStyle='#4a4a30'; rrF(hx2-13.0,ty-36.2,26.0,1.4,0.7);
      wc.fillStyle='#8c8c64'; wc.fillRect(hx2-11.6,ty-38.9,9.0,0.9);
      wc.fillStyle=INK;       rrF(hx2-8.4,ty-45.2,16.8,7.8,4);
      wc.fillStyle='#5e5e40'; rrF(hx2-7.8,ty-44.7,15.6,6.8,3.4);
      wc.fillStyle='#7a7a56'; rrF(hx2-6.4,ty-44.4,7.6,1.8,0.9);
      wc.fillStyle=_hA;       wc.fillRect(hx2-7.8,ty-40.6,15.6,1.4);
    } else if(HAT==='tachelm'){
      // v28.16 (cosm3): a combat helmet, ear pro on both sides and a lamp on the front rail (the accent).
      wc.fillStyle=INK;       rrF(hx2-9.8,ty-44.0,19.6,10.8,5.2);
      wc.fillStyle='#4c5646'; rrF(hx2-9.2,ty-43.5,18.4,9.6,4.6);
      wc.fillStyle='#6a7662'; rrF(hx2-7.8,ty-43.2,9.8,2.2,1.1);
      wc.fillStyle='#363e32'; wc.fillRect(hx2-9.2,ty-36.2,18.4,1.4);
      wc.fillStyle=INK;       rrF(hx2-12.2,ty-35.4,4.8,8.6,2.2); rrF(hx2+7.4,ty-35.4,4.8,8.6,2.2);
      wc.fillStyle='#2a3028'; rrF(hx2-11.6,ty-34.8,3.6,7.4,1.6); rrF(hx2+8.0,ty-34.8,3.6,7.4,1.6);
      wc.fillStyle='#454e42'; wc.fillRect(hx2-11.2,ty-34.6,1.0,6.8); wc.fillRect(hx2+8.4,ty-34.6,1.0,6.8);
      wc.fillStyle=INK;       wc.fillRect(hx2+fl*3.8-2.1,ty-46.6,4.2,3.6);
      wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2+fl*3.8-1.5,ty-46.1,3.0,2.4);
    } else if(HAT==='hardhat'){
      // v28.16 (cosm3): a site worker hard hat, safety yellow, a ridge down the dome, a brim and a lamp.
      wc.fillStyle=INK;       rrF(hx2-9.6,ty-44.0,19.2,9.8,5); rrF(hx2-11.4,ty-37.6,22.8,3.6,1.7);
      wc.fillStyle='#e2b22c'; rrF(hx2-9.0,ty-43.5,18.0,8.8,4.5); rrF(hx2-10.8,ty-37.1,21.6,2.6,1.3);
      wc.fillStyle='#ffd866'; rrF(hx2-7.4,ty-43.2,8.6,2.2,1.1);
      wc.fillStyle='#b58a14'; wc.fillRect(hx2-1.0,ty-43.4,2.0,6.6); wc.fillRect(hx2-10.8,ty-35.8,21.6,0.7);
      wc.fillStyle=INK;       wc.fillRect(hx2+fl*3.9-1.9,ty-41.4,3.8,3.2);
      wc.fillStyle='#f6f2e0'; wc.fillRect(hx2+fl*3.9-1.3,ty-41.0,2.6,2.0);
    } else if(HAT==='goggles'){
      // v28.16 (cosm3): a flat cap with the goggles pushed up on the front of it, the lenses in the accent.
      var _gA=_SCH?_SCH.a:'#7fd0ff';
      wc.fillStyle=INK;       rrF(hx2-8.8,ty-41.4,17.6,6.0,2.8);
      wc.fillStyle='#3a4452'; rrF(hx2-8.2,ty-40.9,16.4,5.0,2.4);
      wc.fillStyle='#566380'; wc.fillRect(hx2-6.8,ty-40.6,7.0,1.0);
      wc.fillStyle=INK;       wc.fillRect(hx2-8.8,ty-37.8,17.6,1.8);
      wc.fillStyle='#262c36'; wc.fillRect(hx2-8.4,ty-37.5,16.8,1.1);
      wc.fillStyle=INK;       wc.beginPath(); wc.ellipse(hx2-4.0,ty-39.0,3.7,3.1,0,0,6.2832); wc.ellipse(hx2+4.0,ty-39.0,3.7,3.1,0,0,6.2832); wc.fill();
      wc.fillStyle=_gA;       wc.beginPath(); wc.ellipse(hx2-4.0,ty-39.0,2.8,2.2,0,0,6.2832); wc.ellipse(hx2+4.0,ty-39.0,2.8,2.2,0,0,6.2832); wc.fill();
      wc.fillStyle='rgba(255,255,255,.75)'; wc.fillRect(hx2-5.6,ty-40.3,1.4,0.9); wc.fillRect(hx2+2.4,ty-40.3,1.4,0.9);
    } else if(HAT==='gasmask'){
      // v28.16 (cosm3): a hood, glass lenses over the eyes and a respirator with a filter on the side he faces.
      var _mA=_SCH?_SCH.a:'#c8a24a';
      wc.fillStyle=INK;       rrF(hx2-9.6,ty-43.2,19.2,10.2,5);
      wc.fillStyle='#2e353c'; rrF(hx2-9.0,ty-42.7,18.0,9.0,4.4);
      wc.fillStyle='#434c55'; rrF(hx2-7.6,ty-42.4,8.4,1.8,0.9);
      wc.fillStyle=INK;       wc.beginPath(); wc.ellipse(hx2-3.6,ty-29.8,3.9,4.0,0,0,6.2832); wc.ellipse(hx2+3.6,ty-29.8,3.9,4.0,0,0,6.2832); wc.fill();
      wc.fillStyle='rgba(60,98,86,.55)'; wc.beginPath(); wc.ellipse(hx2-3.6,ty-29.8,3.1,3.2,0,0,6.2832); wc.ellipse(hx2+3.6,ty-29.8,3.1,3.2,0,0,6.2832); wc.fill();
      wc.fillStyle='rgba(225,255,240,.7)'; wc.fillRect(hx2-5.0,ty-31.9,1.5,1.0); wc.fillRect(hx2+2.2,ty-31.9,1.5,1.0);
      wc.fillStyle=INK;       rrF(hx2-6.8,ty-26.4,13.6,8.6,3.8);
      wc.fillStyle='#303840'; rrF(hx2-6.2,ty-25.9,12.4,7.6,3.2);
      wc.fillStyle='#4a535d'; wc.fillRect(hx2-4.8,ty-25.4,9.6,1.0);
      wc.fillStyle=INK;       rrF(hx2+fl*9.2-3.6,ty-32.0,7.2,8.0,2.6);
      wc.fillStyle='#5c6652'; rrF(hx2+fl*9.2-3.0,ty-31.5,6.0,7.0,2.1);
      wc.fillStyle=_mA;       wc.fillRect(hx2+fl*9.2-3.0,ty-29.0,6.0,1.4);
    } else if(HAT==='heavyhelm'){
      // v28.16 (cosm3): a heavy helmet, a tall dome with a crest in the accent, cheek guards and a nose bar, the face open under the brow.
      wc.fillStyle=INK;       rrF(hx2-10.8,ty-46.0,21.6,13.8,6.4); rrF(hx2-11.4,ty-35.4,5.2,12.4,2.2); rrF(hx2+6.2,ty-35.4,5.2,12.4,2.2);
      wc.fillStyle='#5a636c'; rrF(hx2-10.2,ty-45.5,20.4,12.8,5.8); rrF(hx2-10.8,ty-34.8,4.0,11.2,1.8); rrF(hx2+6.8,ty-34.8,4.0,11.2,1.8);
      wc.fillStyle='#7c8792'; rrF(hx2-8.8,ty-45.2,17.6,3.6,3.2);
      wc.fillStyle='#3e464e'; wc.fillRect(hx2-10.2,ty-34.2,20.4,1.6); wc.fillRect(hx2-0.8,ty-34.2,1.6,5.8);
      wc.fillStyle=INK;       rrF(hx2-2.2,ty-50.2,4.4,10.2,1.6);
      wc.fillStyle=_SCH?_SCH.a:'#d8903a'; rrF(hx2-1.4,ty-49.6,2.8,9.0,1.2);
    }
'@

SubRx @'
!/^(mask|spartan|ghostmask)$/.test(HAT)
'@ @'
!/^(mask|spartan|ghostmask|gasmask)$/.test(HAT)
'@

SubRx @'
var VER='28.15';
'@ @'
var VER='28.16';
'@

$pat = "(?m)^  now:'v28\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.16: Six new headgears in FASHION: boonie, tactical helmet, hard hat, goggle cap, gas mask, heavy helmet. Check 28.16 fails on v28.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
