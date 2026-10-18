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

# Party pages: Press any button is a footer hint, the logo is smaller (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
'@ @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
/* v29.98 (cw-partyprompt), the critic on v29.97 (46, 55, 56, 64 = 3 each): "Press any button is an instruction drawn as a filled button, a fake action", "the logo out-shouts the title", "No scores yet is the one message that matters and it is small and dim", "the ring is unexplained". The prompt is a footer hint now: a button glyph and the words in the accent, pulsing, no fill. The wordmark is the 32px logo on the 5 percent margin. The empty line is 20px light, the seed line a 16px label, the table heads 20px. Restyle only. */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ background:transparent; border-color:transparent; color:var(--acc); padding:0; min-width:0; gap:calc(var(--sp-1) * var(--attz,1)); animation:attpulse 1.6s ease-in-out infinite; }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress::before, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress::before{ content:''; flex:none; box-sizing:border-box; width:calc(var(--sp-3) * var(--attz,1)); height:calc(var(--sp-3) * var(--attz,1)); border:1px solid var(--acc); border-radius:50%; background:radial-gradient(circle, var(--acc) 0 35%, transparent 38%); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage, body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ padding-bottom:calc((var(--sp-4) + var(--sp-3) + var(--btn-h)) * var(--attz,1)); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attname{ left:5%; top:5%; font-size:calc(var(--fs-title) * var(--attz,1)); }
body #attract .arcpage .apn{ color:var(--tx-1); font-weight:700; }
body #attract .arcpage .apb{ font-size:calc(var(--fs-label) * var(--attz,1)); }
body #attract .arcpage .apg{ opacity:.6; }
body #attract .arcpage th{ font-size:calc(var(--fs-body) * var(--attz,1)); }
body #attract .arcpage .aprt{ margin-left:calc(var(--sp-1) * var(--attz,1)); font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
'@

SubRx @'
  if(ring){ k=document.createElement('i'); k.className='aprg'; cell.appendChild(k); }
'@ @'
  if(ring){ k=document.createElement('i'); k.className='aprg'; cell.appendChild(k); k=document.createElement('span'); k.className='aprt'; k.textContent='in the ring'; cell.appendChild(k); }
'@

SubRx @'
var VER='30.00';
'@ @'
var VER='30.01';
'@

$pat = "(?m)^  now:'v30\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.01: The party pages show Press any button as a hint in the card footer. Check 30.01 fails on v30.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
