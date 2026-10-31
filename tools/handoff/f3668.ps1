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

if ($s.Contains("  {v:'36.68',what:")) { throw "check 36.68 is in the fixture already" }

SubRx @'
  {v:'36.67',what:
'@ @'
  {v:'36.68',what:'record every raid: a raid start begins recording with no key in player 1 only, an extract keeps one clip with no download, a 40 s run keeps none, a 16th clip prunes the oldest',
   run:function(){
     var bad=[], MR=window.MediaRecorder, hadF=Object.prototype.hasOwnProperty.call(window,'__recForce'), fv=window.__recForce,
       put=attClipPut, prn=(typeof attPrune==='function')?attPrune:null, ck=HTMLAnchorElement.prototype.click, cp=Object.assign({},CFG), p2=NETP2, po=P.gameOpts,
       puts=[], dls=0, prunes=0, row=null, i, rows, del, g, GB=3*1024*1024*1024;
     function FakeMR(s,o){ this.stream=s; this.mimeType=(o&&o.mimeType)||''; this.state='inactive'; }
     FakeMR.isTypeSupported=function(m){ return /vp9|vp8|h264/.test(m); };
     FakeMR.prototype.start=function(){ this.state='recording'; };
     FakeMR.prototype.stop=function(){ this.state='inactive'; if(this.ondataavailable) this.ondataavailable({data:new Blob(['autorec'])}); if(this.onstop) this.onstop(); };
     function setOpt(v){ P.gameOpts=Object.assign({},P.gameOpts||{},{autoRec:v}); applyGameOpts(); }
     function dep(){ __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); var s=__state(); return !!(s&&!s.over); }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='autoRec') row=GAMEOPTS[i];
       if(!row) return 'no record every raid row in settings';
       if(row.label!=='record every raid') bad.push('row label '+row.label);
       if(gameOptDefault(row)!==(DEV_LOCAL?1:0)||row.opts[gameOptDefault(row)].cfg.autoRec!==(DEV_LOCAL?1:0)) bad.push('default does not follow his own PC');
       if(typeof recAuto!=='function'||typeof attPrunePick!=='function'||!prn) return 'no auto recorder';
       if(REC.on) recStop();
       window.MediaRecorder=FakeMR; window.__recForce=1;
       attClipPut=function(b,cb){ puts.push(b); if(cb) cb(true); };
       attPrune=function(cb){ prunes++; if(cb) cb(0); };
       HTMLAnchorElement.prototype.click=function(){ if(this.download) dls++; };
       setOpt(0); if(!dep()) return 'no live raid';
       if(REC.on) bad.push('recorded with the row off');
       __endRaid('abandon'); __topClear();
       setOpt(1); if(!dep()) return 'no live raid';
       if(!REC.on||!REC.auto) bad.push('a raid start did not start the recorder');
       else{
         if(!REC.mr||REC.mr.mimeType!=='video/webm;codecs=h264') bad.push('codec '+(REC.mr&&REC.mr.mimeType)+' over h264');
         if(!REC.cv||REC.cv.width>1600||REC.cv.width%2||REC.cv.height%2) bad.push('recording size '+(REC.cv&&REC.cv.width)+'x'+(REC.cv&&REC.cv.height));
         if(!REC.mark||REC.mark.dataset.auto!=='1'||REC.mark.style.display!=='block'||!/rec/.test(REC.mark.textContent)) bad.push('no small rec dot');
         REC.mr._t0=Date.now()-40000;
       }
       __endRaid('extract');
       if(REC.on) bad.push('the run end left the recorder on');
       if(puts.length) bad.push('a 40 s run was kept');
       __topClear();
       if(!dep()) return 'no live raid';
       if(!REC.on) bad.push('the second raid did not record');
       recStop(); if(puts.length) bad.push('a stop at once was kept');
       NETP2=true; if(recAuto()||REC.on) bad.push('the player 2 window recorded'); NETP2=p2;
       if(!recAuto()) bad.push('the player 1 window would not record again');
       else REC.mr._t0=Date.now()-61000;
       __endRaid('extract');
       if(puts.length!==1) bad.push('an extract kept '+puts.length+' clips');
       if(prunes!==1) bad.push('no prune after the save');
       if(dls) bad.push('an auto recording fired a download');
       __topClear();
       rows=[]; for(i=0;i<16;i++) rows.push({key:'clip-'+(1000+i),time:1000+i,blob:{size:1}});
       if(REC_CFG.keepN!==15||REC_CFG.keepBytes!==GB) bad.push('store limits');
       del=attPrunePick(rows,REC_CFG.keepN,REC_CFG.keepBytes); if(del.join()!=='clip-1000') bad.push('16 clips pruned '+del.join());
       rows.push({key:'main',time:0,blob:{size:1}}); del=attPrunePick(rows,REC_CFG.keepN,REC_CFG.keepBytes);
       if(del.length!==2||del.indexOf('main')<0||del.indexOf('clip-1000')<0) bad.push('the old main clip was not pruned first');
       del=attPrunePick([{key:'clip-3',time:3,blob:{size:2e9}},{key:'clip-2',time:2,blob:{size:2e9}},{key:'clip-1',time:1,blob:{size:1}}],REC_CFG.keepN,REC_CFG.keepBytes);
       if(del.join()!=='clip-2,clip-1') bad.push('3 gb cap pruned '+del.join());
       return bad.length?bad.join('; '):null;
     }finally{
       try{ if(REC.on) recStop(); }catch(e){}
       NETP2=p2; window.MediaRecorder=MR; if(hadF) window.__recForce=fv; else delete window.__recForce;
       attClipPut=put; if(prn) attPrune=prn; HTMLAnchorElement.prototype.click=ck;
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(e){} __topClear();
       P.gameOpts=po; try{ applyGameOpts(); }catch(e){} Object.assign(CFG,cp);
     }
   }},
  {v:'36.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
