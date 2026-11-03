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

if ($s.Contains("  {v:'37.47',what:")) { throw "check 37.47 is in the fixture already" }

SubRx @'
  {v:'37.46',what:
'@ @'
  {v:'37.47',what:'cw-m3doll3: the longest piece name stays inside its slot; an outfit name shows whole; the tip panel is the dark fill worse reads on; the list fades at its bottom edge, a highlighted row stops clear of the fade, the scroll thumb is not amber',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof gearOpen!=='function') return 'no doll in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], i, K, a, b, s, cs, L, r, m;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.gear=[]; P.worn={}; P.outfits=[];
       showScreen('hub');
       K=Object.keys(WORN_KINDS);
       for(i=0;i<K.length;i++){ a=wornAdd(P,wornMake(K[i],2,50,900+i)); wornWear(P,a.id); }
       for(i=0;i<40;i++) wornAdd(P,wornMake(K[i%K.length],i%4,20+i,950+i));
       need(gearOpen('stash')===true,'the doll did not open');
       E('gearname').value='quiet run'; E('gearsavebtn').click();
       // the longest name stays inside its slot
       s=document.querySelector('#gearslots [data-gs="armor"]'); b=s.querySelector('b');
       need(b.textContent==='rare breacher plate','the armor slot reads '+b.textContent);
       need(s.scrollWidth<=s.clientWidth+1&&b.getBoundingClientRect().right<=s.getBoundingClientRect().right+1,'the name runs out of its slot: '+s.scrollWidth+' over '+s.clientWidth);
       // an outfit name shows whole
       b=document.querySelector('#gearofs .gofb b');
       need(b.scrollHeight<=b.clientHeight,'the outfit name is cut: '+b.scrollHeight+' over '+b.clientHeight);
       // worse reads on the tip panel
       cs=getComputedStyle(E('geartip'));
       need(cs.backgroundColor==='rgb(17, 19, 21)','the tip panel is '+cs.backgroundColor);
       // the list fades, a highlighted row stops clear of the fade, the thumb is the line colour
       L=E('gearlist'); cs=getComputedStyle(L); m=cs.webkitMaskImage||cs.maskImage||'';
       need(/gradient/.test(m),'the list has no fade: '+m);
       need(/74, 82, 87/.test(cs.scrollbarColor),'the scroll thumb is '+cs.scrollbarColor);
       a=L.querySelectorAll('.grow');
       for(i=0;i<a.length;i++){ if(a[i].getBoundingClientRect().bottom>L.getBoundingClientRect().bottom+40){ break; } }
       L.style.scrollBehavior='auto'; padSetFocus(a[Math.min(i,a.length-1)]);
       r=a[Math.min(i,a.length-1)].getBoundingClientRect();
       need(r.bottom<=L.getBoundingClientRect().bottom-20,'the highlighted row ends at '+Math.round(r.bottom)+', the list at '+Math.round(L.getBoundingClientRect().bottom));
       L.style.scrollBehavior='';
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ padSetFocus(null); PAD.focus=null; E('gearname').value=''; E('gearmodal').classList.remove('on'); }catch(_m){}
       P=saved;
       (function(){ var n, s2=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s2) P[n]=s2[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
