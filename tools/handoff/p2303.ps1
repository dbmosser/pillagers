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

# NAMES KEEP THEIR CAPITALS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function killWord(e){ return (e&&(e.kind==='raider'||e.kind==='stray'||e.kind==='peddler'))?' ELIMINATED':' DESTROYED'; }
'@ @'
function killWord(e){ return (e&&(e.kind==='raider'||e.kind==='stray'||e.kind==='peddler'))?' ELIMINATED':' DESTROYED'; }
// v22.xx, the raid text rewrite (R50): NAMES KEEP THEIR CAPITALS. Item names are Title Case (Armour Plate), and two survivor lines
// lowercased them to fit a sentence, which also broke the article: He needs a armour plate. aOrAn gives the article from the name
// as written, and a name inside a detail keeps its case; inside a caps headline it is uppercased when the line is built.
function aOrAn(s){ return (/^[aeiou]/i).test(String(s||''))?'an':'a'; }
'@

SubRx @'
  if(ix<0&&!fromReserve){ say('He needs a '+ITEMS[e.want].name.toLowerCase()+'. You have none.'); return; }
'@ @'
  if(ix<0&&!fromReserve){ say(('He needs '+aOrAn(ITEMS[e.want].name)+' '+ITEMS[e.want].name).toUpperCase(),'info',{sub:'You have none.'}); return; }   // v22.xx (R50): HE NEEDS AN ARMOUR PLATE, never a armour plate
'@

SubRx @'
        say(e.helped?'The survivor is still there.'
          :('Someone is hiding in here. He needs a '+ITEMS[e.want].name.toLowerCase()+'.'));
'@ @'
        // v22.xx, the raid text rewrite (R50): the name keeps its case in the detail, with the right article (He needs an Armour Plate.)
        if(e.helped) say('THE SURVIVOR IS STILL THERE','obj');
        else say('SURVIVOR FOUND','obj',{sub:'He needs '+aOrAn(ITEMS[e.want].name)+' '+ITEMS[e.want].name+'.'});
'@

SubRx @'
        if(!e.helped) label(e.x,e.y-20,'NEEDS: '+ITEMS[e.want].name.toUpperCase(),'#7fc4a0',0,true);
'@ @'
        if(!e.helped) label(e.x,e.y-20,'NEEDS '+ITEMS[e.want].name.toUpperCase(),'#7fc4a0',0,true);   // v22.xx (R50): no colon label
'@

SubRx @'
  if(!NET.up[s]) return false;
  nm=netSeatName(s)||'your teammate';
'@ @'
  if(!NET.up[s]) return false;
  nm=netSeatName(s)||'Your teammate';   // v22.xx (R50): it starts the line
'@

SubRx @'
    if(s<0){ say('NO TEAMMATE IN RANGE'); return true; }   // v22.80 (tr6fixb): the caps callout
    nm=netSeatName(s)||'your teammate';
'@ @'
    if(s<0){ say('NO TEAMMATE IN RANGE'); return true; }   // v22.80 (tr6fixb): the caps callout
    nm=netSeatName(s)||'Your teammate';   // v22.xx (R50)
'@

SubRx @'
  var p=G.player, it=ITEMS[key], g=NET.up[s], nm=netSeatName(s)||'your teammate', bi, arm, ceil;
'@ @'
  var p=G.player, it=ITEMS[key], g=NET.up[s], nm=netSeatName(s)||'Your teammate', bi, arm, ceil;   // v22.xx (R50): it starts the line
'@

SubRx @'
  var p=G.player, s=PR.aid, g=NET.up[s], nm=netSeatName(s)||'your teammate', it=ITEMS[PR.key], i, r;
'@ @'
  var p=G.player, s=PR.aid, g=NET.up[s], nm=netSeatName(s)||'Your teammate', it=ITEMS[PR.key], i, r;   // v22.xx (R50): it starts the line
'@

SubRx @'
var VER='23.02';
'@ @'
var VER='23.03';
'@

$pat = "(?m)^  now:'v23\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.03: A survivor asks for an Armour Plate by its name, with the right article, and a teammate with no name starts a line as Your teammate. Check 23.03 fails on v23.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
