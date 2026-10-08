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

if ($s.Contains("  {v:'19.01',what:")) { throw "check 19.01 is in the fixture already" }

SubRx @'
  {v:'19.00',what:
'@ @'
  {v:'19.01',what:'an empty belt key is just a key: no fallback glyph and no 0 count is drawn in it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, sl, ei=-1, C, oFT=ctx.fillText, oFR=ctx.fillRect, txt=[], rects=0, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       __frame(0.016);
       sl=hotbarSlots(); for(i=sl.length-1;i>=0;i--) if(sl[i]&&sl[i].kind==='empty'){ ei=i; break; }
       if(ei<0||!g.hotCells) return 'SKIP: no empty belt key here';
       C=null; for(i=0;i<g.hotCells.length;i++) if(g.hotCells[i].i===ei) C=g.hotCells[i];
       if(!C) return 'SKIP: the empty key has no cell';
       function inC(x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, sx=(m.a*x+m.c*y+m.e)/d, sy=(m.b*x+m.d*y+m.f)/d; return sx>C.x+2&&sx<C.x+C.w-2&&sy>C.y+2&&sy<C.y+C.h-2; }
       ctx.fillText=function(s,x,y){ if(inC(x,y)) txt.push(String(s)); return oFT.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; if(inC(x+w/2,y+h/2)&&Math.abs(w*m.a/d)<C.w*0.5) rects++; return oFR.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; delete ctx.fillRect; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
       if(txt.some(function(s){ return s==='0'; })) bad.push('an empty key shows a 0 count');
       if(rects>0) bad.push('an empty key draws a placeholder glyph ('+rects+' marks)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; delete ctx.fillRect; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
