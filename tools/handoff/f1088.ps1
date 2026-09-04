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
function CutBetween([string]$startLit, [string]$endLit, [string]$mustHold, [int]$minLen) {
  $a = $script:s.IndexOf($startLit)
  if ($a -lt 0) { throw "cut start not found: $startLit" }
  if ($script:s.IndexOf($startLit, $a + 1) -ge 0) { throw "cut start is not unique: $startLit" }
  $b = $script:s.IndexOf($endLit, $a)
  if ($b -lt 0) { throw "cut end not found after start: $endLit" }
  $block = $script:s.Substring($a, $b - $a)
  if ($block.Length -lt $minLen) { throw "cut is only $($block.Length) chars, expected at least $minLen" }
  if ($block.IndexOf($mustHold) -lt 0) { throw "the cut does not hold $mustHold, so it is cutting the wrong thing" }
  $script:s = $script:s.Remove($a, $b - $a)
  $script:n++
}

# ==== THE CHECKS GO WITH THE FEATURE, IN THE SAME BUILD.
# ==== A check left asserting a screen nobody can open is worse than no check:
# ==== it either fails forever or, worse, passes because everything it looks for
# ==== is missing. Four checks touch the deleted card and they are NOT all the
# ==== same case, so they are not all treated the same way.
# ====
# ====   v10.69  entirely about the card's under-the-fold cue        RETIRED
# ====   v9.41   entirely about one of the card's pages, the XP one  RETIRED
# ====   v10.66  the welcome pack THEN the card. The pack half still
# ====           matters and is kept; only the handover is dropped   TRIMMED
# ====   v10.26  the hotbar word on four surfaces, one of them the
# ====           card. Three surfaces remain and still matter        TRIMMED
# ====   v10.10  a window sweep that named the card in its list      TRIMMED
# ====
# ==== And the fixture's own __primer hook goes, because it calls three functions
# ==== that no longer exist.

# ---- the hook
SubRx @'
window.__primer={open:function(){ openPrimer(); },maybe:function(){ maybePrimer(); },list:function(){ return PRIMER; }};
'@ @'
'@

# ---- v10.69, retired whole
CutBetween "  {v:'10.69',what:'the briefing says how many of its cards" "  {v:'10.68',what:'a gun found in a raid fills the empty sec" "primermore" 1200

# ---- v9.41, retired whole: its subject was one page of the card
CutBetween "  {v:'9.41',what:'the card new players read about XP matches what raids actually pay'," "// Is the page actually laid out?" "__primer" 800
# v9.41 was the LAST entry in the array, so the cut takes the closing bracket
# with it. Put it back, and keep the trailing comma the previous entry ends on,
# which ES5 array literals allow and the parse gate confirms.
SubRx @'
// Is the page actually laid out? A collapsed pane reports a 0x0 viewport and
'@ @'
];
// Is the page actually laid out? A collapsed pane reports a 0x0 viewport and
'@

# ---- v10.66, trimmed to the welcome pack. Steps 2, 4, 5 and 6 all asserted the
# ---- handover to a card that no longer exists; step 1 and step 3 are about the
# ---- pack itself and are the reason this check still earns its place.
SubRx @'
       // 2. TAKING THE PACK hands over to the primer instead of ending it there.
       var take=document.getElementById('welcometake');
       if(!take) return 'SKIP: this build has no welcome pack button';
       take.onclick();
       var second=openIds();
       if(second.indexOf('primermodal')<0) bad.push('closing the welcome pack does not bring up FIRST TIME OUT (open: '+(second.join(',')||'nothing')+')');
       if(second.length>1) bad.push('closing the welcome pack opened '+second.length+' windows: '+second.join(','));
'@ @'
       // 2. TAKING THE PACK closes it and leaves nothing else in the way.
       //    v10.88: this used to assert the handover to FIRST TIME OUT, which is
       //    deleted. What is left is the part that still matters: the pack does
       //    not linger, and it does not open something else behind itself.
       var take=document.getElementById('welcometake');
       if(!take) return 'SKIP: this build has no welcome pack button';
       take.onclick();
       var second=openIds();
       if(second.indexOf('welcomemodal')>=0) bad.push('taking the welcome pack leaves it on the screen');
       if(second.length) bad.push('taking the welcome pack opened '+second.length+' more windows: '+second.join(','));
'@
SubRx @'
       // 4. CLOSING THE PACK the other way does the same.
       fresh();
       __hubEnter();
       var no=document.getElementById('welcomeno');
       if(no){ no.onclick();
         var third=openIds();
         if(third.indexOf('primermodal')<0) bad.push('closing the pack with CLOSE does not bring up FIRST TIME OUT (open: '+(third.join(',')||'nothing')+')');
       }
       // 5. A NEW PLAYER WHO GOES STRAIGHT UP still meets the primer when he
       //    comes back down. This is the one that was silently lost.
       fresh();
       __hubEnter();          // pack up
       shut();                 // he closes it and walks to the lift
       P2.welcomed=1; P2.runs=1; try{ saveProfile(); }catch(_s2){}
       __hubEnter();          // back from his first raid
       var fourth=openIds();
       if(fourth.indexOf('primermodal')<0) bad.push('after one raid the primer is gone unread (open: '+(fourth.join(',')||'nothing')+', seen flag '+P2.primerSeen+')');
       // 6. And it does stop eventually, or it becomes a nag.
       shut();
       P2.runs=9; P2.primerSeen=0; try{ saveProfile(); }catch(_s3){}
       __hubEnter();
       if(openIds().indexOf('primermodal')>=0) bad.push('the primer still opens for a player with nine raids behind him');
'@ @'
       // 4. CLOSING THE PACK the other way does the same.
       fresh();
       __hubEnter();
       var no=document.getElementById('welcomeno');
       if(no){ no.onclick();
         var third=openIds();
         if(third.indexOf('welcomemodal')>=0) bad.push('closing the pack with CLOSE leaves it on the screen');
       }
       // 5. AND A RETURNING PLAYER IS NOT ASKED AGAIN. v10.88: steps 5 and 6
       //    used to be about the briefing card being owed and then stopping;
       //    the card is deleted, and what survives is that the pack is a
       //    one-time thing.
       fresh();
       __hubEnter();          // pack up
       shut();                 // he closes it and walks to the lift
       P2.welcomed=1; P2.runs=1; try{ saveProfile(); }catch(_s2){}
       __hubEnter();          // back from his first raid
       if(openIds().indexOf('welcomemodal')>=0) bad.push('the welcome pack comes back after a raid, so it is not a one-time thing');
'@

# ---- v10.26, one of four surfaces retired
SubRx @'
     // FOUR: the primer card.
     var pm=document.getElementById('primermodal'); if(pm&&has(pm.textContent,OLDW)) bad.push('the primer still says '+OLDW);
'@ @'
     // v10.88: the fourth surface was the FIRST TIME OUT card, which is deleted.
     // The three above it are the ones a player still reads.
'@

# ---- v10.10, the window sweep no longer names a window that is gone
SubRx @'
               ['primermodal',function(){ openModal('primermodal'); }]];
'@ @'
               ];
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + ([regex]::Matches($src, "(?m)^CutBetween ")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
