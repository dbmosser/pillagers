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

if ($s.Contains("  {v:'20.76',what:")) { throw "check 20.76 is in the fixture already" }

SubRx @'
  {v:'20.75',what:
'@ @'
  {v:'20.76',what:'on a controller the legends name D-UP for the ping, never both bumpers, and the compact party legend lists the ping once',
   run:function(){
     if(typeof LEGEND_PAD==='undefined'||typeof drawLegend!=='function'||typeof hudOff!=='function'||!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof PAD!=='object'||!PAD) return 'SKIP: no legend or raid here';
     var NK={}, k, bad=[], i, j, r, g=null, bump='LB'+' + '+'RB', txt=[], had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText, oOn=PAD.on, oBr=PAD.brand, oLo, pings=0;
     for(i=0;i<LEGEND_PAD.length;i++) for(j=0;j<LEGEND_PAD[i][1].length;j++){ r=LEGEND_PAD[i][1][j]; if(/ping/i.test(String(r[1]))&&String(r[0]).indexOf(bump)>=0) bad.push('the full controller list says '+r[0]+' '+r[1]); }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(hudOff('legend').c) return 'SKIP: the legend is folded in this profile';
       oLo=g.legendOn; g.legendOn=1; g.bagOpen=false;
       PAD.on=true; PAD.brand='xbox';
       NET.on=true;
       ctx.fillText=function(t){ txt.push(String(t)); };
       try{ drawLegend(); } finally { if(had) ctx.fillText=oFT; else delete ctx.fillText; }
       g.legendOn=oLo;
       if(txt.indexOf('drop to trade')<0) bad.push('the compact party legend lost its drop to trade row ('+txt.length+' lines drawn)');
       for(i=0;i<txt.length;i++) if(/^ping/.test(txt[i])) pings++;
       if(txt.indexOf(bump)>=0) bad.push('the compact party legend names both bumpers for the ping');
       if(pings!==1) bad.push('the compact party legend lists the ping '+pings+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(had) ctx.fillText=oFT; else delete ctx.fillText;
       PAD.on=oOn; PAD.brand=oBr;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ if(oLo!==undefined) g2.legendOn=oLo; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
