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

if ($s.Contains("  {v:'16.70',what:")) { throw "check 16.70 is in the fixture already" }

SubRx @'
  {v:'16.69',what:
'@ @'
  {v:'16.70',what:'a spectating host back in the Undercroft lets the kept raid go once his teammate stops sending, as he already did on his run card, so a later ascent is not refused for good',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||typeof netOnState!=='function'||typeof netUpTick!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host';
     var keep={}, oSend=netSend, oRef=netRefresh, st0=null, S=null, pr={state:'in',seat:1}, bad=[], k, i, a0, px=0, py=0;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function word(){ return netOnState(pr,{t:'st',k:'r',x:px,y:py,f:0,m:0,pz:1,sd:NET.upSeed>>>0}); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid to spectate';
       st0=state;
       netSend=function(){ return true; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[pr]; NET.up=[]; NET.specG=null;
       NET.entMap={}; NET.entGone={}; NET.entN=0; NET.contMap={}; NET.contN=0; NET.contN0=0; NET.holds={}; NET.srch=null; NET.srchOwn=-1;
       NET.roster=[{seat:0,name:'CHECKHOST'},{seat:1,name:'CHECKKID'}];
       px=+G.player.x||0; py=+G.player.y||0;
       if(word()!=='state'||!NET.up[1]) return 'SKIP: staging: the teammate position word was not filed';
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; S=G;
       state='raid'; word(); a0=NET.up[1].age;
       netSpecTick(0.5); netUpTick(0.5);
       if(!NET.up[1]||Math.abs(NET.up[1].age-a0-0.5)>1e-6) bad.push('on his run card one 0.5 s frame aged the teammate word by '+(NET.up[1]?(NET.up[1].age-a0).toFixed(2):'none')+' s, not 0.5');
       state='hub'; G=null;
       for(i=0;i<8;i++){ word(); netSpecTick(0.5); }
       if(NET.specG!==S) bad.push('a teammate still sending was let go after 4 s with the host in the Undercroft');
       else {
         for(i=0;i<20&&NET.specG;i++) netSpecTick(0.5);
         if(NET.specG) bad.push('back in the Undercroft the host kept the raid 10 s after his teammate stopped sending (word age '+(NET.up[1]?NET.up[1].age:'none')+' s), so every later ascent is refused');
       }
     } finally {
       if(S) G=S;
       if(st0!==null) state=st0;
       netSend=oSend; netRefresh=oRef;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
