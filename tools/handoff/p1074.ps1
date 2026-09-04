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

# ============ THE WAY OUT OF THE RUN REPORT WAS BELOW THE FOLD.
# ============
# ============ REPRODUCED on v10.73 at 1920x1080 with a realistic full bag, ten
# ============ items packed and eight more picked up, dying with two guns: the
# ============ card is 890 pixels wide, 46 percent of the screen, and 1,078 tall,
# ============ which is the whole of it. Its content is 945 pixels in an 826
# ============ pixel box, so 119 pixels sit below the fold, and what is down
# ============ there is the button row: LOG RUN AND RETURN at y 1100 in a card
# ============ that ends at 1079, and COPY REPORT beside it.
# ============
# ============ So a friend who dies with a full bag cannot see the button that
# ============ leaves the card, or the one that sends me the report, without
# ============ scrolling a panel he has no reason to believe scrolls. On the
# ============ alpha that is the feedback path hidden behind a gesture nobody
# ============ will make.
# ============
# ============ Widening the card does not fix it, and I measured that before
# ============ reaching for it: at 1,430 or 1,625 pixels wide the content is
# ============ still 945 tall, because the ledger is one line per item however
# ============ wide the box gets. The card is capped at 86vh on purpose and it is
# ============ right to scroll. What is wrong is WHICH PART scrolls away.
# ============
# ============ The action row is pinned to the bottom of the card now. Measured
# ============ with it pinned and the card scrolled to the top, the buttons sit
# ============ at 993 to 1038 inside a card ending at 1079, where before they
# ============ were at 1100 to 1144 and off the end.
SubRx @'
  .outcome.on{ display:flex; }
'@ @'
  /* v10.74: the two buttons are how you leave this card and how you send him
     the report, so they are the one thing on it that must never scroll away.
     The card is capped at 86vh and a full bag runs past that, which put both
     of them off the bottom. Pinned to the foot of the card, with a fade so the
     ledger passing under them stays readable. On a card short enough not to
     scroll this changes nothing: the row sits where it always did and the fade
     ends in the card's own colour. */
  .ocacts{ position:sticky; bottom:0; z-index:2; width:100%;
    display:flex; gap:8px; margin-top:14px; flex-wrap:wrap; justify-content:center;
    padding:10px 0 4px;
    background:linear-gradient(180deg,rgba(0,0,0,0),var(--win-bot) 38%); }
  .outcome.on{ display:flex; }
'@

SubRx @'
  <div style="display:flex;gap:8px;margin-top:14px;flex-wrap:wrap;justify-content:center">
    <button style="padding:8px 22px" id="oc_btn">Log run and return</button>
    <button style="padding:8px 22px" id="oc_copy">Copy report</button>
  </div>
'@ @'
  <div class="ocacts">
    <button style="padding:8px 22px" id="oc_btn">Log run and return</button>
    <button style="padding:8px 22px" id="oc_copy">Copy report</button>
  </div>
'@

SubRx @'
var VER='10.73';
'@ @'
var VER='10.74';
'@
SubRx @'
  now:'v10.73: the title screen uses the monitor. It was painting a narrow column across the middle of a 1920 screen with 427 pixels of nothing down each side, because the only rule that widened it was written for ultrawides and 16 by 9 missed it.',
'@ @'
  now:'v10.74: the buttons at the end of a raid stay on screen. Die with a full bag and Log run and return, along with Copy report next to it, were below the bottom of the card, so the way out and the way to send the report were both behind a scroll.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
