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

# ONE TEAMMATE COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x-tw/2,g.y-52);
'@ @'
      // v22.70, the raid text rewrite (R27): ONE TEAMMATE COLOUR. His name over his head was amber, the colour of keys and of your own
      // Waypoint, while his row on the left, his map mark and his Waypoint were ally blue; his edge arrow was amber too and his ping
      // cyan, close to the extraction colour. A teammate is now HUDC.ally wherever he is named or marked, and danger red while he is down.
      wc.fillStyle=g.dn?HUDC.danger:HUDC.ally; wc.fillText(nm,g.x-tw/2,g.y-52);
'@

SubRx @'
  c=g.dn?'#ff5a4a':'#ffc04a';
'@ @'
  c=g.dn?HUDC.danger:HUDC.ally;   // v22.70 (R27): one teammate colour
'@

SubRx @'
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(netSeatName(g.seat)||'PILLAGER',x,y);
'@ @'
    ctx.fillStyle=g.dn?HUDC.danger:HUDC.ally; ctx.fillText(netSeatName(g.seat)||'PILLAGER',x,y);   // v22.70 (R27): one teammate colour
'@

SubRx @'
    ctx.fillStyle=g.dn?'#e2564a':'#6fb8ff'; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill();
    if(!g.dn){ ctx.strokeStyle='rgba(111,184,255,.85)';
'@ @'
    ctx.fillStyle=g.dn?HUDC.danger:HUDC.ally; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill();   // v22.70 (R27): one teammate colour
    if(!g.dn){ ctx.strokeStyle='rgba(191,224,255,.85)';
'@

SubRx @'
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(nm,x,y-13*z);
'@ @'
    ctx.fillStyle=g.dn?HUDC.danger:HUDC.ally; ctx.fillText(nm,x,y-13*z);   // v22.70 (R27): one teammate colour
'@

SubRx @'
    c=p.dg?'#ff4a3a':(p.w?'#ff8a3c':'#6fe0ff');
'@ @'
    c=p.dg?'#ff4a3a':(p.w?'#ff8a3c':((p.s===NET.seat)?HUDC.warn:HUDC.ally));   // v22.70 (R27): a teammate ping in the teammate colour, your own in amber like your Waypoint
'@

SubRx @'
var VER='22.69';
'@ @'
var VER='22.70';
'@

$pat = "(?m)^  now:'v22\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.70: A teammate is one ally blue wherever he is named or marked, and red while he is down. Check 22.70 fails on v22.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
