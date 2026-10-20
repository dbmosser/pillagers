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

# PAD RECONNECT CONTRAST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padLostUi(on,ready){
  if(!on&&!PAD.lossUi) return;
  var b=document.getElementById('resumebtn'); if(!b) return;
  if(on){
    if(!PAD.lossUi) PAD.lossUi={text:b.textContent,disabled:b.disabled};
    b.textContent=ready?'resume':'reconnect'; b.disabled=!ready;
  }else{
    var kept=PAD.lossUi; PAD.lossUi=null;
    if(kept){ b.textContent=kept.text; b.disabled=kept.disabled; }
  }
}
'@ @'
function padLostUi(on,ready){
  if(!on&&!PAD.lossUi) return;
  var b=document.getElementById('resumebtn'); if(!b) return;
  // v28.xx (cw-cx-o07-padcontrast): scope the contrast and opaque backdrop to this interruption.
  var box=document.getElementById('pausebox'); if(box) box.classList.toggle('padlost',!!on);
  if(on){
    if(!PAD.lossUi) PAD.lossUi={text:b.textContent,disabled:b.disabled};
    b.textContent=ready?'resume':'reconnect'; b.disabled=!ready;
  }else{
    var kept=PAD.lossUi; PAD.lossUi=null;
    if(kept){ b.textContent=kept.text; b.disabled=kept.disabled; }
  }
}
'@

SubRx @'
#root #pausebox{ --pw:calc(var(--sp-1) * 50); }
'@ @'
#root #pausebox{ --pw:calc(var(--sp-1) * 50); }
/* v28.xx (cw-cx-o07-padcontrast): critic P0, disabled reconnect keeps dark ink on lime; P1, no faint HUD behind this card. */
#root #pausebox.padlost{ background:var(--ui-void) !important; }
#root #pausebox.padlost #resumebtn:disabled{ opacity:1 !important; color:var(--acc-ink) !important; background:var(--acc) !important; border-color:var(--acc) !important; font-weight:700; }
body:has(#pausebox.padlost.on) #hubtoast{ display:none !important; }
'@

SubRx @'
var VER='32.78';
'@ @'
var VER='32.79';
'@

$pat = "(?m)^  now:'v32\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.79: Reconnect uses dark ink at full opacity while disabled. Only the disconnect overlay has an opaque backdrop and hides unrelated page toasts. Recovery restores the ordinary pause appearance. Check 32.79 fails on v32.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
