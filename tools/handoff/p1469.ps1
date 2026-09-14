$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  for(k in COSKEY) if(o.w&&o.w[k]) P[COSKEY[k]]=o.w[k];
'@ @'
  // v14.69, wardrobe audit finding 2: A RESTORE CODE REPLACES THE CLOTHES TOO. A slot the restored character never changed comes
  // through empty, and an empty slot was skipped, so the replaced character's clothes stayed on; and the saved looks and the
  // all cosmetics flag were never touched, so the restored character inherited them. Every slot takes the code's value or
  // none, which reads as the default, and the looks and the flag start clean.
  for(k in COSKEY) P[COSKEY[k]]=(o.w&&o.w[k])||null;
  P.looks=[null,null,null]; P.cosAll=false;
'@
SubRx @'
var VER='14.68';
'@ @'
var VER='14.69';
'@

$pat = "(?m)^  now:'v14\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.69: A RESTORE CODE REPLACES THE CLOTHES TOO. A slot the restored character never changed came through empty and was skipped, so the replaced character kept its clothes on the restored one, and its saved looks and the all cosmetics flag carried over. Every slot now takes the code value or the default, and the looks and the flag start clean. Check 14.69 applies a code from an undressed character over a dressed one; it fails on v14.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
