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

if ($s.Contains("  {v:'21.20',what:")) { throw "check 21.20 is in the fixture already" }

SubRx @'
  {v:'21.19',what:
'@ @'
  {v:'21.20',what:'the gun card in the corner is not drawn while the backpack is open, and is drawn with it shut',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var bad=[], g, a, b;
     function bright(){
       var c=ctx.canvas, k=c.width/W, R=HUDBOX.gear, x0, y0, w, h, d, n=0, i;
       if(!R) return -1;
       w=Math.max(1,Math.round(R.w*0.26*k)); h=Math.max(1,Math.round(R.h*k));
       x0=Math.min(Math.round((R.x+R.w*0.72)*k),c.width-w); y0=Math.min(Math.max(0,Math.round(R.y*k)),c.height-h);
       d=ctx.getImageData(x0,y0,w,h).data;
       for(i=0;i<d.length;i+=4) if(d[i+3]>200&&d[i]+d[i+1]+d[i+2]>540) n++;
       return n;
     }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; drawHUD(); a=bright();
       if(!(a>=20)) return 'SKIP: staging: the gun card drew too little to measure ('+a+')';
       g.bagOpen=true; drawHUD(); b=bright();
       if(b>a*0.2) bad.push('with the backpack open the gun card still drew ('+b+' bright pixels, '+a+' with it shut)');
       g.bagOpen=false; drawHUD();
       if(bright()<a*0.8) bad.push('the gun card did not come back with the backpack shut');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.bagOpen=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
