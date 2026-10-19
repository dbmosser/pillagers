# llm-night.ps1 : overnight work for the local model (Ollama, qwen3.8:27b since 10-19, was qwen2.5-coder:32b, on his RX 7900 XTX). Free: no Claude usage.
# His request 2026-10-13: "i mean I am about to leave it on all night, just like i do every night -- can't we do something with that?!?"
# Writes reports to tools\handoff\llm-night\ ; Claude reads the short summaries in the morning and verifies the top hits.
#   1. leftovers.txt  : exact grep for names and words of systems he removed (deterministic, instant)
#   2. text-audit.md  : every player-facing string, checked by the model against his text and key rules
#   3. code-sweep.md  : the game file in 300-line chunks, checked by the model for likely bugs
# Read-only on the game. Safe to rerun; each report is rewritten.
param([string]$Model='qwen3.8:27b',[int]$Chunk=200,[int]$Batch=30,[switch]$SkipCode,[string]$Since='')
$ErrorActionPreference='Continue'
$R='C:\claudecode\dark raiders'; $G=Join-Path $R 'dark_raiders.html'; $O=Join-Path $R 'tools\handoff\llm-night'
New-Item -ItemType Directory -Force $O | Out-Null
$lines=[IO.File]::ReadAllLines($G)
$api='http://127.0.0.1:11434/api/generate'
function Ask([string]$prompt,[int]$max=500){
  # 2026-10-13: the first run let the model ramble (no cap): one batch took 30 min. Cap the answer and keep the context small.
  $body=@{ model=$Model; prompt=$prompt; stream=$false; think=$false; options=@{ temperature=0.1; num_ctx=8192; num_predict=$max; repeat_penalty=1.15 } } | ConvertTo-Json -Depth 4
  for($t=0;$t -lt 2;$t++){
    try{ $r=Invoke-RestMethod -Uri $api -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 900
         "$(Get-Date -Format 'HH:mm:ss') answer $($r.eval_count) tok in $([math]::Round($r.eval_duration/1e9,1)) s, prompt $($r.prompt_eval_count) tok" | Add-Content $log
         $r.response | Add-Content $raw
         return [string]$r.response }
    catch{ Start-Sleep 20 }
  }
  return 'ERROR: no answer from the local model'
}
function Hits([string]$a,[string]$tag){ return @($a -split "`n" | ForEach-Object { $_.Trim() -replace '^[\-\*\s`#]+','' -replace '\*\*','' } | Where-Object { $_ -match "^$tag\s*\d+" }) }
$log=Join-Path $O 'run.log'; $raw=Join-Path $O 'raw-answers.txt'; '' | Set-Content $raw
"$(Get-Date -Format 'MM-dd HH:mm') start, model $Model, $($lines.Count) lines" | Set-Content $log

# 1. leftovers (exact)
$dead=@('taunt(','TAUNT','voxBark','voxCall','VOX_ANN','VOX_BARKS','GO_SEC','goTick','drawGoCount','doEmote','EMOTES','emoteBubble','MACH_LOOP','diedWithMed','stowLine','OTHER GUN','HEAVY BACKPACK','LOADED BACKPACK','LIGHT BACKPACK','Search resumed','machines inbound','SOMETHING HUGE','HALLOWEEN','pumpkin','JAMMED','jam>','p.jam','hold E to extract','HOLD [E] TO EXTRACT','[V]','weak spot','WEAK SPOT','headshot')
$out=New-Object System.Collections.Generic.List[string]
for($i=0;$i -lt $lines.Count;$i++){ $L=$lines[$i]; foreach($d in $dead){ if($L.Contains($d)){ $s=$L.Trim(); if($s.Length -gt 220){ $s=$s.Substring(0,220) }; $out.Add(('{0,6}  [{1}]  {2}' -f ($i+1),$d,$s)); break } } }
$out | Set-Content (Join-Path $O 'leftovers.txt')
"$(Get-Date -Format 'HH:mm') leftovers: $($out.Count) lines" | Add-Content $log

