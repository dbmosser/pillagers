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

# RETIRE: THE BUTTON READS AS DANGER, THE PAD CONFIRM STARTS ON NOT YET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pilRetireAsk(){
'@ @'
// v37.xx (cw-m2retire2), the critic on the confirm card: on a pad the focus starts on not yet, so a double tap of A never ends a pillager.
function pilRetireAsk(){ pilRetireAskOpen(); try{ if(padOn()) padSetFocus(document.getElementById('askno')); }catch(_pra){} }
function pilRetireAskOpen(){
'@

SubRx @'
    #root #opane_hall #hallretire{ min-height:56px; padding:0 24px; font:700 24px/1 var(--f-cond); white-space:pre; text-transform:none; }
'@ @'
    #root #opane_hall #hallretire{ min-height:56px; padding:0 24px; font:700 24px/1 var(--f-cond); white-space:pre; text-transform:none; }
    #root #opane_hall #hallretire:not(:disabled){ border-color:var(--danger); color:var(--danger); }   /* v37.xx (cw-m2retire2), critic P1: retiring ends this pillager, and the button looked like any other */
'@

SubRx @'
var VER='37.38';
'@ @'
var VER='37.39';
'@

$pat = "(?m)^  now:'v37\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.39: the retire button has a red border and red text while it can be pressed; on a pad the confirm card starts on not yet Check 37.39 fails on v37.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
