$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.74 CHECK, inserted before the v11.73 entry. The stale phrase is assembled
# from pieces so this check never matches its own text, and the draw sites are
# read off drawHUD, whose SOURCE includes its comments, so the comment that
# recorded the old wording is checked for too.
SubRx @'
  {v:'11.73',what:'a character who has never saved still has a name, and the character screen does not read undefined beside their first raid',
'@ @'
  {v:'11.74',what:'the boarding window tells him to act: EXTRACT NOW with the ring letter and the seconds left, in both the banner above the belt and the label on an off-screen ring, and nowhere does it say the old in-progress wording',
   run:function(){
     if(typeof extractNowLine!=='function') return 'the boarding window has no line of its own to read; it is still written inline';
     if(typeof drawHUD!=='function') return 'SKIP: no HUD draw in this build';
     var bad=[], stale=['IN ','PROGRESS'].join('');
     var line=String(extractNowLine('B',11.4));
     // HIS WORDS, and the two things he needs from the line.
     if(line.indexOf('EXTRACT NOW')<0) bad.push('the boarding window reads "'+line+'" instead of telling him to extract now');
     if(line.indexOf('B')<0) bad.push('the line does not name which ring: "'+line+'"');
     if(line.indexOf('12')<0) bad.push('the line does not round the seconds left up to 12: "'+line+'"');
     if(line.indexOf(stale)>=0) bad.push('the line still carries the old wording: "'+line+'"');
     // AND ZERO SECONDS DOES NOT GO NEGATIVE.
     var z=String(extractNowLine('A',-3));
     if(z.indexOf('-')>=0) bad.push('with the window already gone the line reads "'+z+'"');
     // CONTROLS: both draw sites read the helper, and neither still carries the
     // old phrase, its comment included.
     var src=''; try{ src=drawHUD.toString(); }catch(_s){}
     var uses=src.split('extractNowLine(').length-1;
     if(uses<2) bad.push('control: the HUD draw reads the line in '+uses+' place(s), so the banner and the ring label can still disagree');
     if(src.indexOf(stale)>=0) bad.push('control: the HUD draw still carries the old wording somewhere');
     return bad.length?bad.join('; '):null; }},
  {v:'11.73',what:'a character who has never saved still has a name, and the character screen does not read undefined beside their first raid',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
