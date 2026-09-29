# Local first-pass bug scan on his GPU (Ollama). Feeds dark_raiders.html to a local model in overlapping chunks and
# writes what it flags to out\scan-<stamp>.jsonl, one JSON object per suspected defect, with absolute line numbers.
# A local model raises false alarms: every hit is a lead for a reviewer to verify in the code, never a fix by itself.
#   powershell -File tools\localscan\scan.ps1 [-Model qwen2.5-coder:32b] [-From 1] [-To 0] [-Chunk 260] [-Grep 'net']
# -Grep keeps only chunks whose text matches the regex (a focus area). -To 0 means the end of the file.
param([string]$Model='qwen2.5-coder:32b',[int]$From=1,[int]$To=0,[int]$Chunk=260,[int]$Overlap=30,[string]$Grep='',[int]$Ctx=16384)
$ErrorActionPreference='Stop'
$root='C:\claudecode\dark raiders'
$lines=[IO.File]::ReadAllLines("$root\dark_raiders.html")
if($To -le 0 -or $To -gt $lines.Length){ $To=$lines.Length }
$outDir=Join-Path $PSScriptRoot 'out'; New-Item -ItemType Directory -Force $outDir | Out-Null
$stamp=(Get-Date).ToString('yyyyMMdd-HHmm'); $out=Join-Path $outDir "scan-$stamp.jsonl"
$sys=@'
You review one section of a large single-file JavaScript browser game (a top-down extraction shooter with a two-window
co-op mode). Report only concrete defects you can see in THIS section: a variable used before it is set or after it is
cleared, a wrong variable or property name, an inverted or always-true/always-false condition, a state flag set but never
reset on some path, a timer or listener never removed, a value that can become NaN or undefined and is then used, an
off-by-one in a loop or index, an item or count that can be lost or duplicated, an early return that skips needed cleanup.
Do NOT report style, naming, comments, performance, missing features, or numbers that look like tuning. Do NOT guess about
code outside the section. Answer with JSON only: {"defects":[{"line":<line number as printed>,"what":"<one sentence>",
"why":"<one sentence naming the exact code>","confidence":"high|medium|low"}]} and {"defects":[]} when you see none.
'@
$n=0; $hits=0; $t0=Get-Date
for($s=$From; $s -le $To; $s+=($Chunk-$Overlap)){
  $e=[Math]::Min($To,$s+$Chunk-1)
  $sb=New-Object Text.StringBuilder
  for($i=$s;$i -le $e;$i++){ [void]$sb.Append($i).Append(': ').AppendLine($lines[$i-1]) }
  $txt=$sb.ToString()
  if($Grep -and $txt -notmatch $Grep){ if($e -ge $To){ break }; continue }
  $body=@{ model=$Model; stream=$false; format='json'; system=$sys; prompt=("SECTION, lines $s to $e`n"+$txt);
           options=@{ temperature=0.1; num_ctx=$Ctx } } | ConvertTo-Json -Depth 5
  try{
    $r=Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/generate' -Method Post -Body ([Text.Encoding]::UTF8.GetBytes($body)) -ContentType 'application/json' -TimeoutSec 900
    $j=$r.response | ConvertFrom-Json
    foreach($d in @($j.defects)){ if(-not $d -or -not $d.line){ continue }
      $o=[ordered]@{ line=[int]$d.line; what=[string]$d.what; why=[string]$d.why; confidence=[string]$d.confidence; chunk="$s-$e" }
      Add-Content -Path $out -Value ($o | ConvertTo-Json -Compress) -Encoding UTF8; $hits++ }
  }catch{ Add-Content -Path $out -Value (@{ chunk="$s-$e"; error=$_.Exception.Message } | ConvertTo-Json -Compress) -Encoding UTF8 }
  $n++
  if($e -ge $To){ break }
}
"scanned $n chunks of lines $From-$To in $([int]((Get-Date)-$t0).TotalMinutes) min, $hits suspected defects -> $out"
