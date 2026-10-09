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

if ($s.Contains("  {v:'21.39',what:")) { throw "check 21.39 is in the fixture already" }

SubRx @'
  {v:'21.38',what:
'@ @'
  {v:'21.39',what:'the backpack words line up with the item grid: the BACKPACK title, EQUIPPED and the selected item line start where the first tile starts, and the key line and the price end where the grid ends',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof bagStacks!=='function'||!ITEMS.servo) return 'SKIP: no backpack grid here';
     var bad=[], g, oFT=ctx.fillText, seen=[], c0, bp, gL, gR, st, nm, i, q, f;
     function find(fn){ for(var j=seen.length-1;j>=0;j--) if(fn(seen[j])) return seen[j]; return null; }   // the backpack is drawn late in the frame
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       g.bag.push('servo'); g.bag.push('servo'); g.mapOpen=false; g.bagOpen=true; g.bagSel=0;
       __frame(0.016);
       ctx.fillText=function(s,x,y){ seen.push({s:String(s),x:x,a:ctx.textAlign}); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       c0=(g.bagCells||[])[0]; bp=g.bagPanel;
       if(!c0||!bp) return 'SKIP: the backpack grid was not drawn';
       gL=c0.x; gR=bp.x+bp.w-(c0.x-bp.x);
       if(!(gL-bp.x>12)) return 'SKIP: the grid sits at the panel edge here, so there is nothing to line up';
       st=bagStacks()[g.bagSel||0]; nm=(st&&ITEMS[st.key])?ITEMS[st.key].name:null;
       f=[['the BACKPACK title',function(o){ return o.s==='BACKPACK'&&o.a!=='right'; },gL],
          ['EQUIPPED',function(o){ return o.s==='EQUIPPED'; },gL],
          ['the selected item line',function(o){ return !!nm&&o.s.indexOf(nm)===0&&o.a!=='right'&&o.a!=='center'; },gL],
          ['the key line',function(o){ return o.s.indexOf('to close')>=0&&o.a==='right'; },gR],
          ['the price',function(o){ return o.s.indexOf(' each')>=0&&o.s.charAt(0)==='$'&&o.a==='right'; },gR]];
       for(i=0;i<f.length;i++){
         q=find(f[i][1]);
         if(!q){ bad.push('control: '+f[i][0]+' was not drawn'); continue; }
         if(Math.abs(q.x-f[i][2])>1) bad.push(f[i][0]+' is drawn at '+Math.round(q.x-bp.x)+' from the panel edge, the grid '+(f[i][2]===gL?'starts':'ends')+' at '+Math.round(f[i][2]-bp.x));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2){ g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
