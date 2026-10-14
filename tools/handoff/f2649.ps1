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

if ($s.Contains("  {v:'26.49',what:")) { throw "check 26.49 is in the fixture already" }

SubRx @'
  {v:'26.48',what:
'@ @'
  {v:'26.49',what:'settings8, his order 2026-10-14: ACCESSIBILITY has COLOUR-BLIND MODE (off, deuteranopia, protanopia, tritanopia): off is the game as drawn, and each mode swaps the rarity colours, the enemy and ally marks and the stylesheet tokens for a set whose five rarities and two sides stay far apart in the eye of that colour blindness (simulated here), and off puts the original colours back exactly',
   run:function(){
     if(!(window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof RCOL==='undefined'||typeof TEAMCOL==='undefined'||typeof UIC==='undefined'||typeof HUDC==='undefined') return 'SKIP: no colour tables here';
     if(typeof cbApply!=='function') return 'Settings has no colour-blind mode';
     var bad=[], md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kCB=CFG.cb, rows, rr, sn, i, j, k, a, el, cs, S0,
         NORM=['#9da3a8','#5fbf6a','#3f9de9','#a866e0','#ffc72e'], KEYS=['common','uncommon','rare','elite','gold'],
         MX={prot:[[0.152286,1.052583,-0.204868],[0.114503,0.786281,0.099216],[-0.003882,-0.048116,1.051998]],deut:[[0.367322,0.860646,-0.227968],[0.280085,0.672501,0.047413],[-0.011820,0.042940,0.968881]],trit:[[1.255528,-0.076749,-0.178779],[-0.078411,0.930809,0.147602],[0.004733,0.691367,0.303900]]};
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function lin(c){ c/=255; return c<=0.04045?c/12.92:Math.pow((c+0.055)/1.055,2.4); }
     function gam(c){ c=Math.max(0,Math.min(1,c)); return 255*(c<=0.0031308?12.92*c:1.055*Math.pow(c,1/2.4)-0.055); }
     function rgb(h){ return [parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)]; }
     function sim(h,m){ var c=rgb(h).map(lin), M=MX[m]; return [0,1,2].map(function(y){ return gam(M[y][0]*c[0]+M[y][1]*c[1]+M[y][2]*c[2]); }); }
     function dist(p,q){ return Math.sqrt((p[0]-q[0])*(p[0]-q[0])+(p[1]-q[1])*(p[1]-q[1])+(p[2]-q[2])*(p[2]-q[2])); }
     function minSep(list,m){ var s=list.map(function(h){ return m?sim(h,m):rgb(h); }), mn=1e9, x, y; for(x=0;x<s.length;x++) for(y=x+1;y<s.length;y++) mn=Math.min(mn,dist(s[x],s[y])); return mn; }
     function rar(){ return KEYS.map(function(q){ return RCOL[q]; }); }
     try{
       P.gameOpts={}; P.tuned={}; __opts.apply(); cbApply();
       // ONE: the row, in ACCESSIBILITY, off by default, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       rr=null; for(i=0;i<rows.length;i++) if(rows[i].k==='cb') rr=rows[i];
       if(!rr) bad.push('ONE: Settings has no cb row');
       else {
         if(CFG.cb!==0) bad.push('ONE: a fresh profile has cb '+CFG.cb+', not 0');
         if(gameOptLive('cb')!==rr.def) bad.push('ONE: the row reads CUSTOM on a fresh profile');
         if(secOf('go_cb')!=='ACCESSIBILITY') bad.push('ONE: the row sits under '+secOf('go_cb')+', not ACCESSIBILITY');
         if(!document.getElementById('setsec_ACCESSIBILITY')) bad.push('ONE: Settings draws no ACCESSIBILITY head');
         sn=[CFG.cb]; for(j=1;j<5;j++){ __opts.cycle('cb'); sn.push(CFG.cb); }
         if(sn.join(',')!=='0,1,2,3,0') bad.push('ONE: clicking steps it '+sn.join(' > ')+', not 0 > 1 > 2 > 3 > 0');
         if(typeof P.gameOpts.cb!=='number') bad.push('ONE: the pick was not saved');
       }
       P.gameOpts={}; __opts.apply(); CFG.cb=0; cbApply();
       // TWO: off is the game as drawn
       if(rar().join(',')!==NORM.join(',')) bad.push('TWO: control: the rarity colours with the mode off are '+rar().join(' '));
       if(TEAMCOL.ally!=='#5fb0ff'||TEAMCOL.foe!=='#e5482f') bad.push('TWO: control: the team colours with the mode off are '+TEAMCOL.ally+' '+TEAMCOL.foe);
       // THREE: each mode swaps them, everywhere they are read, and its eye can tell them apart
       [[1,'deut'],[2,'prot'],[3,'trit']].forEach(function(q){
         CFG.cb=q[0]; cbApply();
         if(rar().join(',')===NORM.join(',')) bad.push('THREE: mode '+q[0]+' left the rarity colours as they were');
         for(k=0;k<5;k++){ if(UIC['r_'+KEYS[k]]!==RCOL[KEYS[k]]) bad.push('THREE: mode '+q[0]+': the menu colour of '+KEYS[k]+' is not the world one'); }
         el=document.createElement('span'); el.className='r-uncommon'; document.body.appendChild(el); cs=getComputedStyle(el).color; document.body.removeChild(el);
         a=rgb(RCOL.uncommon); if(cs!=='rgb('+a.join(', ')+')') bad.push('THREE: mode '+q[0]+': the stylesheet uncommon colour is '+cs+', not rgb('+a.join(', ')+')');
         if(minSep(rar(),q[1])<60) bad.push('THREE: mode '+q[0]+': two rarities are only '+minSep(rar(),q[1]).toFixed(0)+' apart in the simulated eye');
         if(dist(sim(TEAMCOL.ally,q[1]),sim(TEAMCOL.foe,q[1]))<150) bad.push('THREE: mode '+q[0]+': the two sides are only '+dist(sim(TEAMCOL.ally,q[1]),sim(TEAMCOL.foe,q[1])).toFixed(0)+' apart');
         if(HUDC.ally!==UIC.ally||HUDC.special!==UIC.r_elite) bad.push('THREE: mode '+q[0]+': the HUD tables are not the menu ones');
       });
       // the control: the original colours are NOT apart for a green-blind eye, which is the reason for the mode
       if(!(minSep(NORM,'deut')<40)) bad.push('THREE: control: the original rarities are '+minSep(NORM,'deut').toFixed(0)+' apart for a green-blind eye, not close');
       // FOUR: off puts every original back, and the page token
       CFG.cb=0; cbApply();
       if(rar().join(',')!==NORM.join(',')||TEAMCOL.ally!=='#5fb0ff'||TEAMCOL.foe!=='#e5482f'||TEAMHI.foe!=='#ff9a84'||UIC.ally!=='#9cc7ff'||HUDC.danger!=='#e5482f') bad.push('FOUR: off did not put the original colours back');
       el=document.createElement('span'); el.className='r-uncommon'; document.body.appendChild(el); cs=getComputedStyle(el).color; document.body.removeChild(el);
       if(cs!=='rgb(95, 191, 106)') bad.push('FOUR: off left the stylesheet uncommon colour at '+cs);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.cb=0; cbApply(); CFG.cb=kCB; }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); cbApply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
