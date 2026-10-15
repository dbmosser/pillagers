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

# PARTY RUN GOALS KEEP THEIR PROGRESS WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.netLeft='';
'@ @'
  if(G.flow&&G.flow.goals) for(_i=0;_i<G.flow.goals.length;_i++){ _e=G.flow.goals[_i]; if(_e&&!_e.done) _e.off=Math.max(0,(_e.v|0)-goalProg(_e.id,G.flow)); }   // v28.43 (cloud-coop-takeover-goals-kept), CLOUD HUNT 2026-10-15: the party goal progress the host sent is kept as an offset over this window's own count
  G.netLeft='';
'@

SubRx @'
    v=goalProg(gl.id,S); gl.v=Math.min(gl.n,v);
'@ @'
    v=goalProg(gl.id,S)+(gl.off|0); gl.v=Math.min(gl.n,v);   // v28.43 (cloud-coop-takeover-goals-kept), CLOUD HUNT 2026-10-15: plus the party progress kept at a host takeover
'@

SubRx @'
var VER='28.42';
'@ @'
var VER='28.43';
'@

$pat = "(?m)^  now:'v28\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.43: If your host leaves mid raid, the run goals keep the progress you made together instead of dropping back to only your own kills. Check 28.43 fails on v28.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
