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

# the snip panel reads at a glance: bigger copy and save buttons, a larger size tag, a darker dim (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
box-shadow:0 0 0 100vmax rgba(0,0,0,.5)
'@ @'
box-shadow:0 0 0 100vmax rgba(0,0,0,.6)
'@

SubRx @'
'display:none;padding:2px 8px 1px;color:var(--tx-1);font-size:13px'
'@ @'
'display:none;padding:3px 10px 2px;color:var(--tx-1);font-size:16px'
'@

SubRx @'
  x=Math.max(4,Math.min(window.innerWidth-160,b.x)); y=b.y-26;
  if(y<4){ y=b.y+4; x=Math.max(4,Math.min(window.innerWidth-160,b.x+4)); }
'@ @'
  // v30.xx (cw-snip2): the size tag is 16px and sits clear above the frame (its own height and width measured, so it never runs off the right edge or the top)
  var cw=sz.offsetWidth||200, ch=sz.offsetHeight||26;
  x=Math.max(4,Math.min(window.innerWidth-cw-4,b.x)); y=b.y-ch-8;
  if(y<4){ y=b.y+8; x=Math.max(4,Math.min(window.innerWidth-cw-4,b.x+8)); }
'@

SubRx @'
display:flex;gap:8px;padding:8px;background:rgba(11,12,13,.94);border:1px solid var(--ui-line-hi);cursor:default
'@ @'
display:flex;gap:16px;padding:12px;background:rgba(11,12,13,.94);border:1px solid var(--ui-line-hi);cursor:default
'@

SubRx @'
pn.innerHTML='<button type="button" data-snip="copy" style="min-width:104px">copy</button><button type="button" data-snip="save" style="min-width:104px">save</button>';
'@ @'
// v30.xx (cw-snip2): the shared buttons - copy is the primary (the lime fill), save the secondary beside it, 48px high and 128px wide, so they read at a glance
  pn.innerHTML='<button type="button" class="ui-btn pri" data-snip="copy" style="min-width:128px;min-height:48px">copy</button><button type="button" class="ui-btn" data-snip="save" style="min-width:128px;min-height:48px">save</button>';
'@

SubRx @'
var VER='31.17';
'@ @'
var VER='31.18';
'@

$pat = "(?m)^  now:'v31\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.18: The snip buttons are bigger: copy is the main one in lime and save sits beside it. The size tag is easier to read and the screen around your box is darker. Check 31.18 fails on v31.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
