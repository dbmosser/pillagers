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

# THE PARTY ON THE SECTOR MAP. Multiplayer, plan phase 4 (map dots).

SubRx @'
  ctx.lineWidth=1;
  // SURVEYED. Bottom left of the map, out of the way of every marker on it.
'@ @'
  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  // SURVEYED. Bottom left of the map, out of the way of every marker on it.
'@

SubRx @'
function netEntsHost(){
'@ @'
// v16.08, MULTIPLAYER: THE PARTY ON THE SECTOR MAP (plan phase 4, map dots). The sector map drew only you, so a teammate out of
// sight was nowhere, and one who went down across the sector could not be found to pull up. Each of the party up top on this
// raid seed (netUpShown, from his state words) is drawn on the map as a blue dot with a line for where he faces and his name
// over it; one who is down is drawn red with DOWN under his name. Drawing only: nothing here moves or draws from the seeded stream.
function netMapDots(ox,oy,sc,z){
  var i, g, x, y, nm, n=0;
  z=(z>0)?z:1;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    x=ox+g.x*sc; y=oy+g.y*sc; nm=netSeatName(g.seat)||'PILLAGER';
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(x,y,9*z,0,6.2832); ctx.fill();
    ctx.fillStyle=g.dn?'#e2564a':'#6fb8ff'; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill();
    if(!g.dn){ ctx.strokeStyle='rgba(111,184,255,.85)'; ctx.lineWidth=2*z; ctx.beginPath(); ctx.moveTo(x,y); ctx.lineTo(x+Math.cos(g.f)*18*z,y+Math.sin(g.f)*18*z); ctx.stroke(); ctx.lineWidth=1; }
    ctx.font=FS(TYPE.micro); ctx.textAlign='center';
    ctx.fillStyle=g.dn?'#ff8a80':'#bfe0ff'; ctx.fillText(nm,x,y-13*z);
    if(g.dn) ctx.fillText('DOWN',x,y+20*z);
    ctx.textAlign='left'; n++;
  }
  return n;
}
function netEntsHost(){
'@

SubRx @'
var VER='16.07';
'@ @'
var VER='16.08';
'@

$pat = "(?m)^  now:'v16\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.08: THE PARTY ON THE SECTOR MAP. Multiplayer. The sector map drew only you, so a teammate out of sight was nowhere and one who went down across the sector could not be found. Each of the party up top is now a blue dot on the map with his name and where he faces, and red with DOWN when he is down. Drawing only. No number moved. Check 16.08 fails on v16.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
