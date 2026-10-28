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

# MAINFRAME MONEY IN DOLLARS AND A LOCK ICON ON LOCKED ACHIEVEMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  money.innerHTML=(c.reward||0).toLocaleString()+'<em>c</em>';   // v8.42: see the note on the contract row
'@ @'
  money.innerHTML='$'+(c.reward||0).toLocaleString();   // v8.42: see the note on the contract row. v35.88 (cw-menupolish1): money reads $N (his rule: $ for money), never N c
'@

SubRx @'
    h+='<div style="display:flex;gap:14px;font-size:14px;padding:3px 0;color:'+(P.ach[a.id]?'var(--amber)':'var(--ash)')+'">'+
       '<span style="width:230px;flex:0 0 230px">'+(P.ach[a.id]?'':'LOCKED ')+a.n+'</span><span style="flex:1">'+a.d+'</span></div>';
'@ @'
    // v35.88 (cw-menupolish1): a locked achievement shows a lock icon before its name, not the word LOCKED glued to it (it read "locked first out"), and an
    // earned one carries class achon so it stands out in the gold its emblem has on the extracted card.
    h+='<div class="achrow'+(P.ach[a.id]?' achon':'')+'" style="display:flex;gap:14px;font-size:14px;padding:3px 0;color:'+(P.ach[a.id]?'var(--amber)':'var(--ash)')+'">'+
       '<span style="width:230px;flex:0 0 230px">'+(P.ach[a.id]?'':uiIcon('lock',16,'achlk'))+a.n+'</span><span style="flex:1">'+a.d+'</span></div>';
'@

SubRx @'
#root #opane_rec #achlist > div > span{width:auto !important;min-width:0;}
'@ @'
#root #opane_rec #achlist > div > span{width:auto !important;min-width:0;}
/* v35.88 (cw-menupolish1): the lock icon sits before a locked name in the muted colour; an earned achievement reads in the emblem gold, its line in tx-1 */
#root #opane_rec #achlist .achlk{display:inline-block;vertical-align:-2px;margin-right:8px;color:var(--tx-2);}
#root #opane_rec #achlist > div.achrow.achon{color:var(--tx-1) !important;}
#root #opane_rec #achlist > div.achrow.achon > span:first-child{color:#ffe69a;}
#root #opane_rec #achlist > div.achrow:not(.achon) > span:first-child{color:var(--tx-2);}
'@

SubRx @'
var VER='35.87';
'@ @'
var VER='35.88';
'@

$pat = "(?m)^  now:'v35\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.88: contract rewards read in dollars and locked achievements show a lock Check 35.88 fails on v35.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
