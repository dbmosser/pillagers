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

if ($s.Contains("  {v:'34.34',what:")) { throw "check 34.34 is in the fixture already" }

SubRx @'
  {v:'34.33',what:
'@ @'
  {v:'34.34',what:'the gambler window: two panels side by side, the inner heading is a 16px label not a 64px title, the gamble button is the lime 56px primary when affordable and not lime when not, and a pad-focused button has a 3px ring',
   run:function(){
     var bad=[], snap=null, m=document.getElementById('gamblemodal');
     if(!m||typeof renderGamble!=='function'||!window.__applyLoaded||!window.__P) return 'SKIP: no Wirt counter in this build';
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.wirtLotBought=null;
       q.credits=GAMBLE_PRICE+WIRT_LOT_PRICE+1; renderGamble(); m.classList.add('on');
       var gb=document.getElementById('gamblebtn'), a=document.getElementById('wirtsec_gamble'), o=document.getElementById('wirtsec_offer');
       var hd=a&&a.firstElementChild;
       if(!gb||!a||!o||!hd) return 'no gamble parts';
       var ra=a.getBoundingClientRect(), ro=o.getBoundingClientRect(), rb=gb.getBoundingClientRect(), mr=m.getBoundingClientRect();
       if(!(ro.left>=ra.right-2&&Math.abs(ro.top-ra.top)<4)) bad.push('panels are not side by side: gamble '+Math.round(ra.left)+'-'+Math.round(ra.right)+' top '+Math.round(ra.top)+', offer '+Math.round(ro.left)+' top '+Math.round(ro.top));
       if(ra.bottom<mr.top+mr.height*0.7) bad.push('panels end at '+Math.round(ra.bottom)+', the card is '+Math.round(mr.top)+'-'+Math.round(mr.bottom));
       if(parseFloat(getComputedStyle(hd).fontSize)>24) bad.push('inner heading is '+getComputedStyle(hd).fontSize);
       gb.style.transition='none'; if(parseFloat(getComputedStyle(gb).minHeight)<56) bad.push('gamble button min height is '+getComputedStyle(gb).minHeight);
       if(!/rgb\(230,\s*255,\s*61\)/.test(getComputedStyle(gb).backgroundColor)) bad.push('affordable gamble button is '+getComputedStyle(gb).backgroundColor+', not lime');
       gb.classList.add('padfocus'); var cs=getComputedStyle(gb);
       if(parseFloat(cs.outlineWidth)<2.1||cs.outlineStyle==='none') bad.push('pad focus ring is '+cs.outlineWidth+' '+cs.outlineStyle);
       gb.classList.remove('padfocus');
       q.credits=0; renderGamble();
       if(/rgb\(230,\s*255,\s*61\)/.test(getComputedStyle(gb).backgroundColor)) bad.push('unaffordable gamble button is still lime');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ m.classList.remove('on'); var g2=document.getElementById('gamblebtn'); if(g2) g2.classList.remove('padfocus'); }catch(_x){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
