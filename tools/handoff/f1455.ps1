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
  {v:'14.54',what:
'@ @'
  {v:'14.55',what:'a boot crash repeating every frame is one entry: eight reports of one error before the profile loads, differing only in a number, leave one boot crash counted eight times (report audit finding 7)',
   run:function(){
     if(typeof noteCrash!=='function'||typeof PLOADED==='undefined'||typeof PRECRASH==='undefined') return 'SKIP: no boot crash list in this build';
     var bad=[], keepL=PLOADED, keepPC=null;
     try{ keepPC=localStorage.getItem(PRECRASH); }catch(_k){}
     try{
       try{ localStorage.removeItem(PRECRASH); }catch(_r){}
       PLOADED=false;
       for(var i=0;i<8;i++) noteCrash('error','zqx boot fault reading '+(10+i),'zqx:1:1');
       PLOADED=keepL;
       var pc=[]; try{ pc=JSON.parse(localStorage.getItem(PRECRASH)||'[]'); }catch(_p){ pc=[]; }
       var ours=(Array.isArray(pc)?pc:[]).filter(function(c){ return c&&/zqx boot fault/.test(c.msg); });
       // CONTROL: the boot list received the crash.
       if(!ours.length) return 'SKIP: the boot crash list received nothing here';
       if(ours.length!==1) bad.push('eight repeats of one boot crash made '+ours.length+' entries, pushing real crashes out once merged');
       else if(ours[0].n!==8) bad.push('the merged boot crash counted '+ours[0].n+' repeats, not 8');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       PLOADED=keepL;
       try{ if(keepPC===null) localStorage.removeItem(PRECRASH); else localStorage.setItem(PRECRASH,keepPC); }catch(_s){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
