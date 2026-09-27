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

if ($s.Contains("  {v:'16.38',what:")) { throw "check 16.38 is in the fixture already" }

SubRx @'
  {v:'16.37',what:
'@ @'
  {v:'16.38',what:'the host is told it is hosting: the pause box line shows while its party is in its raid, and closing the host window asks first',
   run:function(){
     var el=document.getElementById('pausehost');
     if(!el||typeof netHostHolds!=='function') return 'this build never tells the host it is hosting';
     if(String(el.textContent).indexOf('YOU ARE HOSTING')!==0||String(el.textContent).indexOf('ends the raid for your whole party')<0) return 'the hosting line reads: '+el.textContent;
     var keep={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed}, kG=G, a, b, c, ev={returnValue:null,prevented:0,preventDefault:function(){ this.prevented=1; }};
     try{
       G={sim:false,over:false}; NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}]; NET.upSeed=77;
       a=netHostHolds();
       NET.peers=[]; b=netHostHolds();
       NET.peers=[{state:'in',seat:1}]; NET.role='join'; c=netHostHolds();
     } finally { G=kG; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.upSeed=keep.upSeed; }
     if(!a) return 'a host with its party in its raid does not read as holding the party';
     if(b||c) return 'a host with nobody linked, or a teammate, reads as holding the party';
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("window.addEventListener('beforeunload',function(e){ if(netHostHolds())")<0) return 'closing the host window does not ask first';
     if(src.indexOf("_hw.style.display=netHostHolds()?'':'none'")<0) return 'the pause box never shows the hosting line';
     return null; }},
  {v:'16.37',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
