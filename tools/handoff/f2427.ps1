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

if ($s.Contains("  {v:'24.27',what:")) { throw "check 24.27 is in the fixture already" }

SubRx @'
  {v:'24.26',what:
'@ @'
  {v:'24.27',what:'his #50 (UI redesign ui7): a world prompt draws its key as a keycap: hudPrompt([E] SEARCH) still fills the whole line once (his wording and the word editor see it whole) but clips the [E] out of it and draws a key shape with the letter E inside the room [E] had, and uiKey names a key as a keycap span',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], OWN=Object.prototype.hasOwnProperty, oFT=ctx.fillText, oRR=ctx.roundRect, oCL=ctx.clip, fills=[], rr=[], clips=0, on0=(typeof PAD!=='undefined'&&PAD)?PAD.on:false, s, w, k0, k1, key;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(typeof PAD!=='undefined'&&PAD) PAD.on=false;
       ctx.save();
       try{
         ctx.font=FS(TYPE.head); w=ctx.measureText('[E] SEARCH').width; k0=400-w/2; k1=k0+ctx.measureText('[E]').width;
         ctx.fillText=function(t){ fills.push(String(t)); return oFT.apply(this,arguments); };
         ctx.clip=function(){ clips++; return oCL.apply(this,arguments); };
         if(oRR) ctx.roundRect=function(x,y,ww,h){ rr.push([x,y,ww,h]); return oRR.apply(this,arguments); };
         hudPrompt('[E] SEARCH',400,300);
       } finally { ctx.restore(); }
       if(fills.indexOf('[E] SEARCH')<0) bad.push('the whole line is no longer filled once ('+JSON.stringify(fills).slice(0,100)+')');
       if(fills.indexOf('E')<0) bad.push('the key letter E was not drawn on a key of its own');
       if(fills.indexOf('[E]')>=0) bad.push('the bracketed key is still printed over the line');
       if(!clips) bad.push('the [E] is not cut out of the line');
       if(oRR){ key=rr.filter(function(q){ return q[0]>=k0-1&&q[0]<k1&&q[0]+q[2]<=k1+1; });
         if(!key.length) bad.push('no key shape in the room [E] had ('+Math.round(k0)+' to '+Math.round(k1)+'; shapes '+JSON.stringify(rr.map(function(q){ return q.map(Math.round); })).slice(0,100)+')'); }
       s=(typeof uiKey==='function')?uiKey('KeyE','E'):'';
       if(!(/class="ui-key[^"]*"/).test(s)) bad.push('uiKey gives no keycap span ('+s.slice(0,40)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(OWN.call(ctx,'fillText')) delete ctx.fillText; if(OWN.call(ctx,'clip')) delete ctx.clip; if(OWN.call(ctx,'roundRect')) delete ctx.roundRect; if(typeof PAD!=='undefined'&&PAD) PAD.on=on0;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
