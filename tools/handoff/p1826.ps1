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

# SHORT DARK HAIR IS THE DEFAULT LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var COSDEF={hair:'blonde',hat:'none',build:'lean',skin:'fair',fit:'slate',cut:'long',beard:'clean',eyes:'eyebrown',face:'faceplain',boots:'bootblack',gloves:'barehands',pack:'packbrown',patch:'patchnone',tattoo:'tatnone',outfit:'outnone'};
'@ @'
var COSDEF={hair:'dark',hat:'none',build:'lean',skin:'fair',fit:'slate',cut:'crop',beard:'clean',eyes:'eyebrown',face:'faceplain',boots:'bootblack',gloves:'barehands',pack:'packbrown',patch:'patchnone',tattoo:'tatnone',outfit:'outnone'};   // v18.26, HIS ORDER (2026-10-03): short dark hair is the default look; a new character wore long blonde, which read as a gold outline round the face
'@

SubRx @'
  {id:'dark',   name:'Dark',           how:'runs:3',      kind:'hair'},
'@ @'
  {id:'dark',   name:'Dark',           how:'always',      kind:'hair'},   // v18.26: the default, so it is never shown locked (was runs:3)
'@

SubRx @'
var VER='18.25';
'@ @'
var VER='18.26';
'@

$pat = "(?m)^  now:'v18\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.26: New characters start with short dark hair. Check 18.26 fails on v18.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
