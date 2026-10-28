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

# FEED KEEPS THE NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(w>maxW&&P.length){   // too long for the zone: the first piece gives way, with a mark at its end
    t=P[0].t; tw=w-P[0].w;
    while(t.length>3&&tw+ctx.measureText(t+'...').width>maxW) t=t.slice(0,-1);
    P[0].t=t+'...'; P[0].w=ctx.measureText(P[0].t).width; w=tw+P[0].w;
  }
'@ @'
  // v28.xx (cw-cx-feedname): the audit (10-28) saw "select a ..." while its detail stayed whole. Keep the name; shorten trailing detail first.
  for(i=P.length-1;i>=0&&w>maxW;i--){
    if(i===0&&P[0].w<=maxW){ w=P[0].w; break; }
    t=P[i].t; tw=w-P[i].w;
    while(t.length&&tw+ctx.measureText(t+'...').width>maxW) t=t.slice(0,-1);
    c0=ctx.measureText(t+'...').width;
    if(tw+c0<=maxW){ P[i].t=t+'...'; P[i].w=c0; w=tw+c0; }
    else { P.pop(); w=tw; }
  }
'@

SubRx @'
var VER='36.08';
'@ @'
var VER='36.09';
'@

$pat = "(?m)^  now:'v36\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.09: Long feed rows keep the name and shorten the detail first. Check 36.09 fails on v36.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
