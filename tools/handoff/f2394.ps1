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

if ($s.Contains("  {v:'23.94',what:")) { throw "check 23.94 is in the fixture already" }

SubRx @'
  {v:'23.93',what:
'@ @'
  {v:'23.94',what:'his #35 and #50 (UI redesign ui4): every HUD text call of a drawn raid HUD is set in Barlow (the condensed roles plus num and body), none in Rubik, Titan One or Impact',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof ctx==='undefined') return 'SKIP: no raid HUD here';
     var bad=[], fonts=[], OWN=Object.prototype.hasOwnProperty, own={}, real={}, g, sp=null, odd=[];
     function wrap(n){ own[n]=OWN.call(ctx,n); real[n]=ctx[n]; ctx[n]=function(){ fonts.push(String(ctx.font)); return real[n].apply(this,arguments); }; }
     function unwrap(){ ['fillText','strokeText'].forEach(function(n){ if(!(n in real)) return; if(own[n]) ctx[n]=real[n]; else delete ctx[n]; }); }
     try{
       if(typeof TYPE!=='object'||!TYPE.num||!TYPE.body) bad.push('TYPE has no num or body role');
       ['micro','label','head','title','huge','num','body'].forEach(function(k){ if(TYPE&&TYPE[k]&&!(/Barlow/).test(TYPE[k])) bad.push('TYPE.'+k+' is '+TYPE[k]); });
       __topClear(); __runPrep(); __deploy({kit:['gun_carbine','bandage'],seed:4242,mapIx:0});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       wrap('fillText'); wrap('strokeText');
       try{ drawHUD(); } finally { unwrap(); }
       if(fonts.length<10) bad.push('the drawn HUD made only '+fonts.length+' text calls');
       fonts.forEach(function(f){ if((!(/Barlow/).test(f)||(/Rubik|Titan|Impact/).test(f))&&odd.indexOf(f)<0) odd.push(f); });
       if(odd.length) bad.push('HUD text not in Barlow: '+odd.slice(0,4).join(' | '));
       sp=document.createElement('span'); sp.className='avnum'; sp.textContent='23'; (document.getElementById('root')||document.body).appendChild(sp);
       if(!(/Barlow/).test(getComputedStyle(sp).fontFamily)) bad.push('the shirt number is set in '+getComputedStyle(sp).fontFamily);
       var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd='px "Ru'+'bik",system-ui', ni='Imp'+'act,sans-serif';
       if(src.indexOf(nd)>=0) bad.push('a canvas or page string still names Rubik');
       if(src.indexOf(ni)>=0) bad.push('a page string still names Impact');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ unwrap(); }catch(_u){} try{ if(sp&&sp.parentNode) sp.parentNode.removeChild(sp); }catch(_s){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'23.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
