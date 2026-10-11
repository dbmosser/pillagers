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

# THE OFFER LINE NAMES ONE KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){ it=ITEMS[gi.k]; s=(netSeatName(gi.from)||'Your teammate')+' offers you '+(it?it.name:gi.k)+'.  T or '+padB('Y')+' to take it.  '+Math.ceil(t)+'s'; }
  else if(go&&(t=GIFT_T-((G.t||0)-go.t))>0){ it=ITEMS[go.k]; s='Offered '+(it?it.name:go.k)+' to '+(netSeatName(go.to)||'your teammate')+'. Waiting for them to take it.  '+Math.ceil(t)+'s'; }
'@ @'
  // v22.64, the raid text rewrite (R21): THE OFFER LINE NAMES ONE KEY. It said T or Y to take it whatever was in his hands. It now
  // names the one key of the device in hand, in brackets: Y on a controller (the take button pollPad gives netGiftKey; PADLABEL puts
  // KeyT on RB, so it is never read from there), and the key T is bound to on a keyboard. The parts are split by the middle dot.
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){ it=ITEMS[gi.k]; s=(netSeatName(gi.from)||'Your teammate')+' offers you '+(it?it.name:gi.k)+'  \u00b7  ['+(padOn()?padB('Y'):keyLabel('KeyT','T'))+'] to take it  \u00b7  '+Math.ceil(t)+'s'; }
  else if(go&&(t=GIFT_T-((G.t||0)-go.t))>0){ it=ITEMS[go.k]; s='Offered '+(it?it.name:go.k)+' to '+(netSeatName(go.to)||'your teammate')+'  \u00b7  Waiting  \u00b7  '+Math.ceil(t)+'s'; }
'@

SubRx @'
var VER='22.63';
'@ @'
var VER='22.64';
'@

$pat = "(?m)^  now:'v22\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.64: The trade offer line names one take key, the one of the device in hand. Check 22.64 fails on v22.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
