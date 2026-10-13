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

# MUSIC STARTS AT 60% (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'volMusic', label:'Music volume',
   hint:'The music on its own.',
   opts:[
     {n:'Off',  cfg:{volMusic:0}},
     {n:'25%',  cfg:{volMusic:0.25}},
     {n:'50%',  cfg:{volMusic:0.5}},
     {n:'75%',  cfg:{volMusic:0.75}},
     {n:'Full', cfg:{volMusic:1}}
   ], def:4},

'@ @'
  // v23.xx, HIS ANSWERS (2026-10-12), answer 36: "menu music 60%". The music (the title, the attract and the Undercroft; never a
  // raid) starts at 60% out of the box. A 60% step sits between 50% and 75%, and a pick saved on the old five steps is moved up
  // once (volMusicMove in applyGameOpts), so a player who chose 75% or Full keeps exactly that.
  {k:'volMusic', label:'Music volume',
   hint:'The music on its own.',
   opts:[
     {n:'Off',  cfg:{volMusic:0}},
     {n:'25%',  cfg:{volMusic:0.25}},
     {n:'50%',  cfg:{volMusic:0.5}},
     {n:'60%',  cfg:{volMusic:0.6}},
     {n:'75%',  cfg:{volMusic:0.75}},
     {n:'Full', cfg:{volMusic:1}}
   ], def:3},

'@

SubRx @'
function applyGameOpts(){
  var tk=tunedKeys();

'@ @'
// v23.xx (his answer 36): a Music volume pick saved on the old five steps (Off, 25, 50, 75, Full) moves up past the new 60% step,
// once per save (P.volMus6 marks it done), so 75% stays 75% and Full stays Full.
function volMusicMove(){
  if(!P||P.volMus6===1) return false;
  if(P.gameOpts&&typeof P.gameOpts.volMusic==='number'&&P.gameOpts.volMusic>=3) P.gameOpts.volMusic++;
  P.volMus6=1;
  return true;
}
function applyGameOpts(){
  try{ volMusicMove(); }catch(_vm){}
  var tk=tunedKeys();

'@

SubRx @'
var VER='25.20';
'@ @'
var VER='25.21';
'@

$pat = "(?m)^  now:'v25\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.21: The music now starts at 60%, with a 60% step in Settings. Check 25.21 fails on v25.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
