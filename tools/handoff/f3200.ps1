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

if ($s.Contains("  {v:'32.00',what:")) { throw "check 32.00 is in the fixture already" }

SubRx @'
  {v:'31.99',what:
'@ @'
  {v:'32.00',what:'J10 menu navigation: raw 0.52 moves at large and huge deadzones, D-pad holds repeat after 0.4 s, taps move once',
   run:function(){
     var bad=[],oOM=padOpenModal,oFo=padFocusables,oNow=netPadNow,pk={},k,md=document.createElement('div'),bs=[],T=100,down=-1,i;
     var dz=CFG.padDz,sens=CFG.padSens;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function pressed(n){ return n===down; }
     function poll(t,button){ T=t; down=button; padMenu(pressed); }
     function reset(){ PAD.prev=[]; PAD.ax=[0,0,0,0]; PAD.focusMd=md; PAD.focusIx=0; PAD.mrepAt=null; PAD.mDdir=0; PAD.mDAt=null; PAD.mDmd=null; padSetFocus(bs[0]); }
     function index(){ return bs.indexOf(PAD.focus); }
     function layout(horizontal){
       md.style.width=horizontal?'800px':'160px'; md.style.height=horizontal?'32px':'750px';
       for(var j=0;j<bs.length;j++) bs[j].style.cssText='position:absolute;display:block;left:'+(horizontal?j*30:0)+'px;top:'+(horizontal?0:j*30)+'px;width:'+(horizontal?24:150)+'px;height:24px;min-width:0;min-height:0;box-sizing:border-box;margin:0;padding:0;white-space:nowrap;transform:none!important;transition:none!important';
     }
     for(k in PAD) pk[k]=PAD[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       md.style.cssText='position:fixed;left:8px;top:8px;width:160px;z-index:99999';
       for(i=0;i<24;i++){ var b=document.createElement('button'); b.textContent='menu '+i; md.appendChild(b); bs.push(b); }
       document.body.appendChild(md);
       layout(false);
       padOpenModal=function(){ return md; }; padFocusables=function(){ return bs; }; netPadNow=function(){ return T; };
       [0.32,0.4].forEach(function(d){
         [0.75,1,1.5].forEach(function(s){
           CFG.padDz=d; CFG.padSens=s; reset(); PAD.ax=[0,0.52,0,0]; poll(100,-1);
           need(index()===1,'raw 0.52 at deadzone '+d+', sensitivity '+s+' moved '+index()+' rows');
           reset(); PAD.ax=[0,d-0.001,0,0]; poll(101,-1); need(index()===0,'deadzone drift moved focus at '+d);
           reset(); PAD.ax=[0,0.49,0,0]; poll(102,-1); need(index()===0,'below half travel moved focus at '+d);
         });
       });
       CFG.padDz=0.22; CFG.padSens=1;
       [30,60,144,240].forEach(function(hz){
         reset(); poll(200,13); need(index()===1,'D-down did not step immediately at '+hz+' Hz');
         for(var f=1;f<Math.ceil(0.4*hz);f++) poll(200+f/hz,13);
         need(index()===1,'D-down repeated before 0.4 s at '+hz+' Hz');
         for(;f<=Math.floor(1.2*hz);f++) poll(200+f/hz,13);
         need(index()>=8&&index()<=10,'D-down 1.2 s hold at '+hz+' Hz moved '+index()+' rows, expected about 8');
         var held=index(); poll(201.21,-1); poll(202,-1); need(index()===held,'released D-down continued repeating');
       });
       [12,13,14,15].forEach(function(button){
         layout(button===14||button===15);
         reset(); padSetFocus(bs[10]);
         poll(300,button); var at=index();
         need(at===(button===12||button===14?9:11),'D-pad '+button+' tap reached '+at+' instead of '+(button===12||button===14?9:11));
         poll(300.05,button); poll(300.1,-1); poll(301,-1); need(index()===at,'D-pad '+button+' tap repeated');
         poll(301.01,button); need(index()===(button===12||button===14?8:12),'D-pad '+button+' second tap reached '+index()+' instead of '+(button===12||button===14?8:12));
       });
       layout(false);
       reset(); PAD.ax=[0,0.52,0,0]; poll(400,-1); poll(400.05,-1); need(index()===1,'stick tap repeated before 0.195 s');
       PAD.ax=[0,0,0,0]; poll(400.06,-1); PAD.ax=[0,0.52,0,0]; poll(400.07,-1); need(index()===2,'fresh stick push waited for previous repeat timer');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ padSetFocus(null); }catch(_e){}
       padOpenModal=oOM; padFocusables=oFo; netPadNow=oNow; md.remove();
       try{ __endRaid('abandon'); }catch(_end){} __topClear();
       CFG.padDz=dz; CFG.padSens=sens;
       for(k in PAD) if(!(k in pk)) delete PAD[k]; for(k in pk) PAD[k]=pk[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
