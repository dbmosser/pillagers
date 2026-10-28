  {v:'VER',what:'menus master pass 2026-10-28: on the KIA card HOW IT WENT and DAMAGE TAKEN sit side by side at the 16px body size with names left aligned (they were 11.5px rows stacked under each other, names centred, and at 4K the card ran past the screen so its stats slid under the button); on the EXTRACTED card DAMAGE TAKEN lays its sources out in two columns so the footnote no longer runs under the button',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, man, k, a, b, ra, rb, rows, i, fs, rg, nm, rr, r0, r1;
     var HL=[{t:41,n:'CRAWLER',w:'CLAWS',a:12,hp:88},{t:77,n:'SENTRY R-34',w:'AUTOCANNON',a:18,hp:70},{t:131,n:'RUSTY VANCE',w:'AUTO RIFLE',a:22,hp:48},{t:132,n:'RUSTY VANCE',w:'AUTO RIFLE',a:22,hp:26},{t:144,n:'RUSTY VANCE',w:'AUTO RIFLE',a:22,hp:4}];
     function raid(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(typeof CAREER_ON==='number') CAREER_ON=0;
       __deploy({kit:['gun_carbine','medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       if(g.tel) g.tel.hitLog=JSON.parse(JSON.stringify(HL));
       return true;
     }
     function leftText(el){ rg=document.createRange(); rg.selectNodeContents(el); return rg.getBoundingClientRect().left; }
     try{
       if(!raid()) return 'SKIP: no live raid';
       __endRaid('dead');
       man=document.getElementById('oc_manifest');
       k=man?man.querySelector('.ockia'):null;
       if(!k) bad.push('the KIA card has no side by side HOW IT WENT and DAMAGE TAKEN block');
       else {
         a=k.children[0]; b=k.children[1];
         if(!a||!b||k.children.length!==2) bad.push('the KIA block holds '+k.children.length+' parts, not 2');
         else {
           ra=a.getBoundingClientRect(); rb=b.getBoundingClientRect();
           if((a.textContent||'').toUpperCase().indexOf('HOW IT WENT')<0||(b.textContent||'').toUpperCase().indexOf('DAMAGE TAKEN')<0) bad.push('the two parts are not HOW IT WENT then DAMAGE TAKEN');
           if(!(ra.width>150&&rb.width>150&&rb.left>=ra.right-1&&Math.abs(ra.top-rb.top)<2)) bad.push('HOW IT WENT and DAMAGE TAKEN are not side by side ('+[ra.left,ra.top,ra.width,rb.left,rb.top,rb.width].map(Math.round).join(',')+')');
           rows=[].slice.call(a.children,2).concat([].slice.call(b.children,1));
           for(i=0;i<rows.length;i++){ fs=parseFloat(getComputedStyle(rows[i]).fontSize); if(fs<15) bad.push('a KIA table row is '+fs+'px'); }
           nm=b.children[1]&&b.children[1].children[0];
           if(nm&&leftText(nm)-rb.left>4) bad.push('DAMAGE TAKEN names are not left aligned ('+Math.round(leftText(nm)-rb.left)+'px in)');
           nm=a.children[2]&&a.children[2].children[1];
           if(nm&&leftText(nm)-nm.getBoundingClientRect().left>4) bad.push('HOW IT WENT names are not left aligned in their column');
         }
       }
       __endRaid('abandon');
       if(!raid()) return bad.concat(['SKIP: no second raid']).join('; ');
       __endRaid('extract');
       try{ if(typeof haulRevealSkip==='function'){ haulRevealSkip(); haulRevealSkip(); } }catch(_hs){}
       man=document.getElementById('oc_manifest');
       rr=man?man.querySelector('.ocrecap > div'):null;
       if(!rr) bad.push('the extracted card has no DAMAGE TAKEN block after hits');
       else {
         rows=[].slice.call(rr.children,1);
         if(rows.length<3) bad.push('DAMAGE TAKEN lists '+rows.length+' sources, not 3');
         else {
           r0=rows[0].getBoundingClientRect(); r1=rows[1].getBoundingClientRect();
           if(!(Math.abs(r0.top-r1.top)<2&&r1.left>=r0.right-1)) bad.push('the extracted DAMAGE TAKEN sources are not in two columns ('+[r0.left,r0.top,r0.width,r1.left,r1.top].map(Math.round).join(',')+')');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ if(typeof CAREER_ON==='number') CAREER_ON=c0; }catch(_c){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
