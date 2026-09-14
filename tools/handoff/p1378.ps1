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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 6: THE EXTRACTED CARD COUNTED THE ISSUED
# BANDAGES AS ITEMS SECURED. Since v13.54 the issued Bandages still carried go back to the
# quartermaster and are skipped at banking, but the card line still read the whole backpack and
# the whole haul: two issued Bandages and one find printed 3 items secured, with 120 of
# Bandages in the figure, while one item reached the stash. The line now counts what was
# banked: the backpack less the Bandages handed back, and the haul less their value.
SubRx @'
    for(i=0;i<G.bag.length;i++){ if(_issB>0&&G.bag[i]==='bandage'){ _issB--; continue; } var bm=bankItem(G.bag[i]); if(bm) lines.push(bm); }
'@ @'
    var _issN=0;   // v13.78: how many issued Bandages were handed back, for the secured line below
    for(i=0;i<G.bag.length;i++){ if(_issB>0&&G.bag[i]==='bandage'){ _issB--; _issN++; continue; } var bm=bankItem(G.bag[i]); if(bm) lines.push(bm); }
'@
SubRx @'
    lines.push(G.bag.length+' item'+(G.bag.length===1?'':'s')+' secured for '+'$'+haul.toLocaleString()+'');
'@ @'
    // v13.78, downed and extraction audit: the issued Bandages handed back were not secured.
    var _secN=G.bag.length-(_issN||0), _secV=Math.max(0,haul-(_issN||0)*ival('bandage'));
    lines.push(_secN+' item'+(_secN===1?'':'s')+' secured for '+'$'+_secV.toLocaleString()+'');
'@
SubRx @'
var VER='13.77';
'@ @'
var VER='13.78';
'@

$pat = "(?m)^  now:'v13\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.78: THE EXTRACTED CARD COUNTS ONLY WHAT WAS SECURED. Downed and extraction audit of 2026-09-14, finding 6: since v13.54 issued Bandages still carried go back to the quartermaster and are skipped at banking, but the card line read the whole backpack and haul, so two issued Bandages and one find printed 3 items secured with their value in the figure. The line now counts the backpack less the Bandages handed back and the haul less their value. Check 13.78 extracts with the issued pair and one find and requires 1 item secured, with 3 items secured when none were issued as the control; it fails on v13.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
