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

# PLAYER 2 CHOOSES EASY OR NORMAL TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(m.arc&&_lr==='up'&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ ARCADE.wantIn=0; ARCADE.late=0; }   // v23.25 (arcade6): in; a later arcade word is taken because he is in an arcade raid
'@ @'
  if(m.arc&&_lr==='up'&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ ARCADE.wantIn=0; ARCADE.late=0; }   // v23.25 (arcade6): in; a later arcade word is taken because he is in an arcade raid
  if(m.arc&&_lr==='up'&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='p2'){ try{ easyStartAsk(); }catch(_esa){} }   // v35.48 (cloud-p2-easy-card), CLOUD AUDIT 2026-10-28: his 2.28 c, EACH player chooses easy or normal as a run starts. Only arcadeDeploy (player 1) asked, so player 2 never saw the card and kept a yes from the run before
'@

SubRx @'
var VER='35.47';
'@ @'
var VER='35.48';
'@

$pat = "(?m)^  now:'v35\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.48: player 2 also chooses easy or normal Check 35.48 fails on v35.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
