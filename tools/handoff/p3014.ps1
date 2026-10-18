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

# Operator card: two rows, focus is a bar (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeOpRows(){ return [{id:'party',label:(ARCOP&&ARCOP.arm)?'Confirm new party':'New party'},{id:'exit',label:'Exit demo'},{id:'back',label:'Back'}]; }
'@ @'
function arcadeOpRows(){ return [{id:'party',label:(ARCOP&&ARCOP.arm)?'Confirm new party':'New party'},{id:'exit',label:'Exit demo'}]; }   /* v30.xx (cw-partyop4) critic 62 (3 of 5): Back repeated the X and Esc, three ways to close. The X and Esc close the card */
'@

SubRx @'
    bg=on?(red?'var(--danger-bg)':'var(--acc)'):'var(--ui-raised)';
    fg=on?(red?'var(--danger)':'var(--acc-ink)'):(red?'var(--danger)':'var(--tx-1)');
    bc=red?'var(--danger)':(on?'var(--acc)':'var(--ui-line-hi)');
'@ @'
    bg=on?(red?'var(--danger-bg)':'var(--ui-hover)'):'var(--ui-raised)';   /* v30.xx (cw-partyop4) critic 62 (3 of 5): the focused row was a full width accent slab that read as a row highlight, not the one action. Focus is the shared row look: a raised fill and a 3px accent bar */
    fg=red?'var(--danger)':'var(--tx-1)';
    bc=red?'var(--danger)':'var(--ui-line-hi)';
'@

SubRx @'
      'background:'+bg+';color:'+fg+';border:'+(on?'2px':'1px')+' solid '+bc;
'@ @'
      'background:'+bg+';color:'+fg+';border:1px solid '+bc+';border-left:3px solid '+(on?(red?'var(--danger)':'var(--acc)'):bc)+';';
'@

SubRx @'
var VER='30.13';
'@ @'
var VER='30.14';
'@

$pat = "(?m)^  now:'v30\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.14: The operator card has New party and Exit demo, and the X closes it. Check 30.14 fails on v30.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
