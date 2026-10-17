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

# PLAYER 2 SEES THE MIMIC HE OPENED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!ct.mimicWake&&(ct.prog||0)>0){ ct.mimicWake=1; ct.mimicT=0.8; }
'@ @'
    if(!ct.mimicWake&&(ct.prog||0)>0){ ct.mimicWake=1; ct.mimicT=0.8; ct.mimicBy=(typeof ct.netBy==='number'&&ct.netBy>0)?ct.netBy:0; }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: remember which of the party opened it
'@

SubRx @'
  var c=null, p=G.player, a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0, x=ct.x+Math.cos(a)*26, y=ct.y+Math.sin(a)*26;
'@ @'
  var c=null, p=G.player, by=(typeof NET==='object'&&NET.on&&NET.role==='host')?((ct.mimicBy>0)?(ct.mimicBy|0):((ct.netBy>0)?(ct.netBy|0):0)):0, i, q, a, x, y;   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: a box player 2 opened through the host wakes on him
  if(by&&NET.up) for(i=0;i<NET.up.length;i++){ q=NET.up[i]; if(q&&q.seat===by&&netUpShown(q)){ p=netUpBody(q); break; } }
  a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0; x=ct.x+Math.cos(a)*26; y=ct.y+Math.sin(a)*26;
'@

SubRx @'
  if(!G.sim){ spark(ct.x,ct.y,'#ff5a40',16,260); G.shake=Math.max(G.shake||0,4); sfx('alarm',ct.x,ct.y,'crawler'); say('MIMIC','warn'); }
'@ @'
  if(!G.sim){ spark(ct.x,ct.y,'#ff5a40',16,260); if(!by){ G.shake=Math.max(G.shake||0,4); say('MIMIC','warn'); } sfx('alarm',ct.x,ct.y,'crawler'); }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: the line and shake go to the player who opened it
  if(by&&!G.sim) netMarkSend({t:'mark',k:'mimic',seat:by,x:Math.round(ct.x),y:Math.round(ct.y)});
'@

SubRx @'
  if(k==='pill'){ if(mine&&!G.sim) say('THE PILLBOX HAS SEEN YOU','warn'); return 'mark:pill'; }
'@ @'
  if(k==='mimic'){ if(!G.sim){ if(isFinite(+m.x)&&isFinite(+m.y)) spark(+m.x,+m.y,'#ff5a40',16,260); if(mine){ G.shake=Math.max(G.shake||0,4); say('MIMIC','warn'); } } return 'mark:mimic'; }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: player 2 sees the spark and, when he opened it, the same shake and line the host gets for his own
  if(k==='pill'){ if(mine&&!G.sim) say('THE PILLBOX HAS SEEN YOU','warn'); return 'mark:pill'; }
'@

SubRx @'
var VER='28.92';
'@ @'
var VER='28.93';
'@

$pat = "(?m)^  now:'v28\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.93: In co-op, when player 2 opens a mimic crate, it jumps at him and his screen says MIMIC and shakes, just like player 1s does for his own. Check 28.93 fails on v28.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
