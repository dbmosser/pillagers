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

# THE BAR SHOWS ITS DRINKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    h+='<div class="row"><div style="flex:1"><b>'+B.name+'</b>'+
'@ @'
    // v19.27, seen on the 4K bar screenshot (2026-10-08): the two drinks were bare lines of text, the only station with no pictures.
    // Each row leads with its drink's status icon, the one the raid shows down the left while it is in your blood.
    h+='<div class="row"><img alt="" src="'+barIconURL(B.tag)+'" style="width:52px;height:52px;flex:none;margin-right:16px;align-self:center"><div style="flex:1"><b>'+B.name+'</b>'+
'@

SubRx @'
function renderBar(){
'@ @'
// v19.27: a drink's picture for the bar, its raid status icon (statusGlyph, v19.00) painted once on a 128 pixel tile: a dark disc
// ringed in the status colour with the glyph inside.
var BARICON={};
function barIconURL(tag){
  if(BARICON[tag]!==undefined) return BARICON[tag];
  var c2=document.createElement('canvas'), x2, keep=ctx, col=(tag==='drunk')?'#d98aff':'#ff9ae6';
  c2.width=128; c2.height=128; x2=c2.getContext('2d'); if(!x2) return '';
  try{
    x2.fillStyle='rgba(6,9,13,.6)'; x2.beginPath(); x2.arc(64,64,60,0,6.2832); x2.fill();
    x2.strokeStyle=col; x2.lineWidth=6; x2.beginPath(); x2.arc(64,64,56,0,6.2832); x2.stroke();
    ctx=x2; x2.fillStyle=col; x2.strokeStyle=col;
    statusGlyph((tag==='drunk')?'drunk':'lsd',64,64,30,col);
  }catch(_b){}
  finally{ ctx=keep; }
  try{ BARICON[tag]=c2.toDataURL(); }catch(_u){ BARICON[tag]=''; }
  return BARICON[tag];
}function renderBar(){
'@

SubRx @'
var VER='19.26';
'@ @'
var VER='19.27';
'@

$pat = "(?m)^  now:'v19\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.27: The bar shows a picture for each drink, matching its status icon in a raid. Check 19.27 fails on v19.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
