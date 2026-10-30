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

if ($s.Contains("  {v:'36.56',what:")) { throw "check 36.56 is in the fixture already" }

SubRx @'
  {v:'36.55',what:
'@ @'
  {v:'36.56',what:'cw-cx-onlinecopy: blocked iframe clipboard leaves the exact mixed-case code focused and selected, with a persistent copy by hand button; success and a new code clear that label',
   run:function(){
     var NK={}, k, saved=false, cd=Object.getOwnPropertyDescriptor(navigator,'clipboard'), ed=Object.getOwnPropertyDescriptor(document,'execCommand');
     var oldFocus=document.activeElement, bad=[], t, b, code, mode='missing', legacy='false', copied='', cb=null;
     function clip(value){ Object.defineProperty(navigator,'clipboard',{configurable:true,value:value}); }
     function manual(tag){
       NET.copyHand=''; NET.code=code; renderParty(); b.focus(); netCopy(); renderParty();
       if(t.value!==code) bad.push(tag+': code changed');
       if(document.activeElement!==t||t.selectionStart!==0||t.selectionEnd!==code.length) bad.push(tag+': code is not focused and fully selected');
       if(b.textContent!=='copy by hand'||NET.status!=='copy by hand') bad.push(tag+': no manual copy label');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(k in NET) NK[k]=NET[k]; saved=true;
       code=sdpPackPlain({type:'answer',sdp:'v=0\r\no=- 1 2 IN IP4 127.0.0.1\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\na=ice-ufrag:AbCdEfGh\r\na=ice-pwd:QrStUvWxYz0123456789AB\r\n'});
       if(!code||code.indexOf('PTY1a')!==0) return 'staging: no reply code';
       NET.role='host'; NET.code=code; NET.reply=''; NET.roster=[]; NET.err=''; NET.pend=null;
       openParty(); t=document.getElementById('partycode'); b=document.getElementById('partycopy');
       Object.defineProperty(document,'execCommand',{configurable:true,value:function(){ if(legacy==='throw') throw new Error('copy blocked'); if(legacy==='true'){ copied=t.value; return true; } return false; }});
       clip(undefined); manual('clipboard missing');
       clip({writeText:function(){ throw new Error('policy blocked'); }}); manual('clipboard throws');
       clip({writeText:function(){ return {then:function(ok,no){ no(new Error('iframe denied')); }}; }}); manual('clipboard rejected');
       legacy='throw'; manual('both paths throw'); legacy='false';
       NET.code=code+'x'; renderParty();
       if(b.textContent!=='copy code') bad.push('a new code keeps the old manual label');
       NET.code=code; renderParty();
       clip({writeText:function(v){ copied=v; return {then:function(ok){ ok(); }}; }}); netCopy();
       if(copied!==code||b.textContent!=='copy code'||NET.status!=='code copied') bad.push('clipboard success loses exact code or keeps manual label');
       clip(undefined); legacy='true'; copied=''; NET.copyHand=code; netCopy();
       if(copied!==code||b.textContent!=='copy code'||NET.status!=='code copied') bad.push('legacy success loses exact code or keeps manual label');
       NET.code=code; renderParty();
       clip({writeText:function(){ return {then:function(ok,no){ cb=no; }}; }}); netCopy();
       NET.code=code+'x'; renderParty(); cb(new Error('late rejection'));
       if(NET.copyHand===code+'x'||b.textContent!=='copy code') bad.push('an old rejection marks the new code as failed');
       return bad.length?bad.join('; '):null;
     }finally{
       if(cd) Object.defineProperty(navigator,'clipboard',cd); else delete navigator.clipboard;
       if(ed) Object.defineProperty(document,'execCommand',ed); else delete document.execCommand;
       if(saved){ for(k in NET) if(!Object.prototype.hasOwnProperty.call(NK,k)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       document.getElementById('partymodal').classList.remove('on');
       __topClear();
       try{ if(oldFocus&&oldFocus.focus) oldFocus.focus(); }catch(_f){}
     }
   }},
  {v:'36.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
