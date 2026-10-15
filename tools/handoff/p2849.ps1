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

# PLAYER 2 SEES THE VOLATILE BLAST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(G.puffs) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
'@ @'
    if(G.puffs) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
    if(e.affix==='boom'){ spark(e.x,e.y,AFFIX.boom.c,28,320); if(G.puffs) G.puffs.push({x:e.x,y:e.y,t:0,life:.6,c:AFFIX.boom.c,r:44}); G.shake=Math.max(G.shake||0,6); flash(e.x,e.y,260,AFFIX.boom.c,.4); try{ boomFx(e.x,e.y,1,'frag'); }catch(_ab){} }   // v28.49 (cloud-coop-volatile-boom-seen), CLOUD HUNT 2026-10-15: the VOLATILE blast the host sees and feels (affixBoom), now in player 2 window; its sound already comes by the fx word
'@

SubRx @'
var VER='28.48';
'@ @'
var VER='28.49';
'@

$pat = "(?m)^  now:'v28\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.49: Player 2 now sees and feels a VOLATILE elite blow up, the same blast and shake player 1 gets. Check 28.49 fails on v28.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
