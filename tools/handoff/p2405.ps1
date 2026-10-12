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

# THE HIT MARKER IS THE INSIDE OF THE CROSSHAIR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
                  G.hitMark={t:0,life:.5,kill:false,weak:true};
'@ @'
                  G.hitMark={t:0,life:.15,kill:false,weak:true};   // v23.9x (hitmark): the marker line below keeps this weak mark now
'@

SubRx @'
G.hitMark={t:0,life:en.hp<=0?.44:.26,kill:en.hp<=0};
'@ @'
              // v23.9x (hitmark), HIS ORDER (2026-10-12): the hit marker is the inside of the crosshair (drawHUD). This line wrote a plain mark
              // over the weak spot mark set above, so a weak spot never showed or sounded as one; it keeps it now. On a linked window the host
              // takes the health off later, so en.hp<=0 never held there and player 2 never saw his kill mark: hitKills works it out from the
              // damage sent, as his kill number does (v23.18). A hit lasts 0.15 s, a kill 0.2 s.
              G.hitMark={t:0,life:hitKills(en,edmg)?.2:.15,kill:hitKills(en,edmg),weak:!!WK};
'@

SubRx @'
              CW.hitT=.16;
'@ @'
              CW.hitT=.16;
              if(!G.sim&&CW.hp>0) G.hitMark={t:0,life:.15,kill:false};   // v23.9x (hitmark): a round that lands on an animal marks a hit too
'@

SubRx @'
                  G.hitMark={t:0,life:.44,kill:true};
'@ @'
                  G.hitMark={t:0,life:.2,kill:true};   // v23.9x (hitmark): a kill marker lasts 0.2 s
'@

SubRx @'
    // hitmarker: four diagonal ticks, wider and amber when the target dropped
    if(G.hitMark){
      var hm=G.hitMark,hk=clamp(1-hm.t/hm.life,0,1);
      // v20.75, from the whole-game bug hunt of 2026-10-08 (H42): the hit ticks grow with the screen, as the reticle has since v9.53.
      // Its gap is 8 times the screen factor, so at 4K the 1080p ticks sat inside the hole of the cross.
      var _hmz=hudRes();   // v21.25, from the review of 2026-10-09 (R7): its own screen factor; _rz is set only when the cross is drawn, so over a HUD panel the ticks were NaN and never drew
      var hIn=((hm.kill?7:5)+(1-hk)*(hm.kill?7:4))*_hmz,hOut=hIn+(hm.kill?7:5)*_hmz;
      ctx.strokeStyle=hm.kill?'rgba(255,192,74,'+(hk*.95)+')':'rgba(240,248,252,'+(hk*.9)+')';
      ctx.lineWidth=(hm.kill?2.4:1.8)*_hmz;
      ctx.beginPath();
      ctx.moveTo(rx0-hOut,ry0-hOut); ctx.lineTo(rx0-hIn,ry0-hIn);
      ctx.moveTo(rx0+hIn,ry0-hIn);   ctx.lineTo(rx0+hOut,ry0-hOut);
      ctx.moveTo(rx0-hOut,ry0+hOut); ctx.lineTo(rx0-hIn,ry0+hIn);
      ctx.moveTo(rx0+hIn,ry0+hIn);   ctx.lineTo(rx0+hOut,ry0+hOut);
      ctx.stroke();
    }
'@ @'
    // v23.9x (hitmark), HIS ORDER (2026-10-12), his words on the hit marker: "i don't really understand how a hit marker is going to
    // work in 2.5 d -- just take your best shot i suppose", and then "maybe just on the inside reticule of the crosshair or something?
    // (Realize that many mechanics of first or third person shooters will not 1:1 translate to 2.5d)". THE HIT MARKER IS THE INSIDE OF
    // THE CROSSHAIR. A landed round drew four faint diagonal ticks out in the gap of the cross, a first person X that read as nothing
    // from above. Now the centre dot itself answers: it swells into a diamond in the hit colour while a thin ring pulses out from it to
    // the inner ends of the arms. White is a hit, orange (the gold tone of the design system) a weak spot, red (its danger tone) a kill,
    // which is bigger and pulses out past the arms. It lasts 0.15 s, 0.2 s for a kill, sharp edged with an ink rim so it reads on snow,
    // no glow. The arms, the magazine ring and the reload ring draw as before, and the tick and the kill confirm sound as since v23.91.
    // Player 2 sees the markers of his own rounds in his own window, his kills included (the round marks them with hitKills).
    if(G.hitMark){
      var hm=G.hitMark,hk=clamp(1-hm.t/hm.life,0,1);
      var _hmz=hudRes();   // v21.25, from the review of 2026-10-09 (R7): its own screen factor; _rz is set only when the cross is drawn, so over a HUD panel the marker was NaN and never drew
      var _hme=1-hk*hk*hk, _hma=Math.min(1,hk*2.5);   // the pulse runs out fast, then settles; full strength, then a fade over the last 40 percent
      var hIn=(hm.kill?4.4:3)*(1.3-0.45*_hme)*_hmz;   // half the width of the diamond
      var _hmr=(3+(hm.kill?12:5)*_hme)*_hmz;   // the ring: out to the inner ends of the arms, past them for a kill
      var _hmc=hm.kill?'229,72,47':(hm.weak?'240,143,46':'246,248,250');
      ctx.beginPath();
      ctx.moveTo(rx0,ry0-hIn); ctx.lineTo(rx0+hIn,ry0); ctx.lineTo(rx0,ry0+hIn); ctx.lineTo(rx0-hIn,ry0); ctx.closePath();
      ctx.fillStyle='rgba('+_hmc+','+_hma.toFixed(3)+')'; ctx.fill();
      ctx.strokeStyle='rgba(11,12,13,'+(0.6*_hma).toFixed(3)+')'; ctx.lineWidth=_hmz; ctx.stroke();
      ctx.strokeStyle='rgba('+_hmc+','+(0.9*hk).toFixed(3)+')'; ctx.lineWidth=(hm.kill?2.2:1.5)*_hmz;
      ctx.beginPath(); ctx.arc(rx0,ry0,_hmr,0,6.2832); ctx.stroke();
    }
'@

SubRx @'
var VER='24.04';
'@ @'
var VER='24.05';
'@

$pat = "(?m)^  now:'v24\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.05: A landed round flashes the centre of your crosshair: white for a hit, orange for a weak spot, bigger and red for a kill. Check 24.05 fails on v24.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
