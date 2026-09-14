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
  {v:'14.50',what:
'@ @'
  {v:'14.51',what:'a crash note keeps where it happened: an error with a long message raised through the real error listener is noted with a line and column in its location (report audit finding 2)',
   run:function(){
     if(typeof noteCrash!=='function'||typeof PLOADED==='undefined'||!PLOADED) return 'SKIP: no loaded crash catcher in this build';
     var bad=[], _sp=saveProfile, keep=P.crashes, keepAt=noteCrash.savedAt, keepTold=crashTold;
     try{
       P.crashes=[]; noteCrash.savedAt=0;
       saveProfile=function(){};
       var long='zqx long fault '+new Array(19).join('the canvas refused a value that was not finite ');
       var er=new Error(long);
       if(!er.stack||!/:\d+:\d+/.test(String(er.stack))) return 'SKIP: this browser gives the error no stack with a line and column';
       window.dispatchEvent(new ErrorEvent('error',{error:er,message:er.message,cancelable:true}));
       var got=P.crashes.filter(function(c){ return /zqx long fault/.test(c.msg); })[0];
       // CONTROL: the real listener noted the error.
       if(!got) return 'SKIP: the error listener did not note the raised error here';
       if(!/:\d+:\d+/.test(String(got.where||''))) bad.push('an error with a long message was noted with no line and column: "'+String(got.where||'').slice(0,90)+'..."');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ saveProfile=_sp; P.crashes=keep; noteCrash.savedAt=keepAt; try{ crashTold=keepTold; }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
