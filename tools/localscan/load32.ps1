# Loads the 32b coder the lean way and measures system RAM. He accepted the crash risk (2026-09-29); a last-resort
# cutoff still unloads the model if available RAM falls under -FloorMB.
#   powershell -File tools\localscan\load32.ps1 [-Model qwen2.5-coder:32b] [-Ctx 8192] [-Mmap 1] [-FloorMB 1000]
param([string]$Model='qwen2.5-coder:32b',[int]$Ctx=8192,[int]$Mmap=1,[int]$FloorMB=1000,[switch]$Restart)
$ol="$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
function Avail(){ [math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue) }
if($Restart){
  # Our own server, only for this run: flash attention and a q8 KV cache (smaller context memory). Nothing persistent.
  Get-Process 'ollama app','ollama' -ErrorAction SilentlyContinue | Stop-Process -Force; Start-Sleep 2
  $env:OLLAMA_FLASH_ATTENTION='1'; $env:OLLAMA_KV_CACHE_TYPE='q8_0'
  Start-Process -FilePath $ol -ArgumentList 'serve' -WindowStyle Hidden
  for($i=0;$i -lt 30;$i++){ try{ Invoke-RestMethod http://127.0.0.1:11434/api/version -TimeoutSec 2 | Out-Null; break }catch{ Start-Sleep 1 } }
}
$a0=Avail
$opt=@{ num_ctx=$Ctx; temperature=0.1 }; if($Mmap){ $opt.use_mmap=$true }
$body=@{ model=$Model; stream=$false; prompt='Reply with the single word ready.'; options=$opt } | ConvertTo-Json -Depth 4
$job=Start-Job { param($b) Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/generate' -Method Post -Body $b -ContentType 'application/json' -TimeoutSec 900 } -ArgumentList $body
$low=999999; $t0=Get-Date; $cut=$false
while($job.State -eq 'Running' -and ((Get-Date)-$t0).TotalSeconds -lt 900){
  Start-Sleep -Milliseconds 700; $a=Avail; if($a -lt $low){ $low=$a }
  if($a -lt $FloorMB){ & $ol stop $Model | Out-Null; $cut=$true; break }
}
$r=Receive-Job $job -ErrorAction SilentlyContinue; Remove-Job $job -Force
Start-Sleep 20
$p=Get-Process llama-server -ErrorAction SilentlyContinue | Sort-Object WorkingSet64 -Descending | Select-Object -First 1
$ps=try{ (Invoke-RestMethod http://127.0.0.1:11434/api/ps).models | Select-Object -First 1 }catch{ $null }
"available before $a0 MB, lowest during load $low MB, 20 s after load " + (Avail) + " MB" + $(if($cut){ ' (CUT OFF at the floor)' }else{ '' })
if($p){ "model process: working set " + [math]::Round($p.WorkingSet64/1GB,1) + " GB, private " + [math]::Round($p.PrivateMemorySize64/1GB,1) + " GB" }
if($ps){ "on the graphics card: " + [math]::Round($ps.size_vram/1GB,1) + " of " + [math]::Round($ps.size/1GB,1) + " GB" }
"answer: " + $r.response + ", load took " + [int]((Get-Date)-$t0).TotalSeconds + " s"
