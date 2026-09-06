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

# v11.92 CHECK, inserted before the v11.91 entry. The floor HUD is drawn with
# the canvas text call recorded, twice: with no runs on the profile, where no
# card may appear and the latch must stamp itself; then with runs, where the
# heading and the dismiss line must both land inside the canvas.
SubRx @'
  {v:'11.91',what:'a belt key holding a gun from the backpack equips it into your hands, and a derived belt cell (Medical, plate, grenade) can be dragged to another key (his note of 2026-09-06)',
'@ @'
  {v:'11.92',what:'the NEW IN card greets only a player with runs behind him, and for him it fits the screen with its heading and its dismiss line both on the canvas (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__forceSize&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText;
     try{
       __topClear(); __runPrep(); __forceSize(1920,1080);
       if(!(H>400)) return 'SKIP: the canvas came back '+W+'x'+H+', too small to measure the card';
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(t,x,y){ rec.push({t:String(t),y:y}); return o.apply(this,arguments); };
       // ARM ONE: a profile with no runs never sees the card and stamps itself current.
       P2.runs=0; __wnseen(0); rec.length=0;
       __hubFrame(0.016); __hubFrame(0.016);
       if(rec.some(function(r){ return r.t.indexOf('NEW IN v')===0; })) bad.push('a profile with no runs was shown the card');
       if(__wnseen()!==1) bad.push('a profile with no runs did not stamp itself current');
       // ARM TWO: a returning player gets a card that fits.
       P2.runs=Math.max(1,keepRuns||0); __wnseen(0); rec.length=0;
       __hubFrame(0.016);
       var hd=null, dm=null, first=0;
       for(var i=0;i<rec.length;i++){
         if(!hd&&rec[i].t.indexOf('NEW IN v')===0) hd=rec[i];
         if(!dm&&/press ENTER or walk to dismiss/.test(rec[i].t)) dm=rec[i];
         if(/^2\. /.test(rec[i].t)) first++;   // the second row: the first is the pinned ALPHA notice, which the cut always keeps
       }
       if(!hd) bad.push('control: a returning player was not shown the card');
       else if(hd.y<0||hd.y>H) bad.push('the heading is drawn at y '+Math.round(hd.y)+' on a canvas '+H+' tall');
       if(!dm) bad.push('the dismiss line was not drawn');
       else if(dm.y<0||dm.y>H) bad.push('the dismiss line is drawn at y '+Math.round(dm.y)+' on a canvas '+H+' tall');
       if(!first) bad.push('the newest entry is not on the card');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.91',what:'a belt key holding a gun from the backpack equips it into your hands, and a derived belt cell (Medical, plate, grenade) can be dragged to another key (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
