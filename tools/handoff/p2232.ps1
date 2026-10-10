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

# THREATS IN THE ALERT LANE, IN HIS VOICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
say('Something woke up.');
'@ @'
say('SOMETHING WOKE UP','warn');
'@

SubRx @'
sayWhenFree('YOUR RIVAL is out here: '+nm+'. He will shoot on sight.','warn');
'@ @'
sayWhenFree('YOUR RIVAL IS UP TOP','warn',{sub:nm+' shoots on sight.'});
'@

SubRx @'
if(tk==='frag') say('GRENADE HIT COVER','warn');
'@ @'
if(tk==='frag') say('GRENADE HIT COVER','warn',{sub:'Get clear of the blast.'});
'@

SubRx @'
  say('It went off in your hand.');
'@ @'
  say('GRENADE WENT OFF IN YOUR HAND','crit');   // v22.32, the raid text rewrite (R09): a threat is an alert headline in the shooter voice (his order of 2026-10-09)
'@

SubRx @'
say('More pillagers have entered the area.');
'@ @'
say('MORE PILLAGERS HAVE COME UP','warn');
'@

SubRx @'
say('It was playing dead.');
'@ @'
say('IT WAS PLAYING DEAD','warn');
'@

SubRx @'
else say('THE PILLBOX HAS SEEN YOU.');
'@ @'
else say('THE PILLBOX HAS SEEN YOU','warn');
'@

SubRx @'
else say('Something very large has noticed you.');
'@ @'
else say('SOMETHING HUGE HAS NOTICED YOU','warn');
'@

SubRx @'
if(mine&&!G.sim) say('Something very large has noticed you.');
'@ @'
if(mine&&!G.sim) say('SOMETHING HUGE HAS NOTICED YOU','warn');
'@

SubRx @'
          if(!G.sim) say(e.name+' does not like that.');
'@ @'
          if(!G.sim) say('PILLAGER TURNED HOSTILE','warn',{sub:e.name+' does not like that.'});   // v22.32, the raid text rewrite (R09): a threat is an alert headline in the shooter voice (his order of 2026-10-09)
'@

SubRx @'
var VER='22.31';
'@ @'
var VER='22.32';
'@

$pat = "(?m)^  now:'v22\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.32: Threat lines are short caps callouts in the alert slot, such as THE PILLBOX HAS SEEN YOU and PILLAGER TURNED HOSTILE. Check 22.32 fails on v22.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
