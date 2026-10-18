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

# Abandoned card: the loot left behind is a 56px figure (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocnote{ display:block; margin:24px 0; font-family:var(--f-cond); font-size:24px; font-weight:700; line-height:1.2; color:var(--tx-1); }
'@ @'
  #root .ocnote{ display:block; margin:24px 0; font-family:var(--f-cond); font-size:24px; font-weight:700; line-height:1.2; color:var(--tx-1); }
  /* v28.xx (cw-abhero), the critic on the Abandoned card (2 of 5, P0): "there is no 56px hero line, the key message is a 22px sentence in the same weight as the title and stats". The loss is the 56px figure with a 16px label under it, the same shape as the Killed card. The sentence stays in the card as hidden text (the checks read it). The XP line is 16px. Words unchanged. */
  #root .ocnote.ocsr{ display:none; }
  #root #oc_manifest span[style*="var(--amber)"]{ font-size:16px; line-height:1.4; }
'@

SubRx @'
    lines.push('<span class="ocnote">Run abandoned. '+'$'+haul.toLocaleString()+' left behind.</span>');   // v28.xx (cw-endcard-clean): the same words, its own bone line (critic on screen 60: no focal line)
'@ @'
    lines.push('<span class="ocnote ocsr">Run abandoned. '+'$'+haul.toLocaleString()+' left behind.</span><div class="ocloss"><b>\x24'+haul.toLocaleString()+'</b><span>Left behind</span></div>');   /* v28.xx (cw-abhero): the loss is the 56px figure over a 16px label; the same words stay in the hidden line (critic on screen 60: no hero line) */
'@

SubRx @'
var VER='29.98';
'@ @'
var VER='29.99';
'@

$pat = "(?m)^  now:'v29\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.99: Abandoned card: the loot left behind is a big figure with a label. Check 29.99 fails on v29.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
