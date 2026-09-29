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

if ($s.Contains("  {v:'17.34',what:")) { throw "check 17.34 is in the fixture already" }

SubRx @'
  {v:'17.33',what:
'@ @'
  {v:'17.34',what:'the kit wait never starts the host raid behind the character selection title: with the title up it sends nobody up, RETURN TO CHARACTER SELECTION and ending the party drop a standing kit wait, and on the Undercroft floor it still sends the party up',
   run:function(){
     if(typeof netKitGo!=='function'||typeof netReset!=='function') return 'SKIP: this build has no kit wait';
     var t=document.getElementById('title'), cs=document.getElementById('charselbtn');
     if(!t||!cs||typeof cs.onclick!=='function') return 'SKIP: this build has no character selection title';
     var keep={on:NET.on,role:NET.role,status:NET.status,err:NET.err,kw:NET.kitWait}, kS=state, kG=G, oRef=netRefresh, oSave=saveProfile, wasOn=t.classList.contains('on'), went=0, bad=[];
     var pbx=document.getElementById('pausebox'), wasPb=!!(pbx&&pbx.classList.contains('on')), kPO=pauseOpen, kEL=(typeof HB!=='undefined'&&HB)?HB.eLock:null;
     function wait(){ went=0; NET.kitWait={f:function(){ went++; },need:1,got:0,tm:0}; NET.status='zqx waiting'; }
     try{
       netRefresh=function(){}; saveProfile=function(){};
       NET.on=true; NET.role='host'; state='hub'; G=null;
       t.classList.add('on'); wait();
       netKitGo();
       if(went) bad.push('the kit wait ran out with the host on the character selection title and started his raid behind it');
       if(NET.kitWait) bad.push('the kit wait was left standing on the title');
       t.classList.remove('on'); wait();
       netKitGo();
       if(went!==1) bad.push('control: on the Undercroft floor the kit wait no longer sends the party up');
       wait();
       cs.onclick();
       if(!t.classList.contains('on')) bad.push('control: RETURN TO CHARACTER SELECTION did not raise the title');
       if(NET.kitWait) bad.push('RETURN TO CHARACTER SELECTION left the kit wait standing, so it could still start the raid behind the title');
       else if(NET.status) bad.push('RETURN TO CHARACTER SELECTION left the waiting line up: '+NET.status);
       t.classList.remove('on');
       if(!keep.on&&!NET.same&&!NET.bc){
         wait(); NET.on=false; NET.role=null;
         netReset();
         if(NET.kitWait) bad.push('ending the party left the kit wait standing');
       }
       if(went) bad.push('a dropped kit wait still sent the party up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       netRefresh=oRef; saveProfile=oSave;
       NET.on=keep.on; NET.role=keep.role; NET.status=keep.status; NET.err=keep.err; NET.kitWait=keep.kw||null;
       state=kS; G=kG;
       try{ if(pbx) pbx.classList.toggle('on',wasPb); pauseOpen=kPO; if(kEL!==null) HB.eLock=kEL; }catch(_p){}
       if(wasOn) t.classList.add('on'); else t.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
