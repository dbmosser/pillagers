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

# RUN GOAL REWARD ROWS FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root .lg .lgpm .lgr.tot b{font:700 32px/1.2 var(--f-cond);letter-spacing:0;color:var(--tx-1)}
'@ @'
#root .lg .lgpm .lgr.tot b{font:700 32px/1.2 var(--f-cond);letter-spacing:0;color:var(--tx-1)}
/* v28.xx (cw-cx-goalrewardlayout): the critic found the goal item name crowded against its value. Keep its full name on a wrapping subline, with a 16px column gap. */
#root #oc_manifest .lg.hasgoal .lgpm .gri{grid-template-columns:minmax(0,1fr) auto;column-gap:16px;align-items:start}
#root #oc_manifest .lg.hasgoal .gritem{display:block;white-space:normal;overflow-wrap:anywhere;margin-top:4px;padding-left:16px;font:600 16px/1.25 var(--f-cond);letter-spacing:.02em;color:var(--tx-1)}
#root #oc_manifest .lg.hasgoal .lgp .lgr.sc,#root #oc_manifest .lg.hasgoal .lgp .lgr.tot{display:flex;justify-content:space-between;min-height:80px;box-sizing:border-box;margin-top:auto;column-gap:16px}
#root #oc_manifest .lg.hasgoal .lgp .lgr.sc>*,#root #oc_manifest .lg.hasgoal .lgp .lgr.tot>*{align-self:flex-end}
'@

SubRx @'
    if(gr) for(i=0;i<gr.items.length;i++) mh+=row('gr','<span class="lgl">run goals: '+escHtml(ITEMS[gr.items[i]].name.toLowerCase())+'</span>'+cnt(ival(gr.items[i]),'',1));
'@ @'
    if(gr) for(i=0;i<gr.items.length;i++) mh+=row('gr gri','<span class="lgl">run goals <span class="gritem">'+escHtml(ITEMS[gr.items[i]].name.toLowerCase())+'</span></span>'+cnt(ival(gr.items[i]),'',1));   // v28.xx (cw-cx-goalrewardlayout): item names wrap below the reward label, separate from their appraised value.
'@

SubRx @'
  return ['<div class="lg">'+h+'</div>'].concat(rest);
'@ @'
  return ['<div class="lg'+((ex&&G.goalPaid)?' hasgoal':'')+'">'+h+'</div>'].concat(rest);   // v28.xx (cw-cx-goalrewardlayout): align the totals when the reward rows make the money panel taller.
'@

SubRx @'
      rows.push({k:'RUN GOALS',v:'',c:UIC.acc});
'@ @'
      if(!_arc) rows.push({k:'RUN GOALS',v:'',c:UIC.acc});   // v28.xx (cw-cx-goalrewardlayout): the demo already has its goals count as the panel heading.
'@

SubRx @'
var VER='36.33';
'@ @'
var VER='36.34';
'@

$pat = "(?m)^  now:'v36\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.34: Goal cache items keep their full names on wrapping sublines with a 16px gap before the value. Reward cards align score and money totals. Demo goals keep one heading and still show every reward. Check 36.34 fails on v36.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
