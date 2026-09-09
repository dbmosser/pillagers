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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, confirmed by a skeptic and then by me
# reading the stall panel, the sale and the purchase.
#
# Selling at the stall does not pay him in Credits. It deliberately does not: the
# money rides on the run and is banked only if he walks out, and dies where he
# falls. That is a decision and it stays.
#
# What is wrong is that the panel does not know it. The balance line on the stall
# reads the BANKED Credits, and the affordability of every row on his stock reads
# the same number. So a first-time player at zero Credits sells seven things for
# four thousand, is told so by the game in the same breath, and one line below
# reads "you hold $0" with every item on the shelf greyed out. Two numbers about
# the same pocket, in the same panel, in the same frame, disagreeing.
#
# WHETHER STALL MONEY SHOULD BE SPENDABLE AT THE STALL IS HIS CALL, not mine, and
# nothing here changes it: what he can buy with is unchanged. The panel stops
# lying about it. It now names both pockets, and the refusal says which one it
# means, so the answer is "that money is not banked yet" instead of "you have
# nothing" one second after being paid.
#
# The same sale line said cash, which is not a word this game uses.
SubRx @'
  ctx.fillText('you hold '+'$'+(P.credits||0).toLocaleString()+'',x+PW-14,cy); ctx.textAlign='left';
'@ @'
  // v12.74, 2026-09-08 first-hour audit: BOTH POCKETS, because the stall pays
  // into neither the one this line used to read. A sale banks on the run and is
  // only his if he walks out, so a man who has just been paid four thousand read
  // "you hold $0" one line under the message saying so.
  ctx.fillText('banked '+'$'+(P.credits||0).toLocaleString()+((G.pedCarry||0)>0?('   +   on you '+'$'+(G.pedCarry||0).toLocaleString()+', not banked'):''),x+PW-14,cy); ctx.textAlign='left';
'@

SubRx @'
  if((P.credits||0)<st.price){ say('You cannot cover '+'$'+st.price.toLocaleString()+'.'); return; }
'@ @'
  // v12.74: the refusal says WHICH money it means, so a man carrying stall
  // money is told it is not banked yet rather than that he has nothing.
  if((P.credits||0)<st.price){ say('You cannot cover '+'$'+st.price.toLocaleString()+' from banked Credits.'+((G.pedCarry||0)>0?(' The '+'$'+(G.pedCarry||0).toLocaleString()+' on you is not banked until you walk out.'):'')); return; }
'@

SubRx @'
      ' percent. The cash rides with you now - walk it out or lose it. Carried '+
'@ @'
      ' percent. The Credits ride with you now - walk them out or lose them. Carried '+
'@

# NEW IN.
SubRx @'
  'THE GAME TELLS YOU WHEN A FOUND GUN CHANGES YOUR HANDS. A gun going into your empty second slot, or replacing the one you were holding, wrote you a line saying so and then wrote Found over the top of it in the same frame, every time. Both facts now arrive in the one line you can actually read.',
'@ @'
  'THE GAME TELLS YOU WHEN A FOUND GUN CHANGES YOUR HANDS. A gun going into your empty second slot, or replacing the one you were holding, wrote you a line saying so and then wrote Found over the top of it in the same frame, every time. Both facts now arrive in the one line you can actually read.',
  'THE PEDDLER STALL KNOWS WHAT IT JUST PAID YOU. Selling at the stall pays into money that rides with you until you extract, but the panel read your banked Credits, so it said you hold nothing one line under the message telling you it had paid you thousands, and greyed its own stock. It now names both, and says which one it cannot spend.',
'@

# STAMPS.
SubRx @'
var VER='12.73';
'@ @'
var VER='12.74';
'@
SubRx @'
var WHATSNEW_VER='12.73';
'@ @'
var WHATSNEW_VER='12.74';
'@
$cnt=([regex]::Matches($s,"now:'v12\.73:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.73 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.73:[^']*'",{ param($m) "now:'v12.74: from the 2026-09-08 first-hour audit, confirmed by a skeptic and then by me reading the stall panel, the sale and the purchase. Selling at the stall does not pay him in Credits and deliberately does not: the money rides on the run, is banked only if he walks out, and dies where he falls. That decision stays. What is wrong is that the panel does not know it. The balance line on the stall reads the BANKED Credits, and so does the affordability of every row of the stock, so a first-time player at zero sells seven things for four thousand, is told so by the game in the same breath, and one line below reads that he holds nothing with every item on the shelf greyed out: two numbers about the same pocket, in the same panel, in the same frame, disagreeing. Whether stall money should be spendable at the stall is HIS call and nothing here changes it, so what he can buy with is exactly what it was; the panel simply stops lying about it. It names both pockets now, and the refusal says which one it means, so the answer is that the money is not banked yet rather than that he has nothing one second after being paid. The same sale line said cash, which is not a word this game uses, and it now says Credits. Check 12.74 sells a bag at the stall, then requires the panel line to carry the money that is riding on him and the refusal to name it too, with a control that a man carrying nothing still reads the plain banked figure and still gets the plain refusal; fails on v12.73.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
