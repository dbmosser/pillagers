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
  {v:'14.35',what:
'@ @'
  {v:'14.36',what:'a hidden tab goes quiet: the visibility change on a hidden page suspends the audio context, and still lets go of held keys (audio audit finding 2)',
   run:function(){
     if(typeof AC==='undefined'||typeof releaseAllKeys!=='function') return 'SKIP: no audio context holder in this build';
     if(!document.hidden) return 'SKIP: the page is visible, so the hidden branch cannot be driven here';
     var bad=[], calls=[], _AC=AC;
     function MK(path){ var f=function(){}; return new Proxy(f,{get:function(t,k){ if(k==='currentTime') return 1; if(k==='sampleRate') return 44100; if(k==='state') return 'running'; if(typeof k==='symbol') return k===Symbol.toPrimitive?function(){ return 1; }:undefined; if(k==='then'||k==='toJSON') return undefined; return MK(path+'.'+k); }, set:function(){ return true; }, apply:function(){ calls.push(path); return MK(path+'()'); }}); }
     try{
       __topClear();
       var K=__keysRef(); K['KeyW']=true;
       AC=MK('AC');
       document.dispatchEvent(new Event('visibilitychange'));
       // CONTROL: the handler ran, because it let go of the held key.
       var K2=__keysRef();
       if(K2['KeyW']||K['KeyW']===true&&K2===K) return 'SKIP: the visibility handler did not let go of a held key, so it did not run here';
       if(calls.indexOf('AC.suspend')<0) bad.push('on a hidden page the audio context was not suspended, so the ambient bed keeps playing while the game is frozen ('+(calls.join(',')||'no audio calls')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ AC=_AC; try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
