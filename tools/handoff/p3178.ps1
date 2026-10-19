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

# END CARDS: FLAT CHIPS, ABANDON CONFIRM X AND COST LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #oc_manifest span[style*="var(--amber)"]{ font-size:16px; line-height:1.4; }

'@ @'
  #root #oc_manifest span[style*="var(--amber)"]{ font-size:16px; line-height:1.4; }
  /* v28.xx (cw-endflat), the critic on 38, 60 and 77 (3 and 2 of 5): "the badges and the challenge pill are boxed chips that read as buttons, the feedback link is a fourth control". His Q43 (the card has an X). A chip is now a flat 16px tx-2 name with a middle dot between names and no box; the contract line gets a green tick. The words are unchanged. */
  #root .ocachs{ gap:4px 8px; margin:24px 0 8px; }
  #root .ocach, #root .ocach.ocok{ padding:0; background:transparent; border:0; border-radius:0; font-size:16px; line-height:1.4; color:var(--tx-2); }
  #root .ocach:not(:last-child)::after{ content:'\00b7'; margin-left:8px; color:var(--ui-line-hi); }
  #root .ocach.ocok::before{ content:'\2713'; margin-right:8px; color:var(--ok); }
  #root #confirmabandon small{ display:block; margin-top:4px; font-size:16px; font-weight:400; letter-spacing:.04em; line-height:1.2; color:var(--tx-2); }
'@

SubRx @'
#root #pausebox.asking #pausex{ display:none; }

'@ @'
/* v28.xx (cw-endflat), the critic on 59 (3 of 5): "no close control". Armed, the pause box keeps its X: it is the Keep playing twin (it clicks resume, which disarms), so it adds no new way out. */

'@

SubRx @'
    cb.textContent=(G&&G.arcade)?'YES, ABANDON THIS RUN':(_el>60)?('YES, ABANDON THIS RUN ('+(_ac>0?('costs '+_ac+' XP'):'no XP to lose')+')')
                           :'YES, ABANDON THIS RUN (free this early)';

'@ @'
    /* v28.xx (cw-endflat), the critic on 59: "an explaining parenthetical on the danger button". Q8, reason logged in notes/ui/changes.md: the cost is its own quiet 16px line under the button words, not a bracket inside them. */
    cb.innerHTML=(G&&G.arcade)?'YES, ABANDON THIS RUN':'YES, ABANDON THIS RUN <small>'+((_el>60)?(_ac>0?('costs '+_ac+' XP'):'no XP to lose'):'free this early')+'</small>';

'@

SubRx @'
var VER='31.77';
'@ @'
var VER='31.78';
'@

$pat = "(?m)^  now:'v31\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.78: Chips are flat names with dots. The contract line has a tick. The armed abandon confirm keeps its X and shows its cost on its own line. Check 31.78 fails on v31.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
