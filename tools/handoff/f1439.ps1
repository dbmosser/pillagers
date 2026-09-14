$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.38',what:
'@ @'
  {v:'14.39',what:'no audio resume before the first click: on a suspended audio context, ten calls to ac() before any user gesture ask to resume nothing, while after a gesture they still ask (audio audit finding 5)',
   run:function(){
     if(typeof ac!=='function'||typeof AC==='undefined') return 'SKIP: no audio context holder in this build';
     var bad=[], resumes=0, _AC=AC, own=Object.getOwnPropertyDescriptor(navigator,'userActivation'), faked=false;
     var fake={state:'suspended', resume:function(){ resumes++; return {then:function(){}}; }, suspend:function(){}};
     var gesture=function(active){ try{ Object.defineProperty(navigator,'userActivation',{configurable:true,get:function(){ return {hasBeenActive:active,isActive:active}; }}); faked=true; return navigator.userActivation&&navigator.userActivation.hasBeenActive===active; }catch(e){ return false; } };
     try{
       AC=fake;
       if(!gesture(true)) return 'SKIP: this browser will not let the user activation state be faked';
       // CONTROL: after a gesture, a suspended context is asked to resume.
       resumes=0; for(var i=0;i<10;i++) ac();
       if(!resumes) return 'SKIP: after a gesture ac() asked for no resume, so a resume cannot be seen here';
       // THE FIX: before any gesture, no resume is asked for.
       gesture(false);
       resumes=0; for(var j=0;j<10;j++) ac();
       if(resumes) bad.push('before any click, ten calls to ac() asked the browser to resume '+resumes+' times, each one refused and logged');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       AC=_AC;
       try{ if(faked){ if(own) Object.defineProperty(navigator,'userActivation',own); else delete navigator.userActivation; } }catch(_u){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
