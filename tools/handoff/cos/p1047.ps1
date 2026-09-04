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

# ============ HIS NOTE, 2026-09-03 about 14:10, and the Reach research: a
# ============ finished rack should mean something. v10.46 put the first
# ============ capstone on the hair rack; three more racks get theirs.
#
# Silver eyes for a finished eye rack, a Gold fit for a finished clothing
# rack, Gilded boots for a finished boots rack. Colours only; the painters
# already draw every colour the racks hold.

SubRx @'
  {id:'eyeamber', name:'Amber',        how:'warden:1',    kind:'eyes'},
'@ @'
  {id:'eyeamber', name:'Amber',        how:'warden:1',    kind:'eyes'},
  {id:'eyesilver',name:'Silver',       how:'rack:eyes',   kind:'eyes'},   // v10.47: the capstone
'@

SubRx @'
var EYECOL={eyebrown:'#5a3a22',eyehazel:'#8a6a34',eyeblue:'#4a7ab8',eyegreen:'#4a8a5a',eyegrey:'#8a949c',eyeamber:'#c88a2a'};
'@ @'
var EYECOL={eyebrown:'#5a3a22',eyehazel:'#8a6a34',eyeblue:'#4a7ab8',eyegreen:'#4a8a5a',eyegrey:'#8a949c',eyeamber:'#c88a2a',eyesilver:'#d4d8de'};
'@

SubRx @'
  {id:'jersey',    name:'Number 23 Jersey', how:'level:4', kind:'fit'}
];
'@ @'
  {id:'jersey',    name:'Number 23 Jersey', how:'level:4', kind:'fit'},
  {id:'gold',      name:'Gold',        how:'rack:fit', kind:'fit'}   // v10.47: the capstone
];
'@

SubRx @'
            jersey:['#7a1414','#c41e1e']};   // v10.40: red; the black panels and the 23 are painted on
'@ @'
            jersey:['#7a1414','#c41e1e'],   // v10.40: red; the black panels and the 23 are painted on
            gold:['#8a6a1a','#d1a72c']};    // v10.47
'@

SubRx @'
  {id:'sneakbred', name:'Bred High-Tops',    how:'level:5',     kind:'boots'},
'@ @'
  {id:'sneakbred', name:'Bred High-Tops',    how:'level:5',     kind:'boots'},
  {id:'gilded',    name:'Gilded Boots',      how:'rack:boots',  kind:'boots'},   // v10.47: the capstone
'@

SubRx @'
             sneakchi:['#a81a1a','#cc2424','#f2f0ea','#14161b'],sneakcon:['#14161b','#1f2227','#f2f0ea','#e6e3da'],sneakbred:['#14161b','#1f2227','#c41e1e','#c41e1e']};
'@ @'
             sneakchi:['#a81a1a','#cc2424','#f2f0ea','#14161b'],sneakcon:['#14161b','#1f2227','#f2f0ea','#e6e3da'],sneakbred:['#14161b','#1f2227','#c41e1e','#c41e1e'],
             gilded:['#7a5a1a','#b8912f','#f1e6c0','#3a2a10']};   // v10.47: gold, a pale sole, a dark collar
'@

SubRx @'
var VER='10.46';
'@ @'
var VER='10.47';
'@
SubRx @'
  now:'v10.46: the first capstone. Platinum hair is earned by owning every other colour on the hair rack; a rack can be finished now, and says so.',
'@ @'
  now:'v10.47: three more capstones. Silver eyes, a Gold fit and Gilded boots, each earned by owning every other piece on its rack.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
