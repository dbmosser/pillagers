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

# THE GUN CARD NO LONGER SAYS STOWED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       if(p.sec){ ctx.font=FS(TYPE.micro); _wtx=Math.max(_wtx,ctx.measureText('STOWED  '+p.sec.name+((p.sec.mag>0)?'  '+p.secAmmo:'')).width); ctx.font=FS(TYPE.head); }
'@ @'
       if(stowLine(p)){ ctx.font=FS(TYPE.micro); _wtx=Math.max(_wtx,ctx.measureText(stowLine(p)).width); ctx.font=FS(TYPE.head); }
'@

SubRx @'
  if(p.sec){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    var _cornStow='STOWED  '+p.sec.name+((p.sec.mag>0)?'  '+p.secAmmo:'');   // v18.61, seen on the raid screenshot (2026-10-07): bare hands read STOWED Bare Hands 0; a weapon with no magazine shows no count, as the held line says MELEE
'@ @'
  // v21.73, HIS NOTE (2026-10-09): "it says my gun is stowed even tho i've got it out". The line over the gun name read STOWED and
  // then the other slot, so over the gun in his hands it said STOWED Bare Hands, which reads as the gun he holds being put away. It
  // now names the other gun plainly (OTHER GUN, its name, its rounds), and with nothing but Bare Hands in the other slot there is no line.
  if(stowLine(p)){
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#7d8894';
    var _cornStow=stowLine(p);
'@

SubRx @'
function drawStatusIcons(){
'@ @'
// v21.73: the gun card's line for the gun you are NOT holding, or '' when the other slot holds only Bare Hands.
function stowLine(p){
  var s=p&&p.sec;
  if(!s||s.id==='fists') return '';
  return 'OTHER GUN  '+s.name+((s.mag>0)?'  '+p.secAmmo:'');
}
function drawStatusIcons(){
'@

SubRx @'
var VER='21.74';
'@ @'
var VER='21.75';
'@

$pat = "(?m)^  now:'v21\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.75: The gun card no longer says STOWED over the gun in your hands. Your second gun is listed as OTHER GUN. Check 21.75 fails on v21.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
