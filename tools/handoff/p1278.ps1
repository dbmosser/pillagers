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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT. The reader's version of this was mostly
# wrong and the skeptic threw it out; what is left, and what I confirmed by
# reading, is small and true.
#
# The fine for walking out is at least a hundred XP. It is taken with a floor at
# zero, so it can never push him negative, which is right. But the button quotes
# the fine before that floor is applied, and the message afterwards announces the
# same unfloored number.
#
# So a first-time player, who has almost no XP, opens the pause box on his second
# run and reads YES, ABANDON THIS RUN (costs 106 XP) with nothing like 106 XP to
# his name. He presses it, is told XP -106, and loses nothing at all, because
# there was nothing there to take. The one number the game shows him about the
# consequences of quitting is fiction in both places it appears.
#
# What the audit ALSO claimed, and I am not building, because the skeptic showed
# it is not true: that the fine is invisible to the outcome card's accounting. It
# is not. The fine lands before the raid ends, and the card's total is built from
# the profile afterwards, so the card and the corner readout agree.
SubRx @'
    cb.textContent=(_el>60)?('YES, ABANDON THIS RUN (costs '+abandonRepCost(_el)+' XP)')
                           :'YES, ABANDON THIS RUN (free this early)';
'@ @'
    // v12.78, 2026-09-08 first-hour audit: THE PRICE ON THE BUTTON IS THE PRICE
    // HE WILL PAY. The fine is taken with a floor at zero so it can never push
    // him negative, which is right, but this quoted the figure from before that
    // floor: a first-time player with almost no XP read a hundred-odd XP on a
    // button that was about to take nothing from him.
    var _ac=Math.min(abandonRepCost(_el),(P.xp||0));
    cb.textContent=(_el>60)?('YES, ABANDON THIS RUN ('+(_ac>0?('costs '+_ac+' XP'):'no XP to lose')+')')
                           :'YES, ABANDON THIS RUN (free this early)';
'@

SubRx @'
    var _rc=abandonRepCost(elapsed());
    P.xp=Math.max(0,(P.xp||0)-_rc);
    say('Walked out on the job. XP -'+_rc+'.');
'@ @'
    // v12.78: and the line afterwards reports what was actually taken, not the
    // figure before the floor. It used to say XP -106 to a man who had lost
    // nothing, because he had nothing to lose.
    var _rc=Math.min(abandonRepCost(elapsed()),(P.xp||0));
    P.xp=Math.max(0,(P.xp||0)-_rc);
    say(_rc>0?('Walked out on the job. XP -'+_rc+'.'):'Walked out on the job. No XP to lose.');
'@

# NEW IN.
SubRx @'
  'DYING WITH THE FREEBIE KIT GIVES YOUR TACTICAL BELT BACK TOO. It restored the items you had packed and quietly kept the belt keys you had bound, and the gun slot, which were thrown away the moment you took the kit. Keys pointing at something you no longer own are still dropped.',
'@ @'
  'DYING WITH THE FREEBIE KIT GIVES YOUR TACTICAL BELT BACK TOO. It restored the items you had packed and quietly kept the belt keys you had bound, and the gun slot, which were thrown away the moment you took the kit. Keys pointing at something you no longer own are still dropped.',
  'THE PRICE OF WALKING OUT IS THE PRICE YOU ACTUALLY PAY. The confirm button quoted a fine of a hundred or more XP to players who did not have it, and the line afterwards announced taking it, when the fine has always stopped at zero and took nothing.',
'@

# STAMPS.
SubRx @'
var VER='12.77';
'@ @'
var VER='12.78';
'@
SubRx @'
var WHATSNEW_VER='12.77';
'@ @'
var WHATSNEW_VER='12.78';
'@
$cnt=([regex]::Matches($s,"now:'v12\.77:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.77 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.77:[^']*'",{ param($m) "now:'v12.78: from the 2026-09-08 first-hour audit, and most of what that finding claimed was wrong. The skeptic threw out the part that said the fine is invisible to the outcome card, and it was right to: the fine lands before the raid ends and the card total is built from the profile afterwards, so the card and the corner readout agree. What survives is small and true. The fine for walking out is at least a hundred XP, and it is taken with a floor at zero so it can never push him negative, which is right. But the button quoted the fine from BEFORE that floor, and the line afterwards announced the same unfloored number. So a first-time player, who has almost no XP, opens the pause box on his second run and reads that abandoning costs a hundred and six XP when he has nothing like that to his name, presses it, is told XP minus a hundred and six, and loses nothing at all because there was nothing to take. The one number the game shows him about the consequences of quitting was fiction in both places it appeared, and it is the kind of fiction that makes a new player keep playing a run he wanted to leave. Both places now use the figure that will actually be charged, and at zero the button says there is no XP to lose and the line afterwards says the same. Nothing about the fine itself moves: the amount, the sixty second grace and the floor are all exactly as they were. Check 12.78 arms the confirm on a character with nothing banked and requires the button not to quote a fine, presses it and requires the line afterwards not to announce one, and controls that a character who HAS the XP still reads the full price and still pays it; fails on v12.77.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
