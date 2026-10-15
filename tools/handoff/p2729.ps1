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

# THE PROMPTS ARE 60 PERCENT SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudPrompt(s,x,y,o){
  var t=String(s), m, w, a, d, sub=(o&&o.sub)?String(o.sub):'', sw=0, h, bw, i0, i1;
'@ @'

// v27.29 (feedocc1), HIS NOTE (2026-10-14), the press E to loot text: "wayy too big". EVERY PROMPT IN THE WORLD IS 60 PERCENT OF ITS SIZE.
// hudPrompt (the keycap and its words over a crate, a door, a body, the seal, a ring) draws as it always did, in hudPromptDraw, inside a
// scale of HUDPROMPTZ (0.6) about its own anchor (x, y), so the plate, the keycap, the words and the second line shrink together and the
// prompt stays where it was. It still grows with the screen (the caller's hudAtIn, the same HUD scale), so at 4K it is 60 percent of the
// 4K size and as legible as at 1080p. The returned width and bottom are the drawn ones, for a bar under the prompt.
var HUDPROMPTZ=0.6;
function hudPrompt(s,x,y,o){
  var r;
  ctx.save(); ctx.translate(x,y); ctx.scale(HUDPROMPTZ,HUDPROMPTZ); ctx.translate(-x,-y);
  try{ r=hudPromptDraw(s,x,y,o); } finally { ctx.restore(); }
  return {w:r.w*HUDPROMPTZ,by:y+(r.by-y)*HUDPROMPTZ};
}
function hudPromptDraw(s,x,y,o){
  var t=String(s), m, w, a, d, sub=(o&&o.sub)?String(o.sub):'', sw=0, h, bw, i0, i1;
'@

SubRx @'
var VER='27.28';
'@ @'
var VER='27.29';
'@

$pat = "(?m)^  now:'v27\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.29: The press E prompts over crates, doors and bodies are now 60 percent of their old size. Check 27.29 fails on v27.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
