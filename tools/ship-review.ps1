# ship-review.ps1 : a second AI reads every new ship (the git diff of the game file) and flags likely bugs. Read-only: it only
# writes words into tools\handoff\ship-review\. Costs no Claude usage. Every hit is a lead, not a fact: Claude or a helper
# checks it in the code before anything changes, like the overnight local-model audit (llm-night.ps1).
# His request 2026-10-19: "Let's figure out how to set up Gemini and chapgpt to integrate. Do everything you can by yourself",
# then "explore all options". The research (tools\handoff\ai-services\research.md, fact-checked the same day) put a free local
# model first for this job: no limit, nothing leaves the PC. Free Gemini API keys let Google use what is sent to improve its
# products, and Google may no longer serve free keys in Gemini CLI.
# Engines:
#   ollama (default) : the local model on his RX 7900 XTX, qwen3.8:27b when it is installed, else qwen2.5-coder:32b.
#                      Skipped in his usual PC hours (-QuietHours) so it never costs him frame rate.
#   agy              : Google's Antigravity CLI (the replacement for Gemini CLI since 2026-06-18) in its read-only plan
#                      mode, on the free tier after his one-time sign-in (run agy once: %LOCALAPPDATA%\agy\bin\agy.exe).
#                      Free-tier limits are weekly and unpublished; it rests when it hits them.
#   gemini           : Google's Gemini CLI in plan (read-only) mode with his key saved by tools\ai-keys.ps1 gemini
#                      (PILLAGERS_GEMINI_KEY, handed only to this one program). A paid key is the documented path.
# Output: reviews\<version>-<engine>.md per ship, findings.txt (one line per hit), status-<engine>.txt (one line), run.log
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\ship-review.ps1                 new ships, at most -Max per run
#   ... -Loop -EveryMin 20                                                                     keeps going
#   ... -Engine gemini                                                                         Google instead of the local model
param([ValidateSet('ollama','agy','gemini')][string]$Engine='ollama',[int]$Max=6,[int]$First=3,[string]$Model='',[switch]$Loop,
      [int]$EveryMin=20,[int]$TimeoutMin=15,[string]$QuietHours='6-9,13-16,19-22')
$ErrorActionPreference='Continue'
$R='C:\claudecode\dark raiders'; $O=Join-Path $R 'tools\handoff\ship-review'; $RV=Join-Path $O 'reviews'
New-Item -ItemType Directory -Force $RV | Out-Null
$log=Join-Path $O 'run.log'; $last=Join-Path $O "last-reviewed-$Engine.txt"; $found=Join-Path $O 'findings.txt'; $stat=Join-Path $O "status-$Engine.txt"
$utf8=New-Object Text.UTF8Encoding($false)
$node=(Get-Command node -ErrorAction SilentlyContinue).Source
$gem=if($node){ Join-Path (Split-Path $node) 'node_modules\@google\gemini-cli\bundle\gemini.js' } else { '' }
$api='http://127.0.0.1:11434'
$agy=Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
function Log([string]$m){ "$(Get-Date -Format 'MM-dd HH:mm:ss') [$Engine] $m" | Add-Content $log }
function Status([string]$state,[string]$m){ [IO.File]::WriteAllText($stat, "$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')) $Engine $state $m`n", $utf8) }
function Quiet {
  $h=(Get-Date).Hour
  foreach($span in ($QuietHours -split ',')){ $p=$span -split '-'; if($p.Count -eq 2 -and $h -ge [int]$p[0] -and $h -lt [int]$p[1]){ return $true } }
  return $false
}

$rules=@'
You are a careful senior game programmer reviewing ONE change to PILLAGERS, a single-file HTML5 Canvas 2D top-down
extraction shooter in plain JavaScript (file dark_raiders.html, about 5.5 MB). Below are the commit message and the diff
of that file with 25 lines of context; the @@ headers give line numbers.

Report only REAL bugs that this change introduces or exposes, things that would break or misbehave when the game runs:
- errors: undefined names, wrong argument order, null or undefined access, NaN or Infinity reaching canvas calls
  (createRadialGradient throws on NaN), a variable used before it is set
- logic: wrong or inverted condition, a missed branch, state not reset at raid start or end, a timer that never clears
- two players: code that only handles player 1 when two local players (P1 and P2) are in the raid, or that uses the
  wrong player's input, camera or colour
- performance: new work inside a per-frame loop over all entities or walls that will cost frame time at 4K
- on-screen words: new or changed text the player sees that says raider or raiders (players are pillagers; the enemy
  AI humans are pillager bots)
