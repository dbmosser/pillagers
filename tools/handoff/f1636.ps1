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

if ($s.Contains("  {v:'16.36',what:")) { throw "check 16.36 is in the fixture already" }

SubRx @'
  {v:'16.35',what:
'@ @'
  {v:'16.36',what:'player 2 first contact: the host tells the seat an enemy went for, and that seat stamps its own first contact',
   run:function(){
     if(typeof netContactTake!=='function'||typeof netContactSend!=='function') return 'this build never tells a seat its first contact';
     var keepG=G, keepR=NET.role, keepS=NET.seat, r1, r2, fc1, fc2;
     try{
       G={t:42,sim:false,tel:{firstContact:null}}; NET.role='join'; NET.seat=1;
       r1=netContactTake({state:'in'},{t:'contact',seat:1}); fc1=G.tel.firstContact;
       G.t=50; r2=netContactTake({state:'in'},{t:'contact',seat:1}); fc2=G.tel.firstContact;
     } finally { G=keepG; NET.role=keepR; NET.seat=keepS; }
     if(r1!=='contact'||fc1!==42) return 'the seat did not stamp its first contact ('+r1+', '+fc1+')';
     if(fc2!==42) return 'a second word moved the first contact to '+fc2;
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(p&&p.net) netContactSend(p.seat); else if(T.firstContact===null) T.firstContact=G.t;")<0) return 'the host still stamps its own first contact when an enemy goes for a teammate';
     return null; }},
  {v:'16.35',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
