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

if ($s.Contains("  {v:'17.14',what:")) { throw "check 17.14 is in the fixture already" }

SubRx @'
  {v:'17.13',what:
'@ @'
  {v:'17.14',what:'a player 2 window still on its title goes up with the party: the kit question and the host word take it past the title, and a host up top is told in the raid when a teammate could not go up',
   run:function(){
     if(typeof netKitTake!=='function'||typeof netUpTake!=='function'||typeof netUpWord!=='function'||typeof netUpBusy!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this build has no party ascent';
     var t=document.getElementById('title'), mod=document.getElementById('askmodal');
     if(!t) return 'SKIP: this build has no title';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status,err:NET.err,start:NET.start,seat:NET.seat,up:NET.up,upOut:NET.upOut,roster:NET.roster},
         oSend=netSend, oStart=netUpStart, oRef=netRefresh, oSwf=sayWhenFree, g0=G, k0=keys, st0=state, t0=t.classList.contains('on'), bad=[], said=[], r, went=0, passed=0, mate;
     try{
       netSend=function(){ return true; }; netRefresh=function(){}; netUpStart=function(){ went++; return 'up'; };
       sayWhenFree=function(m){ said.push(String(m)); };
       NET.start=function(){ passed++; t.classList.remove('on'); };
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}]; G=null; state='hub';
       // ONE: the kit question reaches a window still on its title.
       t.classList.add('on');
       if(netUpBusy()!=='on the title') return 'SKIP: staging: the window does not read as on the title ('+netUpBusy()+')';
       r=netKitTake({state:'in'},{t:'kitask'});
       if(r!=='kit:ask'||!passed) bad.push('the kit question reached a window on its title as '+r+' and did not take it past the title, so the host went up without it');
       if(mod) mod.classList.remove('on');
       try{ ASKYES=null; ASKALT=null; ASKBACK=null; ASKRAND=null; ASKTOP=null; }catch(e){}
       // TWO: the host word reaches a window still on its title.
       passed=0; went=0; t.classList.add('on');
       r=netUpTake({state:'in'},{t:'raid',seed:4242});
       if(r!=='up'||!went||!passed) bad.push('the host word left a window on its title below ('+r+')');
       // THREE: the host, up top in a raid, hears that a teammate could not go up.
       NET.role='host'; NET.seat=0; NET.up=[]; NET.upOut=undefined; NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ZQX MATE'}];
       mate={state:'in',seat:1}; NET.peers=[mate];
       G={over:false,sim:false,msgT:0,msgQ:[]}; said.length=0;
       r=netUpWord(mate,{t:'up',st:'no',why:'on the title'});
       if(r!=='up:no') return 'SKIP: staging: the host did not file the word ('+r+')';
       if(!said.some(function(s){ return s.indexOf('ZQX MATE')>=0; })) bad.push('a host up top was told nothing in the raid when his teammate could not go up (status: '+NET.status+')');
     } finally {
       netSend=oSend; netUpStart=oStart; netRefresh=oRef; sayWhenFree=oSwf;
       NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.err=keep.err; NET.start=keep.start; NET.seat=keep.seat; NET.up=keep.up; NET.upOut=keep.upOut; NET.roster=keep.roster;
       G=g0; keys=k0||{}; state=st0;
       if(t0) t.classList.add('on'); else t.classList.remove('on');
       if(mod) mod.classList.remove('on'); try{ ASKYES=null; ASKALT=null; ASKBACK=null; ASKRAND=null; ASKTOP=null; }catch(e){}
       try{ if(typeof kitExtraHide==='function') kitExtraHide(); }catch(e){}
       try{ __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
