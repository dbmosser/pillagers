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

if ($s.Contains("  {v:'19.82',what:")) { throw "check 19.82 is in the fixture already" }

SubRx @'
  {v:'19.81',what:
'@ @'
  {v:'19.82',what:'a long contract wraps evenly in the CONDITIONS box: where greedy wrapping would leave one word and the count alone on the second line, the drawn second line carries more than that word',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, oFT=ctx.fillText, c0=P.contracts, h0=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined, seen=[], inner, k, desc=null, tail, gl, alt, f0, i, NB='\u00a0\u00a0';
     function greedy(t,w){ var words=String(t).split(' '),lines=[],cur='',j,tr; for(j=0;j<words.length;j++){ tr=cur?(cur+' '+words[j]):words[j]; if(ctx.measureText(tr).width<=w) cur=tr; else { if(cur) lines.push(cur); cur=words[j]; } } if(cur) lines.push(cur); return lines; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       f0=ctx.font; ctx.font=FS(TYPE.micro); inner=Math.round(LH(165))-16;
       for(k=1;k<40&&!desc;k++){
         var d='Extract carrying 1x '+new Array(k+1).join('Q')+' Zqcore', t=d+NB+'0/1';
         gl=greedy(t,inner);
         if(gl.length!==2||gl[1].indexOf(' ')>=0) continue;
         alt=[gl[0].slice(0,gl[0].lastIndexOf(' ')), gl[0].slice(gl[0].lastIndexOf(' ')+1)+' '+gl[1]];
         if(ctx.measureText(alt[1]).width<ctx.measureText(gl[0]).width) desc=d;
       }
       ctx.font=f0;
       if(!desc) return 'SKIP: no test contract wraps with a lone last word at this size';
       tail='Zqcore'+NB+'0/1';
       P.contracts=[{type:'zqtest',desc:desc,n:1,prog:0}];
       if(!P.hud) P.hud={}; P.hud.cond=Object.assign({},P.hud.cond||{},{c:0});
       ctx.fillText=function(t){ seen.push(String(t)); return oFT.apply(this,arguments); };
       for(i=0;i<3;i++) __frame(0.05);
       var line=null; for(i=0;i<seen.length;i++) if(seen[i].indexOf(tail)>=0){ line=seen[i]; break; }
       if(line===null) return 'SKIP: the test contract was not drawn';
       if(line===tail) bad.push('the second line is the lone word and count: '+line.replace(/\u00a0/g,' '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; P.contracts=c0; if(h0===undefined) delete P.hud; else P.hud=h0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
