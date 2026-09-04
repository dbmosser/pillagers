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

# 1. HIS RULING, 2026-09-04: the crowd may not wear these two. They stay on the
#    rack for him. crowd:0 is a flag the roller reads, so a third piece can be
#    kept off the floor later with one word and no new code.
SubRx @'
  {id:'spartan',   name:'Spartan Helmet', how:'extracts:20', kind:'hat'},
  {id:'ghostmask', name:'Ghost Mask',     how:'warden:3',    kind:'hat'},
'@ @'
  {id:'spartan',   name:'Spartan Helmet', how:'extracts:20', kind:'hat', crowd:0},
  {id:'ghostmask', name:'Ghost Mask',     how:'warden:3',    kind:'hat', crowd:0},
'@

# 2. THE ROLLER READS THE FLAG.
SubRx @'
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.kind==='build') continue; (byKind[c.kind]=byKind[c.kind]||[]).push(c.id); }
'@ @'
    // v11.13, his ruling: a piece marked crowd:0 is his alone, like the crown.
    // Measured before this line: 182 ghost masks and 172 Spartan helmets in
    // 2,000 rolls, so on an eight man floor one of the two was usually there.
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.kind==='build'||c.crowd===0) continue; (byKind[c.kind]=byKind[c.kind]||[]).push(c.id); }
'@

# 3. VERSION STAMPS, both of them.
SubRx @'
var VER='11.12';
'@ @'
var VER='11.13';
'@
SubRx @'
var WHATSNEW_VER='11.12';
'@ @'
var WHATSNEW_VER='11.13';
'@
SubRx @'
  'MACHINES NO LONGER WALK INTO WINDOWS.
'@ @'
  'THE GHOST MASK AND THE SPARTAN HELMET ARE YOURS ALONE. Nobody in the Undercroft crowd wears either any more; everyone downstairs still dresses from the rest of the rack.',
  'MACHINES NO LONGER WALK INTO WINDOWS.
'@

# 4. THE WATCHDOG.
SubRx @'
  now:'v11.12: a window is see-through and it is not walk-through, and every movement test in the game had been reading the sight geometry, which skips windows. A machine inside a building saw you through the glass, threw its route away, walked into the window and stood there. Measured on COLD STORAGE at seed 4242: four buildings had a route out and none of their crawlers got within 240 units. Bodies now ask whether they can WALK the line, not whether they can SEE it.',
'@ @'
  now:'v11.13: his ruling on the crowd. The ghost mask and the Spartan helmet come off the Undercroft crowd and stay on his rack; everything else the crowd wears is unchanged. Measured before: 182 masks and 172 helmets in 2,000 rolls, so on an eight man floor one of the two was usually in the room. Next: the furniture that plugs doorways and seals machines inside buildings.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
