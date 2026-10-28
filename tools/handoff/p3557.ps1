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

# PAD BOX PROMPTS CLEAR THE HEAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudPrompt(s,x,y,o){
  var r;
  ctx.save(); ctx.translate(x,y); ctx.scale(HUDPROMPTZ,HUDPROMPTZ); ctx.translate(-x,-y);
  try{ r=hudPromptDraw(s,x,y,o); } finally { ctx.restore(); }
  return {w:r.w*HUDPROMPTZ,by:y+(r.by-y)*HUDPROMPTZ};
}
'@ @'
function hudPrompt(s,x,y,o){
  // v28.xx (cw-cx-xpromptread): Q7 lets the style guide override older sizes; only pad container prompts opt into its readable label floor.
  var r,z=(o&&o.scale>0)?o.scale:HUDPROMPTZ;
  ctx.save(); ctx.translate(x,y); ctx.scale(z,z); ctx.translate(-x,-y);
  try{ r=hudPromptDraw(s,x,y,o); } finally { ctx.restore(); }
  return {w:r.w*z,by:y+(r.by-y)*z};
}
'@

SubRx @'
    var s=w2s(nc2.x,26,nc2.y);
'@ @'
    var s=w2s(nc2.x,26,nc2.y);
    if(s&&padOn()) s.y-=LH(24)*hudRes(); // v28.xx (cw-cx-xpromptread): clear the pillager head and reticle, at the same offset at 1080p and 4k.
'@

SubRx @'
      hudPrompt(_ft,s.x,s.y,{accent:_fcr,sub:_fsub,subCol:_fsc});
'@ @'
      hudPrompt(_ft,s.x,s.y,{accent:_fcr,sub:_fsub,subCol:_fsc,scale:padOn()?0.85:HUDPROMPTZ}); // v28.xx (cw-cx-xpromptread): the pad box action grows from about 12px to at least 16px; keyboard keeps its scale.
'@

SubRx @'
var VER='35.56';
'@ @'
var VER='35.57';
'@

$pat = "(?m)^  now:'v35\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.57: Pad box prompts are readable above the pillager head; reload and search use the same size. Check 35.57 fails on v35.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