# 2. text audit
$rx=@("say\('([^']{6,})'","label\([^,]+,[^,]+,'([^']{6,})'","fillText\('([^']{6,})'","sub:'([^']{6,})'","textContent\s*=\s*'([^']{6,})'","innerHTML\s*=\s*'([^'<]{6,})","^\s*'([A-Z][A-Z ,.!?']{8,}[^']*)',\s*$")
# 2026-10-14 (his "ok lets do all that"): narrowed. Night 1 flagged 107 lines, almost all old What's New history entries, which never show
# in a raid. So: skip the WHATSNEW history array, and with -Since audit only strings on lines changed since that commit (the day's work).
$wnA=-1; $wnB=-1
for($i=0;$i -lt $lines.Count;$i++){ if($wnA -lt 0 -and $lines[$i] -match '^\s*var WHATSNEW\s*=\s*\['){ $wnA=$i } elseif($wnA -ge 0 -and $lines[$i] -match '^\s*\];'){ $wnB=$i; break } }
$chg=$null
if($Since){ $chg=@{}; $dd=& git -C $R diff -U0 "$Since..HEAD" -- dark_raiders.html 2>$null
  foreach($h in $dd){ if($h -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@'){ $c=[int]$Matches[1]; $n=1; if($Matches[2] -ne $null -and $Matches[2] -ne ''){ $n=[int]$Matches[2] }; for($q=$c;$q -lt $c+$n;$q++){ $chg[$q]=1 } } } }
$seen=@{}; $items=New-Object System.Collections.Generic.List[string]
for($i=0;$i -lt $lines.Count;$i++){ $L=$lines[$i]; $tl=$L.TrimStart(); if($tl.StartsWith('//')){ continue }
  if($wnA -ge 0 -and $i -ge $wnA -and ($wnB -lt 0 -or $i -le $wnB)){ continue }
  if($chg -ne $null -and -not $chg.ContainsKey($i+1)){ continue }
  foreach($x in $rx){ foreach($m in [regex]::Matches($L,$x)){ $s=$m.Groups[1].Value; if(-not $seen.ContainsKey($s)){ $seen[$s]=1; $items.Add("L$($i+1): $s") } } } }
$rules=@'
You audit player-facing text in PILLAGERS, a top-down 2.5D extraction shooter (DEMO arcade mode and CAREER mode). The owner's rules:
1. In-raid callouts are terse ALL-CAPS HUD lines like a AAA shooter (LOCATION REVEALED, SIEGE INCOMING, EXTRACTION CALLED), with at most a short detail. Never an explaining sentence.
2. Keys: E search/use (never extraction), X call and board extraction, G throw the chosen grenade, U next grenade, H use the chosen heal (hold H = armour plate), J next heal, 5-6 throw that grenade, 7-8 use that heal, 9 plate, Q crowbar melee, F next gun, F1 controls list, middle mouse ping, hold Alt raid status, R reload, 1-4 guns. Text naming another key for these actions is wrong.
3. Removed, must not be mentioned or promised: any voice, announcer, barks or taunts; emotes; the 3-2-1 GO countdown; backpack sizes (LIGHT/LOADED/HEAVY BACKPACK); "search resumed"; how many machines a siege brings; weak spots or headshots on pillagers or players (machines may have weak spots); guns wearing out or jamming; Halloween; the second map THE COLD MILE.
4. Gameplay is identical in DEMO and CAREER; text must not claim otherwise.
For the numbered lines below, list ONLY the lines that break a rule, one per line, as: L<number>: <problem> => <suggested fix>. If none break a rule, answer NONE. No other words.
'@
"# Text audit ($($items.Count) strings, model $Model, $(Get-Date -Format 'MM-dd HH:mm'))`n" | Set-Content (Join-Path $O 'text-audit.md')
for($b=0;$b -lt $items.Count;$b+=$Batch){
  $part=$items.GetRange($b,[Math]::Min($Batch,$items.Count-$b)) -join "`n"
  $a=(Ask ($rules+"`n"+$part)).Trim()
  Hits $a 'L' | Add-Content (Join-Path $O 'text-audit.md')
  "$(Get-Date -Format 'HH:mm') text batch $([int]($b/$Batch)+1) of $([math]::Ceiling($items.Count/$Batch))" | Add-Content $log
}

# 3. code sweep
if(-not $SkipCode){
$crules=@'
You review a chunk of a single-file JavaScript Canvas 2D game (PILLAGERS). Report only CONCRETE likely bugs you can point at in this chunk:
- calls or reads of names from removed systems (taunt, TAUNT, voxBark, voxCall, VOX_ANN, GO_SEC, goTick, drawGoCount, doEmote, EMOTES, emoteBubble, MACH_LOOP, stowLine)
- possible NaN or undefined values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions)
- property access on a value that can be null or undefined in per-frame code without a guard
- assignment used where a comparison was meant, duplicate object keys, code after an unconditional return, a variable used before it is set
- a try/catch that swallows a whole per-frame draw or update
Do not report style, naming, comments or performance. Each finding on its own line as: LINE <number>: <problem>. At most 5 findings. If nothing concrete, answer NONE.
'@
"# Code sweep (chunks of $Chunk lines, model $Model, $(Get-Date -Format 'MM-dd HH:mm'), since $Since)`n" | Set-Content (Join-Path $O 'code-sweep.md')
# 2026-10-13: at ~3 tok/s on his card a whole-file sweep takes 12+ h, so by default only the chunks holding lines changed since -Since are swept.
$want=@{}
if($Since){
  $d=& git -C $R diff -U0 "$Since..HEAD" -- dark_raiders.html 2>$null
  foreach($h in $d){ if($h -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@'){ $c=[int]$Matches[1]; $n=1; if($Matches[2] -ne $null -and $Matches[2] -ne ''){ $n=[int]$Matches[2] }; for($q=$c;$q -lt $c+[Math]::Max(1,$n);$q++){ $want[[int][math]::Floor(($q-1)/$Chunk)]=1 } } }
  "$(Get-Date -Format 'HH:mm') code sweep limited to $($want.Count) of $([math]::Ceiling($lines.Count/$Chunk)) chunks changed since $Since" | Add-Content $log
}
for($s=0;$s -lt $lines.Count;$s+=$Chunk){
  if($Since -and -not $want.ContainsKey([int]($s/$Chunk))){ continue }
  $e=[Math]::Min($s+$Chunk,$lines.Count)-1; $sb=New-Object Text.StringBuilder
  for($k=$s;$k -le $e;$k++){ $t=$lines[$k]; $tt=$t.TrimStart(); if($tt.StartsWith('//') -or $tt.Length -eq 0){ continue }; $ci=$t.IndexOf('   // '); if($ci -gt 0){ $t=$t.Substring(0,$ci) }; if($t.Length -gt 260){ $t=$t.Substring(0,260) }; [void]$sb.AppendLine(('{0}: {1}' -f ($k+1),$t)) }
  $a=(Ask ($crules+"`n"+$sb.ToString()) 300).Trim()
  Hits $a 'LINE' | Add-Content (Join-Path $O 'code-sweep.md')
  "$(Get-Date -Format 'HH:mm') code chunk $([int]($s/$Chunk)+1) of $([math]::Ceiling($lines.Count/$Chunk))" | Add-Content $log
}
}
"$(Get-Date -Format 'MM-dd HH:mm') done" | Add-Content $log
