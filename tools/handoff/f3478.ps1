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

if ($s.Contains("  {v:'34.78',what:")) { throw "check 34.78 is in the fixture already" }

SubRx @'
  {v:'34.77',what:
'@ @'
  {v:'34.78',what:'the opened career controls list: every row at the 16px label size, key caps drawn, one footer line, clear of the feed, the vitals and the bot list; the folded chip uses the same HUD panel and label face as the standing tag (job 121)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof careerPostBuild!=='function') return 'SKIP: no raid in this fixture';
     var bad=[], r0=P.runs, oSay=say, g=null, ft=ctx.fillText, sr=ctx.strokeRect, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), ownS=Object.prototype.hasOwnProperty.call(ctx,'strokeRect');
     var rows=[], foot=0, caps=0, i, L, fb, hb, rb, d, small=0, hit;
     function hitR(a,b){ return a&&b&&a.w>0&&b.w>0&&a.x<b.x+b.w&&b.x<a.x+a.w&&a.y<b.y+b.h&&b.y<a.y+a.h; }
     try{
       say=function(){};
       P.runs=0; __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no raid';
       g.career=1; g.arcade=0; g.legendAutoDone=true; g.legendOn=1; g.bagOpen=false; g.mapOpen=false; keys={};
       for(i=0;i<10;i++) __frame();
       d=DPRH||1;
       ctx.fillText=function(s,x,y){
         var t=String(s).toLowerCase(), m=ctx.getTransform(), px=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,16])[1]);
         if(/^(move|sprint|crouch|roll|fire|sights|reload|melee|next gun|item wheel|guns|backpack|use item|map|search|extract)$/.test(t)) rows.push(px*Math.abs(m.a)/d);
         if(/full list/.test(t)) foot++;
         return ft.apply(this,arguments);
       };
       ctx.strokeRect=function(){ caps++; return sr.apply(this,arguments); };
       __frame();
       L=HUDBOX.legend; fb=FEEDBOX; hb=HUDBOX.body; rb=HUDBOX.raiders;
       if(!rows.length) bad.push('no key row words were drawn');
       for(i=0;i<rows.length;i++) if(rows[i]<16-0.01) small++;
       if(small) bad.push(small+' of '+rows.length+' row words are under the 16px label size (smallest '+Math.round(Math.min.apply(null,rows)*10)/10+'px)');
       if(caps<10) bad.push('the key caps are not drawn as boxes ('+caps+')');
       if(foot!==1) bad.push('the footer line is drawn '+foot+' times, not once');
       if(!L||!(L.w>0)) bad.push('no list box');
       else {
         if(L.y<H/2) bad.push('the list box starts above the lower half: y '+Math.round(L.y)+' h '+Math.round(L.h)+' bottom '+Math.round(L.y+L.h)+' of '+H+' zoom '+HUDZ.legend);
         if(fb&&fb.on&&hitR(L,fb)) bad.push('the opened list overlaps the left log');
         if(hitR(L,hb)) bad.push('the opened list overlaps the vitals');
         if(hitR(L,rb)) bad.push('the opened list overlaps the bot list');
       }
       g.legendOn=0; for(i=0;i<6;i++) __frame();
       hit=(typeof LEGHINT!=='undefined')?LEGHINT:null;
       if(!hit) bad.push('the folded chip did not draw');
       else if(hit.h<16*1.3) bad.push('the folded chip is only '+Math.round(hit.h)+' high, not a standing-tag chip');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) ctx.fillText=ft; else delete ctx.fillText; if(ownS) ctx.strokeRect=sr; else delete ctx.strokeRect; say=oSay; P.runs=r0; try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'34.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