Do not report style, naming, comments, missing tests, or feature ideas. If you are not fairly sure, leave it out.
Most changes have no bugs, and NONE is a normal answer.

Answer in exactly this format and nothing else:
BUG 1: <line number in dark_raiders.html, or the function name> - <what goes wrong, one sentence> - <the evidence, one sentence>
BUG 2: ...
or the single word NONE
'@

function PickModel {
  if($Model){ return $Model }
  try { $tags=(Invoke-RestMethod "$api/api/tags" -TimeoutSec 10).models.name } catch { return '' }
  foreach($m in @('qwen3.8:27b','qwen3.8:latest','qwen2.5-coder:32b')){ if($tags -contains $m){ return $m } }
  return ''
}

function AskOllama([string]$text,[string]$m){
  $req=@{ model=$m; stream=$false; messages=@(@{ role='user'; content=$text }); options=@{ temperature=0.1; num_ctx=32768; num_predict=4096 } }
  # qwen3.x is a thinking model: without think=false it spends the whole 4096-token budget thinking and returns an empty answer (10-19)
  if($m -like 'qwen3*'){ $req.think=$false }
  $body=$req | ConvertTo-Json -Depth 5
  try {
    $r=Invoke-RestMethod -Uri "$api/api/chat" -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($body)) -ContentType 'application/json; charset=utf-8' -TimeoutSec ($TimeoutMin*60)
    Log "answer $($r.eval_count) tok in $([math]::Round($r.eval_duration/1e9,1)) s, prompt $($r.prompt_eval_count) tok, model $m"
    return @{ resp=[string]$r.message.content; err='' }
  } catch { return @{ resp=''; err="no answer from the local model: $($_.Exception.Message)" } }
}

function AskGemini([string]$text){
  $in=Join-Path $O 'input.txt'; $out=Join-Path $O 'out.json'; $err=Join-Path $O 'err.txt'
  [IO.File]::WriteAllText($in, $text, $utf8)
  $a=@("`"$gem`"",'-p','"Do the review described at the top of this input. Reply only in the format given there."','--approval-mode','plan','-o','json')
  if($Model){ $a+=@('-m',$Model) }
  $k=[Environment]::GetEnvironmentVariable('PILLAGERS_GEMINI_KEY','User'); if($k){ $env:GEMINI_API_KEY=$k }; $k=$null
  try {
    $p=Start-Process -FilePath $node -ArgumentList $a -WorkingDirectory $R -NoNewWindow -PassThru `
       -RedirectStandardInput $in -RedirectStandardOutput $out -RedirectStandardError $err
    if(-not $p.WaitForExit($TimeoutMin*60000)){ try{ $p.Kill() }catch{}; return @{ resp=''; err="timed out after $TimeoutMin min" } }
  } finally { Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue }
  $o=if(Test-Path $out){ [IO.File]::ReadAllText($out) } else { '' }; $e=if(Test-Path $err){ [IO.File]::ReadAllText($err) } else { '' }
  $resp=''; try { $j=$o | ConvertFrom-Json; $resp=[string]$j.response; if($j.error){ $e+=' '+($j.error | ConvertTo-Json -Compress -Depth 4) } } catch {}
  return @{ resp=$resp; err=(($e+' '+$o) -replace '\s+',' ').Trim() }
}

function AskAgy([string]$text){
  $in=Join-Path $O 'input.txt'; $out=Join-Path $O 'out.json'; $err=Join-Path $O 'err.txt'
  [IO.File]::WriteAllText($in, $text, $utf8)
  $a=@('-p','"Open the file tools/handoff/ship-review/input.txt with your file viewing tool and do the review it describes. Never run shell or terminal commands (they are refused); to check other code, use your file viewing and search tools on dark_raiders.html. Reply only in the format given there."',
       '--mode','plan','--output-format','json','--print-timeout',"$($TimeoutMin)m")
  if($Model){ $a+=@('--model',$Model) }
  $p=Start-Process -FilePath $agy -ArgumentList $a -WorkingDirectory $R -NoNewWindow -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
  if(-not $p.WaitForExit(($TimeoutMin+1)*60000)){ try{ $p.Kill() }catch{}; return @{ resp=''; err="timed out after $TimeoutMin min" } }
  $o=if(Test-Path $out){ [IO.File]::ReadAllText($out) } else { '' }; $e=if(Test-Path $err){ [IO.File]::ReadAllText($err) } else { '' }
  $resp=''; try { $j=$o | ConvertFrom-Json; $resp=[string]$j.response; if($j.error){ $e+=' '+($j.error | ConvertTo-Json -Compress -Depth 4) } } catch {}
  return @{ resp=$resp; err=(($e+' '+$o) -replace '\s+',' ').Trim() }
}

