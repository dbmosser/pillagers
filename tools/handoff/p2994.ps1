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

# Run over card: stat cells, and no first run card over the arcade (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract:has(.arcpage[style*="block"]) .attname, body #attract:has(.arcover[style*="block"]) .attname{ color:var(--tx-2); }
'@ @'
body #attract:has(.arcpage[style*="block"]) .attname, body #attract:has(.arcover[style*="block"]) .attname{ color:var(--tx-2); }
/* v29.94 (cw-partystats), the critic on v29.93 (55 = 3): "the stats are a dot separated run-on string of 16px grey, ext is cryptic, You 0 SP repeats the hero". The run over card shows kills, extractions and deaths as cells, a 32px value over a 16px label, one row for one player and a row each for two. The old text row stays in the page (hidden) for the readers of its words. Restyle only. */
body #attract .arcover .aor{ display:none; }
body #attract .arcover .aost{ display:grid; row-gap:calc(var(--sp-2) * var(--attz,1)); margin-top:calc(var(--sp-3) * var(--attz,1)); padding-top:calc(var(--sp-3) * var(--attz,1)); border-top:1px solid var(--ui-line); }
body #attract .arcover .aosr{ display:flex; align-items:flex-end; gap:calc(var(--sp-3) * var(--attz,1)); }
body #attract .arcover .aosn{ min-width:calc(var(--sp-5) * var(--attz,1)); font-size:calc(var(--fs-body) * var(--attz,1)); font-weight:700; line-height:1.1; color:var(--tx-2); }
body #attract .arcover .aosc{ display:block; flex:1; }
body #attract .arcover .aosc b{ display:block; font-size:calc(var(--fs-title) * var(--attz,1)); font-weight:700; line-height:1.1; color:var(--tx-1); }
body #attract .arcover .aosc i{ display:block; margin-top:calc(var(--sp-1) * var(--attz,1)); font-style:normal; font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
'@

SubRx @'
function arcadeOverSync(){
'@ @'
// v29.94 (cw-partystats), critic 55 (3 of 5): the run over stats are cells, a value over a label (Kills, Extractions, Deaths). One player: three cells in a row. Two players: a row each, led by P1 and P2 and the player score.
function arcadeOverStats(c,o){
  var rows=ARCADE.solo?[[null,o&&o.p1]]:[['P1',o&&o.p1],['P2',o&&o.p2]], hd=[['Score','s'],['Kills','k'],['Extractions','x'],['Deaths','d']], g, row, cell, v, l, i, j, r;
  if(!c||!o) return false;
  g=document.createElement('div'); g.className='aost';
  for(i=0;i<rows.length;i++){
    r=rows[i][1]; if(!r) continue;
    row=document.createElement('div'); row.className='aosr';
    if(rows[i][0]){ cell=document.createElement('span'); cell.className='aosn'; cell.textContent=rows[i][0]; row.appendChild(cell); }
    for(j=ARCADE.solo?1:0;j<hd.length;j++){
      if(hd[j][1]==='d'&&!(r.d>=0)) continue;
      cell=document.createElement('span'); cell.className='aosc';
      v=document.createElement('b'); v.textContent=(hd[j][1]==='s')?arcadeCr(r.s):String(r[hd[j][1]]|0); cell.appendChild(v);
      l=document.createElement('i'); l.textContent=hd[j][0]; cell.appendChild(l);
      row.appendChild(cell);
    }
    g.appendChild(row);
  }
  c.appendChild(g);
  return true;
}
function arcadeOverSync(){
'@

SubRx @'
    if(ini) arcadeIniDraw(c,ini);
'@ @'
    if(oc){ try{ arcadeOverStats(c,o); }catch(_os){} }
    if(ini) arcadeIniDraw(c,ini);
'@

SubRx @'
function firstRunNext(){
  if(document.querySelector('.modal.on')) return;   // he is reading one already
'@ @'
function firstRunNext(){
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   /* v29.94 (cw-partystats): the welcome pack opened under the party attract on a fresh profile and showed through it. No first run card opens while the arcade is up; it waits for the next visit to the Undercroft */
  if(document.querySelector('.modal.on')) return;   // he is reading one already
'@

SubRx @'
var VER='29.93';
'@ @'
var VER='29.94';
'@

$pat = "(?m)^  now:'v29\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.94: The run over card shows kills, extractions and deaths as cells. Check 29.94 fails on v29.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
