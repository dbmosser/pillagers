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

if ($s.Contains("  {v:'21.86',what:")) { throw "check 21.86 is in the fixture already" }

SubRx @'
  {v:'21.85',what:
'@ @'
  {v:'21.86',what:'two message rows: a line said while another shows takes the top row and the other moves under it instead of being written over, and the band bottom the boss bar starts under moves only when two rows are up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof ctx.getTransform!=='function') return 'SKIP: no getTransform here';
     var bad=[], ev=[], g, realSay=say, A=['zq','row','one'].join(' '), B=['zq','row','two'].join(' '), oFT=ctx.fillText, ya=null, yb=null, j, b1, z;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function spy(){ ev=[]; ctx.fillText=function(t,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; ev.push({t:String(t),y:(m.b*x+m.d*y+m.f)/d}); return oFT.apply(this,arguments); }; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
       realSay(A); realSay(B);
       if(g.msg!==B) bad.push('G.msg is '+JSON.stringify(g.msg)+', not the newest line');
       say=function(){};   // nothing else is said mid-frame
       spy();
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++){ if(ev[j].t===A) ya=ev[j].y; if(ev[j].t===B) yb=ev[j].y; }
       if(yb===null) bad.push('the newest line was not drawn');
       if(ya===null) bad.push('the older line was not drawn: the second say wrote over it');
       if(ya!==null&&yb!==null&&!(yb<ya)) bad.push('the newest line (y '+Math.round(yb)+') is not above the older one (y '+Math.round(ya)+')');
       z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'); b1=Math.round((LH(96)+LH(17))*z);
       if(typeof HUDMSGB!=='number') bad.push('there is no HUDMSGB band bottom');
       else {
         if(ya!==null&&!(HUDMSGB>ya)) bad.push('with two rows the band bottom '+HUDMSGB+' is above the older row at y '+Math.round(ya));
         if(!(HUDMSGB>b1)) bad.push('with two rows the band bottom '+HUDMSGB+' did not move under the one row bottom '+b1);
         g.msgT=0; g.msg=''; g.feed=[]; realSay(A);
         spy();
         try{ __frame(0.016); } finally { unspy(); }
         if(Math.abs(HUDMSGB-b1)>1) bad.push('with one row the band bottom is '+HUDMSGB+', not the old '+b1+', so the boss bar moved');
         for(j=0,ya=null;j<ev.length;j++) if(ev[j].t===A) ya=ev[j].y;
         if(ya===null) bad.push('a single line was not drawn');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ unspy(); say=realSay; keys={}; try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
