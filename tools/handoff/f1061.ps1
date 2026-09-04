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

# v9.87 picked the tune out of the recording by its TIMBRE, so a build that
# changed the timbre would read as a build that deleted the tune. It picks it
# out by its length now, which is what a tune is: the long voice that is not the
# bass. The register tests underneath are untouched.
SubRx @'
       for(var i=0;i<rec.length;i++){
         var r=rec[i];
         if(r.type==='square') lead.push(r.midi);
         else if(r.vol>=0.2) bass.push(r.midi);
         else if(r.dur<0.5) arp.push(r.midi);
       }
'@ @'
       for(var i=0;i<rec.length;i++){
         var r=rec[i];
         // v10.61: bass by its level, tune by its length, shimmer by being short.
         // This used to name the tune by its waveform, which made a change of
         // timbre look like a missing voice.
         if(r.vol>=0.2) bass.push(r.midi);
         else if(r.dur>=1.0) lead.push(r.midi);
         else arp.push(r.midi);
       }
'@
SubRx @'
     var rec3=__musDry(all[0].bars.length*16), old=[];
     for(var k=0;k<rec3.length;k++) if(rec3[k].type==='square') old.push(rec3[k].midi);
'@ @'
     var rec3=__musDry(all[0].bars.length*16), old=[];
     for(var k=0;k<rec3.length;k++) if(rec3[k].vol<0.2&&rec3[k].dur>=1.0) old.push(rec3[k].midi);   // v10.61: by length, not timbre
'@

SubRx @'
  {v:'10.60',what:'walls are opaque by default, and over a minute of the Undercroft no body and not the operator ever stands inside the rectangle a wall paints',
'@ @'
  {v:'10.61',what:'the Undercroft plays slower, darker and softer: no bright square leading the tune, seventy-six a minute, a closed filter, half the shimmer and a held bass',
   run:function(){
     var bad=[];
     if(!(window.__musTheme&&window.__musDry&&window.__musUse&&window.__musDarkInfo))
       return 'SKIP: this fixture cannot read what the music schedules';
     var MT=__musTheme(), all=MT.themes;
     var hub=null; for(var i=0;i<all.length;i++) if(/UNDERCROFT/.test(all[i].name)) hub=all[i];
     if(!hub) return 'SKIP: the Undercroft theme is not among the themes';
     __resetCfg(); __pinDefaults(0);
     try{
       __musUse(hub);
       var rec=__musDry(hub.bars.length*16);
       var lead=[],arp=[],bass=[],sq=[],tri=[];
       for(i=0;i<rec.length;i++){
         var r=rec[i];
         if(r.vol>=0.2) bass.push(r);
         else if(r.dur>=1.0){ lead.push(r); if(r.type==='square') sq.push(r); else tri.push(r); }
         else arp.push(r);
       }
       if(!lead.length||!arp.length||!bass.length)
         return 'the Undercroft schedules '+lead.length+' tune notes, '+arp.length+' shimmer notes and '+bass.length+' bass notes, so a voice has gone missing';
       // 1. Nothing bright leads. The square may still be there, under the tune.
       var loudSq=0, loudTri=0;
       for(i=0;i<sq.length;i++) loudSq=Math.max(loudSq,sq[i].vol);
       for(i=0;i<tri.length;i++) loudTri=Math.max(loudTri,tri[i].vol);
       if(!tri.length) bad.push('the tune has no soft voice at all');
       else if(loudSq>=loudTri) bad.push('the square is still the loudest thing in the tune ('+loudSq.toFixed(3)+' against '+loudTri.toFixed(3)+'), which is the toy sound he heard');
       // 2. Slower than eighty a minute: a sixteenth no faster than 0.1875 s.
       var info=__musDarkInfo(hub);
       if(!(info.stepSec>=0.1875)) bad.push('the room plays a sixteenth every '+info.stepSec+' s, which is faster than eighty a minute');
       // 3. Darker than the old corner.
       if(!(info.lpHz<=1000)) bad.push('the lowpass corner is '+info.lpHz+' Hz, which is not closed further than v9.87 left it');
       // 4. The shimmer is halved and quieter.
       var perBar=arp.length/hub.bars.length;
       if(perBar>4.5) bad.push('the shimmer plays '+perBar.toFixed(1)+' notes a bar, which is still one an eighth');
       var loudArp=0; for(i=0;i<arp.length;i++) loudArp=Math.max(loudArp,arp[i].vol);
       if(loudArp>0.05) bad.push('the shimmer is still at '+loudArp.toFixed(3)+', which is where he heard it');
       // 5. The bass is held long enough to run under the next chord.
       var longest=0; for(i=0;i<bass.length;i++) longest=Math.max(longest,bass[i].dur);
       if(longest<2.5) bad.push('the longest bass note is '+longest.toFixed(2)+' s, too short to hum under the room');
       // CONTROL: the dial still puts the bright room back.
       __cfg({musDark:0});
       __musUse(hub);
       var rec2=__musDry(hub.bars.length*16), backSq=0;
       for(i=0;i<rec2.length;i++) if(rec2[i].type==='square'&&rec2[i].dur>=1.0) backSq=Math.max(backSq,rec2[i].vol);
       var info2=__musDarkInfo(hub);
       if(backSq<0.1) bad.push('control: with musDark off the square does not come back (loudest '+backSq.toFixed(3)+'), so this may be reading a rewritten table rather than the dial');
       if(info2.lpHz<2000) bad.push('control: with musDark off the filter stays closed at '+info2.lpHz);
     } finally { __cfg({musDark:1}); MT.pick(); }
     return bad.length?bad.join('; '):null; }},
  {v:'10.60',what:'walls are opaque by default, and over a minute of the Undercroft no body and not the operator ever stands inside the rectangle a wall paints',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
