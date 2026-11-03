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

if ($s.Contains("  {v:'37.44',what:")) { throw "check 37.44 is in the fixture already" }

SubRx @'
  {v:'37.43',what:
'@ @'
  {v:'37.44',what:'cw-m3doll2: the key hints stand under the panels, not on them; the slots and figure fill the doll panel; the list groups pieces by kind and its head reads stash n; save outfit is the lime button; the tip panel reads pick a piece until something is picked',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof gearOpen!=='function') return 'no doll in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], i, K, L, a, b, fr, wr, gap, cs;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.gear=[]; P.worn={}; P.outfits=[];
       showScreen('hub');
       K=Object.keys(WORN_KINDS);
       for(i=0;i<24;i++) wornAdd(P,wornMake(K[i%K.length],i%4,20+i,700+i));
       need(gearOpen('stash')===true,'the doll did not open');
       // the hints stand under the panels
       fr=E('gearhints').getBoundingClientRect(); wr=E('gearwrap').getBoundingClientRect();
       need(fr.height>=20,'the hints are '+fr.height+' tall');
       need(fr.top>=wr.bottom-1,'the hints start at '+Math.round(fr.top)+', the panels end at '+Math.round(wr.bottom));
       need(fr.bottom<=window.innerHeight,'the hints are off the window');
       // the doll fills its panel
       wr=E('geardoll').getBoundingClientRect(); a=E('gearsum').getBoundingClientRect();
       gap=wr.bottom-a.bottom;
       need(gap<220,'the doll panel stands empty for '+Math.round(gap)+'px under the sum');
       a=document.querySelector('#gearslots [data-gs="head"]').getBoundingClientRect(); b=document.querySelector('#gearslots [data-gs="armor"]').getBoundingClientRect();
       need(a.height>=96&&b.top>=a.bottom,'the head slot is '+a.height+' tall, armor starts at '+b.top);
       a=document.querySelector('#gearslots [data-gs="boots"]').getBoundingClientRect(); b=document.querySelector('#gearslots [data-gs="pack"]').getBoundingClientRect();
       need(Math.abs(a.top-b.top)<2&&Math.abs(a.height-b.height)<2&&b.left>=a.right,'the backpack does not stand in the row of boots: '+JSON.stringify([a,b]));
       a=document.querySelector('#gearslots [data-gs="gloves"]').getBoundingClientRect();
       need(Math.abs(a.top-b.top)<2&&a.left>=b.right,'gloves do not stand in the row of the backpack');
       need(E('gearcv').getBoundingClientRect().bottom<=b.top+1&&E('gearcv').getBoundingClientRect().height>200,'the figure stands at '+JSON.stringify(E('gearcv').getBoundingClientRect()));
       // grouped by kind, a gap between groups, the head says what it counts
       L=document.querySelectorAll('#gearlist .grow');
       a={}; b=''; for(i=0;i<L.length;i++){ fr=P.gear.filter(function(g){ return g.id===L[i].getAttribute('data-gp'); })[0].k;
         if(fr!==b){ need(!a[fr],'the '+fr+' rows are in two places'); a[fr]=1; need((i>0)===L[i].classList.contains('gnew'),'row '+i+' starts a group: '+L[i].className); b=fr; }
         else need(!L[i].classList.contains('gnew'),'row '+i+' is a gap inside a group'); }
       need(document.querySelector('#gearhd b').textContent==='stash 24','the list head reads '+document.querySelector('#gearhd b').textContent);
       // one lime action, a tip panel that is never blank, the pad told how to move
       cs=getComputedStyle(E('gearsavebtn'));
       E('gearname').value=''; P.worn={}; a=P.gear[0]; wornWear(P,a.id); gearDraw();
       cs=getComputedStyle(E('gearsavebtn'));
       need(!E('gearsavebtn').disabled&&cs.backgroundColor==='rgb(230, 255, 61)','save outfit is '+cs.backgroundColor);
       GEAR.tip=''; gearTipDraw();
       need(E('geartip').textContent==='pick a piece','the empty tip reads '+JSON.stringify(E('geartip').textContent));
       need(/d-pad/.test(E('gearhints').textContent),'the pad hints read '+E('gearhints').textContent);
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ padSetFocus(null); PAD.focus=null; E('gearmodal').classList.remove('on'); }catch(_m){}
       P=saved;
       (function(){ var n, s=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s) P[n]=s[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
