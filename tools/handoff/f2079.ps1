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

if ($s.Contains("  {v:'20.79',what:")) { throw "check 20.79 is in the fixture already" }

SubRx @'
  {v:'20.78',what:
'@ @'
  {v:'20.79',what:'on a PlayStation pad the backpack hint, the Peddler rows, the Undercroft footer and the belt and DROP HERE tips name the PlayStation buttons, never A, B or LS',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawBag!=='function'||typeof drawTrade!=='function'||typeof drawHubHUD!=='function'||typeof renderHub!=='function'||typeof PAD!=='object'||!PAD||typeof padB!=='function') return 'SKIP: no raid or pad here';
     var bad=[], g=null, txt=[], had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText, oOn=PAD.on, oBr=PAD.brand, ik=null, k, i, hint=null, oTr=null, pushed=false, nX=0, s1, s2;
     function cap(t){ txt.push(String(t)); }
     function unc(){ if(had) ctx.fillText=oFT; else delete ctx.fillText; }
     for(k in ITEMS) if(ITEMS[k]&&!ITEMS[k].use&&!/^gun_/.test(k)){ ik=k; break; }
     if(!ik) return 'SKIP: no plain item here';
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.player.wep) return 'SKIP: no live raid';
       PAD.on=true; PAD.brand='ps';
       g.bag.push(ik); pushed=true; g.bagOpen=true; g.bagSel=0;
       ctx.fillText=cap;
       try{ drawBag(); } finally { unc(); }
       for(i=0;i<txt.length;i++) if(txt[i].indexOf('past the ends')>=0) hint=txt[i];
       if(hint===null) bad.push('the backpack hint was not drawn ('+txt.length+' lines)');
       else if(/(^|\s)(A|B)(\s|$)/.test(hint)) bad.push('on a PlayStation pad the backpack hint reads: '+hint);
       txt=[]; g.bagOpen=false; oTr=g.trade;
       g.trade={stock:[{k:ik,price:98765,sold:false}],hp:1};
       ctx.fillText=cap;
       try{ g.pedSel=1; drawTrade(); g.pedSel=0; drawTrade(); } finally { unc(); }
       for(i=0;i<txt.length;i++){ if(txt[i].indexOf('[A]')>=0) bad.push('on a PlayStation pad a Peddler row reads: '+txt[i]); if(txt[i].indexOf('[CROSS]')>=0) nX++; }
       if(nX<4) bad.push('the Peddler panel named [CROSS] '+nX+' times in two draws, fewer than 4');
       s1=String(drawHubHUD); s2=String(renderHub);
       if(s1.indexOf("fillText('L STI"+"CK WALK")>=0) bad.push('the Undercroft pad footer names LS, not L3, on a PlayStation pad');
       if(s2.indexOf("?'Pick an item"+" up with A first")>=0) bad.push('the tactical belt plan tip names A on a PlayStation pad');
       if(s2.indexOf("say2('Drag an item"+" onto DROP HERE")>=0) bad.push('the DROP HERE tip names A on a PlayStation pad');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       unc();
       PAD.on=oOn; PAD.brand=oBr;
       try{ var g2=__state(); if(g2){ g2.trade=oTr||null; g2.pedSel=0; g2.bagOpen=false; if(pushed){ var j=g2.bag.lastIndexOf(ik); if(j>=0) g2.bag.splice(j,1); } if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
