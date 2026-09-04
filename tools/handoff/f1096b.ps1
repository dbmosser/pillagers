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

# ---- THE ROUND TRIP, not just the arrival. A door he cannot come back through
# ---- is worse than no door, and the screen he lands on has to be drawn, not
# ---- merely marked as shown.
SubRx @'
         var pr2=__P();
         if(pr2.credits!==credits0||pr2.runs!==runs0||pr2.pname!==name0)
           bad.push('going back to the character screen changed the save: credits '+credits0+' to '+pr2.credits+', runs '+runs0+' to '+pr2.runs);
'@ @'
         var pr2=__P();
         if(pr2.credits!==credits0||pr2.runs!==runs0||pr2.pname!==name0)
           bad.push('going back to the character screen changed the save: credits '+credits0+' to '+pr2.credits+', runs '+runs0+' to '+pr2.runs);
         // IT HAS TO BE DRAWN. A screen marked as shown that paints nothing is
         // the same dead end with the class attribute changed.
         var col=ti.querySelector('.titlecol');
         if(col&&col.getBoundingClientRect().height<200)
           bad.push('the character screen came up but is only '+Math.round(col.getBoundingClientRect().height)+' pixels tall, so it is not drawn');
         // AND HE HAS TO BE ABLE TO COME BACK. A one-way door is worse than none.
         var st=document.getElementById('titlestart');
         if(!st) bad.push('control: there is no way in from the character screen, so the round trip cannot be tested');
         else {
           st.click();
           if(ti.classList.contains('on')) bad.push('pressing the start button on the character screen does not put you back in the game');
         }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