function ReviewOne([string]$sha,[string]$m){
  $subj=(git -C $R log -1 --format=%s $sha) -join ' '
  $ver=if($subj -match '^(v\d+\.\d+)'){ $Matches[1] } else { $sha.Substring(0,8) }
  $diff=(git -C $R show --format= --no-color -U25 $sha -- dark_raiders.html) -join "`n"
  if(-not $diff.Trim()){ Log "$ver no game change, skipped"; return 'ok' }
  $cap=if($Engine -eq 'ollama'){ 60000 } else { 150000 }
  $cut=''; if($diff.Length -gt $cap){ $diff=$diff.Substring(0,$cap); $cut="`n[diff cut at $cap characters]" }
  $text="$rules`nCOMMIT: $subj`n`nDIFF:`n$diff$cut`n"
  $a=if($Engine -eq 'ollama'){ AskOllama $text $m } elseif($Engine -eq 'agy'){ AskAgy $text } else { AskGemini $text }
  $resp=$a.resp.Trim()
  if(-not $resp){
    $why=$a.err; if($why.Length -gt 300){ $why=$why.Substring(0,300) }
    if($why -match 'quota|429|RESOURCE_EXHAUSTED|rate.?limit'){ Status 'resting' 'the daily limit is used up; it tries again later'; Log "$ver quota: $why"; return 'stop' }
    if($Engine -ne 'ollama' -and $why -match 'Authentication required|auth|API key|GEMINI_API_KEY|sign.?in|login|credential'){ Status 'needs-you' "$Engine is not signed in yet"; Log "$ver sign-in: $why"; return 'stop' }
    Log "$ver no answer: $why"; return 'retry'
  }
  $tag=if($Engine -eq 'ollama'){ "the local model $m" } elseif($Engine -eq 'agy'){ 'Antigravity (Google)' } else { 'Gemini' }
  [IO.File]::WriteAllText((Join-Path $RV "$ver-$Engine.md"), "# $subj`n`ncommit $sha, reviewed $(Get-Date -Format 'yyyy-MM-dd HH:mm') by $tag (read-only)`n`n$resp`n", $utf8)
  $bugs=@($resp -split "`n" | ForEach-Object { $_.Trim() -replace '^[\-\*\s`#]+','' -replace '\*\*','' } | Where-Object { $_ -match '^BUG\s*\d+' })
  foreach($b in $bugs){ "$ver [$Engine]  $b" | Add-Content $found }
  Log "$ver reviewed: $($bugs.Count) possible bug(s)"
  return 'ok'
}

function RunOnce {
  $m=''
  if($Engine -eq 'ollama'){
    if(Quiet){ Status 'resting' "his usual PC hours ($QuietHours), so the graphics card stays free for him"; return }
    $m=PickModel; if(-not $m){ Status 'broken' 'the local AI (Ollama) is not running or has no model'; return }
  } elseif($Engine -eq 'agy'){ if(-not (Test-Path $agy)){ Status 'broken' 'Antigravity is not installed'; return } }
  elseif(-not (Test-Path $gem)){ Status 'broken' 'the Gemini program is not installed (npm install -g @google/gemini-cli)'; return }
  $head=(git -C $R rev-parse master).Trim()
  $from=if(Test-Path $last){ (Get-Content $last -TotalCount 1).Trim() } else { '' }
  $list=if($from){ @(git -C $R rev-list --reverse "$from..$head") } else { @(git -C $R rev-list --reverse -n $First $head) }
  if(-not $list.Count){ Status 'ok' 'up to date'; return }
  $n=0
  foreach($s in $list){
    if($n -ge $Max){ break }
    $r=ReviewOne $s $m
    if($r -eq 'stop'){ return }
    if($r -eq 'retry'){ Status 'ok' 'one review failed; it tries again next round'; return }
    [IO.File]::WriteAllText($last, "$s`n", $utf8); $n++
  }
  $left=$list.Count-$n
  Status 'ok' ("reviewed $n new ship(s)" + $(if($left -gt 0){", $left waiting"}else{''}))
}

do { RunOnce; if($Loop){ Start-Sleep ($EveryMin*60) } } while($Loop)
