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

# THE AIR STRIKE ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_rbN&&!PAD.prev[5]){ PAD.rbAt=_bnow; PAD.rbHeld=0; }
'@ @'
    if(_rbN&&!PAD.prev[5]){ PAD.rbAt=_bnow; PAD.rbHeld=0; }
    // v27.25 (coop7): BOTH BUMPERS TOGETHER ARM THE AIR STRIKE. It was a keyboard key (G) and the keyboard is player 1's, so a player on a controller (player 2) could fill the
    // meter and never spend it. The two bumpers pressed within 0.3 s of each other are a chord: they arm it (or cancel the aim), and neither walks the belt or zooms.
    if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&!PAD.airChord&&PAD.lbAt!=null&&PAD.rbAt!=null&&Math.abs(PAD.lbAt-PAD.rbAt)<0.3&&typeof flowOn==='function'&&flowOn()){
      PAD.airChord=1; PAD.lbHeld=1; PAD.rbHeld=1; PAD.lbAt=null; PAD.rbAt=null;
      try{ airKey(); }catch(_pak){}
    }
    if(!_lbN&&!_rbN) PAD.airChord=0;
'@

SubRx @'
      if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+drop); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:'PRESS G'}); } }
'@ @'
      if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+drop); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:airHint()}); } }
'@

SubRx @'
  if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+add); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:'PRESS G'}); } }
'@ @'
  if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+add); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:airHint()}); } }
'@

SubRx @'
    c.font=hudFS(TYPE.micro); c.fillStyle=UIC.tx_2; hudText((padOn()?pbn(7):'LMB')+' CALL     G CANCEL',s.x,s.y-ar-U(8));
'@ @'
    c.font=hudFS(TYPE.micro); c.fillStyle=UIC.tx_2; hudText((padOn()?pbn(7):'LMB')+' CALL     '+(padOn()?padB('LB + RB'):'G')+' CANCEL',s.x,s.y-ar-U(8));
'@

SubRx @'
    bx=x+U(96); bwid=bw-U(96)-U(48); by=Math.round(y+bh*0.5-U(3));
'@ @'
    bx=x+U(96); bwid=bw-U(96)-U(padOn()?76:48); by=Math.round(y+bh*0.5-U(3));
'@

SubRx @'
    if(rdy) hudKey('G',x+bw-U(46),y+Math.round(bh*0.7),U(8),U(32));
'@ @'
    if(rdy) hudKey(padOn()?padB('LB+RB'):'G',x+bw-U(padOn()?74:46),y+Math.round(bh*0.7),U(8),U(padOn()?62:32));   // v27.25 (coop7): the chord on a controller
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
function airHint(){ return (typeof padOn==='function'&&padOn())?padB('LB + RB'):'PRESS G'; }
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.24';
'@ @'
var VER='27.25';
'@

$pat = "(?m)^  now:'v27\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.25: A player on a controller can now arm the air strike with both bumpers together. Check 27.25 fails on v27.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
