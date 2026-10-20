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

# EASY RUN: BOARD POINTS CUT 30 PERCENT AND TAGGED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
m:(x.m===1)?1:2,u:'cr'});   // v23.54 (arcade30): the mode, an old row
'@ @'
m:(x.m===1)?1:2,e:x.e?1:0,u:'cr'});   // v28.xx (cw-easyboard): the easy tag survives a load; v23.54 (arcade30): the mode, an old row
'@

SubRx @'
o=m[x.run]={run:x.run,i:x.i||'',i2:x.i2||'',s:x.s,x:x.x,k:x.k,t:x.t,m:(x.m===1)?1:2,u:'cr'};
'@ @'
o=m[x.run]={run:x.run,i:x.i||'',i2:x.i2||'',s:x.s,x:x.x,k:x.k,t:x.t,m:(x.m===1)?1:2,e:x.e?1:0,u:'cr'};
'@

SubRx @'
o.s=x.s; o.x=x.x; o.k=x.k; o.t=x.t; }
'@ @'
o.s=x.s; o.x=x.x; o.k=x.k; o.t=x.t; o.e=x.e?1:0; }
'@

SubRx @'
  var id=ARCADE.run.id, s=arcadeTeam(), r, i, ini='', ini2='';
'@ @'
  var id=ARCADE.run.id, ez=arcadeBoardEasy(), s=arcadeBoardCut(arcadeTeam(),ez), r, i, ini='', ini2='';   // v28.xx (cw-easyboard), HIS ANSWER (2026-10-18, 2.47 c): an easy run is cut 30 percent and tagged
'@

SubRx @'
if(r[i].s>s) s=r[i].s; r.splice(i,1); }
'@ @'
if(r[i].s>s&&(r[i].e?1:0)===ez) s=r[i].s; r.splice(i,1); }
'@

SubRx @'
m:arcadeBoardMode(),u:'cr'});   // v23.54 (arcade30): tagged with its mode;
'@ @'
m:arcadeBoardMode(),e:ez,u:'cr'});   // v23.54 (arcade30): tagged with its mode;
'@

SubRx @'
// the run row, written in place under the run id. Returns whether it was written.
function arcadeBoardPut(){
'@ @'
// v28.xx (cw-easyboard), HIS ANSWER (2026-10-18, 2.47 c): "the points are cut by 30 percent and tagged". The flag is ARCADE.easy (the host window); same 0.7 as the damage cut (3.16 b).
function arcadeBoardEasy(){ return (typeof ARCADE==='object'&&ARCADE&&ARCADE.easy)?1:0; }
function arcadeBoardCut(s,e){ return e?Math.round((+s||0)*(typeof EASY_MUL==='number'?EASY_MUL:0.7)):s; }
function arcadeBoardTag(r){ return (r&&r.e)?' \u00b7 easy':''; }
// the run row, written in place under the run id. Returns whether it was written.
function arcadeBoardPut(){
'@

SubRx @'
toUpperCase():''),arcadeCr(r.s)); }   // v23.56 (arcade31): in credits
'@ @'
toUpperCase():'')+arcadeBoardTag(r),arcadeCr(r.s)); }   // v23.56 (arcade31): in credits; v28.xx (cw-easyboard): and the easy tag
'@

SubRx @'
var VER='32.30';
'@ @'
var VER='32.31';
'@

$pat = "(?m)^  now:'v32\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.31: An easy demo run writes its board row at 70 percent of the score with an easy tag next to the initials. Check 32.31 fails on v32.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
