# ai-keys.ps1 : HE runs this (Claude never does) to store a key for another AI service, so the helper scripts can use it.
# His request 2026-10-19: "Let's figure out how to set up Gemini and chapgpt to integrate." Claude never sees, handles or prints a key:
# the key is typed hidden here, saved as a Windows user variable named PILLAGERS_..., and each helper script hands it only to its
# own program. The PILLAGERS_ names on purpose: a key under the standard name (OPENAI_API_KEY, GEMINI_API_KEY) can make a tool
# bill the key by the token instead of using your subscription sign-in, the same trap as ANTHROPIC_API_KEY.
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1              shows which keys are set (never the key itself)
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini       asks for the Gemini key and saves it
#   powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini -Remove
param([string]$Service='',[switch]$Remove)
$names=[ordered]@{ gemini='PILLAGERS_GEMINI_KEY'; openai='PILLAGERS_OPENAI_KEY'; xai='PILLAGERS_XAI_KEY'; openrouter='PILLAGERS_OPENROUTER_KEY' }
function Show {
  ''; 'AI service keys on this PC (the keys themselves are never shown):'
  foreach($k in $names.Keys){ $v=[Environment]::GetEnvironmentVariable($names[$k],'User'); '  {0,-11} {1}' -f $k, $(if($v){'set'}else{'not set'}) }
  ''
}
$Service=$Service.ToLower()
if(-not $Service){ Show; 'To add one: powershell -ExecutionPolicy Bypass -File tools\ai-keys.ps1 gemini   (or openai, xai, openrouter)'; return }
if(-not $names.Contains($Service)){ "Unknown service '$Service'. Use one of: $($names.Keys -join ', ')"; return }
$n=$names[$Service]
if($Remove){ [Environment]::SetEnvironmentVariable($n,$null,'User'); "Removed $n."; Show; return }
$sec=Read-Host "Paste your $Service key (it stays hidden), then press Enter" -AsSecureString
$b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try { $plain=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
$plain=$plain.Trim()
if($plain.Length -lt 20){ 'That looks too short to be a key, so nothing was saved. Run it again and paste the whole key.'; return }
[Environment]::SetEnvironmentVariable($n,$plain,'User'); $plain=$null
"Saved. Tell Claude 'the $Service key is in' and it takes it from there."
Show
