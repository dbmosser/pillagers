# ai-keys.ps1 : HE runs this (Claude never does) to store a key for another AI service, so the helper scripts can use it.
# His request 2026-10-19: "Let's figure out how to set up Gemini and chapgpt to integrate." Claude never sees, handles or prints a key:
# the key is typed hidden here, saved as a Windows user variable named PILLAGERS_..., and each helper script hands it only to its
# own program. The PILLAGERS_ names on purpose: a key under the standard name (OPENAI_API_KEY, GEMINI_API_KEY) can make a tool
# bill the key by the token instead of using your subscription sign-in, the same trap as ANTHROPIC_API_KEY.
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1              shows which keys are set (never the key itself)
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini       asks for the Gemini key and saves it
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini -Remove
# Added 2026-10-19 (the move into the VM; keys do not travel with the files, so they are typed again in the VM):
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 console      your normal Anthropic Console API key -> PILLAGERS_API_KEY
#                                                                           (the Console helper lanes: console-lane.sh, console-worker.sh, review-nightly.sh, console-sdk\critic.mjs)
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 admin        your Anthropic ADMIN key -> PILLAGERS_ADMIN_KEY
#                                                                           (the real-spend cost report: console-sdk\balance.mjs). Never ANTHROPIC_API_KEY.
param([string]$Service='',[switch]$Remove)
$names=[ordered]@{ gemini='PILLAGERS_GEMINI_KEY'; openai='PILLAGERS_OPENAI_KEY'; xai='PILLAGERS_XAI_KEY'; openrouter='PILLAGERS_OPENROUTER_KEY'; console='PILLAGERS_API_KEY'; admin='PILLAGERS_ADMIN_KEY' }
function Show {
  ''; 'AI service keys on this PC (the keys themselves are never shown):'
  foreach($k in $names.Keys){ $v=[Environment]::GetEnvironmentVariable($names[$k],'User'); '  {0,-11} {1}' -f $k, $(if($v){'set'}else{'not set'}) }
  '  (console = the helpers on your Anthropic Console credit, saved as PILLAGERS_API_KEY; admin = the real-spend report, saved as PILLAGERS_ADMIN_KEY)'
  ''
}
$Service=$Service.ToLower()
if(-not $Service){ Show; 'To add one: powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini   (or openai, xai, openrouter, console, admin)'; return }
if(-not $names.Contains($Service)){
  # never print the argument back: if a key was pasted here by mistake it must not be echoed again
  if($Service.Length -gt 20 -or $Service -like 'sk-*' -or $Service -like 'aiza*'){ 'That looks like a key, not a service word. Never put a key on the command line: it stays in this window and in its history. Nothing was saved.'; 'If it was a real key, close this window and make a new key at the provider (the old one is now exposed). Then run the script with just a service word and paste the key when it asks.'; "Service words: $($names.Keys -join ', ')"; return }
  'Unknown service word. Use one of: ' + ($names.Keys -join ', '); return
}
$n=$names[$Service]
if($Remove){ [Environment]::SetEnvironmentVariable($n,$null,'User'); "Removed $n."; Show; return }
$sec=Read-Host "Paste your $Service key (it stays hidden), then press Enter" -AsSecureString
$b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try { $plain=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
$plain=$plain.Trim()
if($plain.Length -lt 20){ 'That looks too short to be a key, so nothing was saved. Run it again and paste the whole key.'; return }
# the two Anthropic slots must not be swapped: the helpers need the normal key, the cost report needs the Admin key (only the start of the key is looked at, never shown)
if($Service -eq 'console' -and $plain -like 'sk-ant-admin*'){ $plain=$null; 'That is an ADMIN key. The console slot needs your normal Console API key. Nothing was saved. Use the admin slot for the Admin key: powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 admin'; return }
if($Service -eq 'admin' -and $plain -like 'sk-ant-api*'){ $plain=$null; 'That is a normal API key, not an Admin key. The admin slot needs an Admin key (Anthropic Console, Settings, Admin keys). Nothing was saved. Use the console slot for the normal key: powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 console'; return }
if(($Service -eq 'console' -or $Service -eq 'admin') -and $plain -notlike 'sk-ant-*'){ 'Note: Anthropic keys start with sk-ant-. This one does not, so check it is the right key. It is saved anyway.' }
[Environment]::SetEnvironmentVariable($n,$plain,'User'); $plain=$null
"Saved. Tell Claude 'the $Service key is in' and it takes it from there."
Show
