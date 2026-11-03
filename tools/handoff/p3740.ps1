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

# EXTRACTION PAYS THE BONUS AND THE GEAR, NOT YOUR SCORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.careerCash=(how==='extract')?s*2:0;
'@ @'
  // v37.xx (cw-nospcash), HIS RULING OF 11-01: "it shouldn't pay cash beyond just selling what you have and maybe some sort of bonus, but most the money should come from selling gear." The raid score stays score: it no longer banks as $ on an extraction. v37.25 (cw-m1nocash) ended the other raid cash and left this line.
'@

SubRx @'
    fin=Math.round(s*2*cm);
    P.credits=(+P.credits||0)+G.careerCash;
'@ @'
    fin=Math.round(s*2*cm);
'@

SubRx @'
, cash=(G.careerCash===undefined)?(ex?s*2:0):G.careerCash, b=c.b||{}
'@ @'
, b=c.b||{}
'@

SubRx @'
    mh+=row('cr','<span class="lgl">CREDITS BANKED</span>'+((cash>0)?cnt(cash,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
'@ @'
    // v37.xx (cw-nospcash): no CREDITS BANKED row, nothing banks from the score any more
'@

SubRx @'
    tot=cash+hv+(gr?(gr.cash+gr.value):0);
'@ @'
    tot=hv+(gr?(gr.cash+gr.value):0);
'@

SubRx @'
    mh+=row('lost','<span class="lgl">CREDITS NOT BANKED</span><b><s>+'+arcadeMoney(Math.floor(s/2))+'</s> LOST</b>');
'@ @'
    // v37.xx (cw-nospcash): no CREDITS NOT BANKED row, a score never banked anything to lose
'@

SubRx @'
var VER='37.39';
'@ @'
var VER='37.40';
'@

$pat = "(?m)^  now:'v37\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.40: an extraction banks its bonus, no longer your raid score as cash; money comes from selling gear Check 37.40 fails on v37.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
