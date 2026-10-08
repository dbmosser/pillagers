$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'19.21',what:")) { throw "check 19.21 is in the fixture already" }

SubRx @'
  {v:'19.20',what:
'@ @'
  {v:'19.21',what:'the what is new card grows with the screen: at 4K its heading and its lines are drawn about twice their 1080p size, and the whole card still fits the screen',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__forceSize&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, s1, s4;
     function grab(){ rec.length=0; __wnseen(0); __hubFrame(0.016); var hd=null, dm=null, ln=null, i; for(i=0;i<rec.length;i++){ if(!hd&&rec[i].t.indexOf('NEW IN v')===0) hd=rec[i]; if(!dm&&/press ENTER or walk to dismiss/.test(rec[i].t)) dm=rec[i]; if(!ln&&/^1\. /.test(rec[i].t)) ln=rec[i]; } return {hd:hd,dm:dm,ln:ln}; }
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(t,x,y){ var m=this.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, fm=(/([\d.]+)px/).exec(String(this.font)); rec.push({t:String(t),px:(fm?parseFloat(fm[1]):0)*m.d/d,y:(m.d*y+m.f)/d}); return o.apply(this,arguments); };
       __forceSize(1920,1080); if(!(H>400)) return 'SKIP: the canvas came back '+W+'x'+H;
       s1=grab();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K ('+W+'x'+H+')';
       s4=grab();
       if(!s1.hd||!s4.hd) return 'SKIP: the card was not drawn';
       if(s4.hd.px<s1.hd.px*1.7) bad.push('at 4K the heading is '+s4.hd.px.toFixed(1)+' px against '+s1.hd.px.toFixed(1)+' px at 1080p, not grown with the screen');
       if(s1.ln&&s4.ln&&s4.ln.px<s1.ln.px*1.7) bad.push('at 4K the card lines are '+s4.ln.px.toFixed(1)+' px against '+s1.ln.px.toFixed(1)+' px at 1080p');
       if(s4.hd.y<0||s4.hd.y>H) bad.push('at 4K the heading is drawn at y '+Math.round(s4.hd.y)+' on a screen '+H+' tall');
       if(!s4.dm) bad.push('at 4K the dismiss line was not drawn');
       else if(s4.dm.y<0||s4.dm.y>H) bad.push('at 4K the dismiss line is at y '+Math.round(s4.dm.y)+' on a screen '+H+' tall');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} try{ __forceSize(1920,1080); }catch(_f){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
