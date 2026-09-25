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
  // v9.07: A NOISE YOU CANNOT SEE. An expanding red ring at the place the sound
  // came from, fading as it grows. Drawn here so it is in world space: it sits
  // on the ground where the noise happened and scales with his zoom.
  if(G.noiseRings) for(i=0;i<G.noiseRings.length;i++){
'@ @'
  // v9.07: A NOISE YOU CANNOT SEE. An expanding red ring at the place the sound
  // came from, fading as it grows. Drawn here so it is in world space: it sits
  // on the ground where the noise happened and scales with his zoom.
  // v15.67, stealth audit finding: RED NOISE MARKS FOR UNSEEN SOUNDS ARE DRAWN ABOVE THE DARKNESS AND FOG OF WAR SHEETS. This
  // pass lies under both sheets, and noiseMark keeps only sounds he cannot see, which is ground the fog of war sheet covers,
  // so every mark was buried exactly where it is shown. The marks now draw after the fog, just below the v4.05 ping pass;
  // this old place runs only when ringsOnTop is dialled off, the same way back to the old order the pings have.
  if(G.noiseRings&&CFG.ringsOnTop===0) for(i=0;i<G.noiseRings.length;i++){
'@
SubRx @'
    wc.restore();
  }
  // Weather sits ON TOP of the fog, because rain falls between you and the world
'@ @'
    wc.restore();
  }
  // v15.67, stealth audit finding: RED NOISE MARKS FOR UNSEEN SOUNDS ARE DRAWN ABOVE THE DARKNESS AND FOG OF WAR SHEETS. The
  // v9.07 marks were drawn in the world pass, under the darkness sheet (litC) and the fog of war sheet (fogC), and noiseMark
  // keeps only sounds whose place canSee says he cannot see, which is always ground under the fog sheet. So both sheets were
  // laid over every mark: by night about 0.30 and then about 0.60, and a mark reached the screen at roughly 28 percent of its
  // alpha. It is the v4.05 fault the pass above fixed for the pings, repeated for these marks, and some sounds have only this
  // mark: a pillager grenade landing (v15.28), the Listener and Crier windups and the extraction sounds. By night a grenade
  // landing out of sight behind him was a faint smudge. The marks now draw here, after the pings, above the darkness and
  // below the rain, in the same world transform, colour, size and fade; ringsOnTop 0 puts them back in the world pass with
  // the pings. Draw order only: no number, dial or seeded draw moved.
  if(CFG.ringsOnTop!==0&&G.noiseRings&&G.noiseRings.length){
    wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
    for(i=0;i<G.noiseRings.length;i++){
      var nr=G.noiseRings[i], nf=clamp(nr.t/nr.life,0,1);
      wc.globalAlpha=clamp(nr.a0*(1-nf),0,1);
      wc.strokeStyle='#ff5a4a';
      wc.lineWidth=2.2;
      wc.beginPath(); wc.arc(nr.x,nr.y-10,6+nf*nr.r,0,6.2832); wc.stroke();
      if(nf>0.22){
        wc.globalAlpha=clamp(nr.a0*(1-nf)*0.55,0,1);
        wc.beginPath(); wc.arc(nr.x,nr.y-10,6+(nf-0.22)*nr.r,0,6.2832); wc.stroke();
      }
    }
    wc.globalAlpha=1; wc.restore();
  }
  // Weather sits ON TOP of the fog, because rain falls between you and the world
'@
SubRx @'
var VER='15.66';
'@ @'
var VER='15.67';
'@

$pat = "(?m)^  now:'v15\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.67: RED NOISE MARKS FOR UNSEEN SOUNDS ARE DRAWN ABOVE THE DARKNESS AND FOG OF WAR SHEETS. The red ring that marks a sound he cannot see was drawn on the ground under the darkness and the fog of war, so by night it reached the screen at about a quarter of its strength, and a grenade landing out of sight behind him was a faint smudge. The marks now draw above both sheets with the gunfire rings, in the same colour, size and fade. Check 15.67 records the draw order of one raid frame with a mark and a gunfire ring 300 units behind him; it fails on v15.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
