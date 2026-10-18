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

if ($s.Contains("  {v:'31.26',what:")) { throw "check 31.26 is in the fixture already" }

SubRx @'
  {v:'31.25',what:
'@ @'
  {v:'31.26',what:'cw-shkey2, his note (2026-10-18) "superhot mode needs a toggle key": the F1 list names the key as LEFT OF 1 on the Superhot row and clear of the word beside it, and the pane beside the Settings list says key: left of 1',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy or draw a frame';
     if(typeof openSettings!=='function'||typeof applyGameOpts!=='function'||typeof LEGEND==='undefined') return 'SKIP: no Settings window or controls list in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(typeof __vpAlive==='function'&&!__vpAlive()) return 'SKIP: the page has no laid out viewport, so the Settings pane and the controls list cannot be read';
     var bad=[], g=null, txt=[], proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, i, k, w, row, sl, hadGo=!!P.gameOpts, go0=P.gameOpts?JSON.parse(JSON.stringify(P.gameOpts)):null;
     function el(id){ return document.getElementById(id); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=0; applyGameOpts();
       // THE F1 LIST names the key in words, a key the eye can find: LEFT OF 1 on the row of Superhot, clear of the word beside it.
       g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.fd={t:0,seq:0,lines:[]}; g.legendOn=2; g.bagOpen=false;
       proto.fillText=function(){ var s=String(arguments[0]), m=0; try{ m=this.measureText(s).width; }catch(_m){} txt.push({s:s,x:arguments[1],y:arguments[2],w:m}); return oFt.apply(this,arguments); };
       try{ __frame(0.016); } finally { proto.fillText=oFt; }
       k=null; w=null;
       for(i=0;i<txt.length;i++){ if(/^left of 1$/i.test(txt[i].s)) k=txt[i]; if(/^superhot on\/off$/i.test(txt[i].s)) w=txt[i]; }
       if(!w) bad.push('the F1 controls list has no Superhot row');
       else if(!k) bad.push('the F1 controls list does not name the key for Superhot in words (LEFT OF 1)');
       else{
         if(Math.abs(k.y-w.y)>1) bad.push('LEFT OF 1 is not on the Superhot row ('+Math.round(k.y)+' against '+Math.round(w.y)+')');
         if(k.x+k.w+2>w.x) bad.push('LEFT OF 1 runs into the word beside it ('+Math.round(k.x+k.w)+' against '+Math.round(w.x)+')');
       }
       g.legendOn=1;
       // THE PANE beside the Settings list says the same in words.
       if(el('settingsmodal')){
         openSettings();
         row=el('go_superhot'); sl=el('setlist');
         if(row&&sl&&typeof window.__setDetailSync==='function'){
           try{ row.scrollIntoView({block:'center'}); }catch(_si){}
           row.dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
           window.__setDetailSync();
           w=(el('setdetail')||{}).textContent||'';
           if(!/key: left of 1/i.test(w)) bad.push('the pane beside the Settings list does not say "key: left of 1" for Superhot ('+w.slice(0,90)+')');
         } else bad.push('the Settings list has no Superhot row to name a key on');
         el('settingsmodal').classList.remove('on');
       }
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fillText=oFt;
       try{ var _sm=el('settingsmodal'); if(_sm) _sm.classList.remove('on'); }catch(_e0){}
       if(hadGo) P.gameOpts=go0; else delete P.gameOpts;
       try{ applyGameOpts(); saveProfile(); }catch(_e4){}
       try{ __endRaid('abandon'); }catch(_e5){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'31.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
