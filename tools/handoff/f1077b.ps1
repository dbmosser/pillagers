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

# ==== THE SAME FAULT IN A SECOND CHECK, found by running the corpus at 4K.
# ==== v10.69 requires the briefing's scrollbar to be at least 10 pixels wide so
# ==== a player can see there is more below. On a 3840x2160 screen the whole
# ==== briefing FITS: 18 cards, none under the fold, and the cue correctly stays
# ==== hidden. There is then no scrollbar at all, and the 1 pixel it measures is
# ==== the border, so the check failed a build that was behaving perfectly.
# ==== An assertion about a scrollbar only means anything when the list scrolls.
SubRx @'
       var bar=host.offsetWidth-host.clientWidth;
       if(bar<10) bad.push('the briefing scrollbar is '+bar+' pixels wide, which is not a signal');
'@ @'
       // v10.77: only when there IS one. At 4K the whole briefing fits, so there
       // is no bar and the 1 pixel measured is the border; requiring a wide bar
       // there failed a build that was doing exactly the right thing.
       if(host.scrollHeight>host.clientHeight+2){
         var bar=host.offsetWidth-host.clientWidth;
         if(bar<10) bad.push('the briefing scrolls and its scrollbar is '+bar+' pixels wide, which is not a signal');
       }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
