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

if ($s.Contains("  {v:'16.40',what:")) { throw "check 16.40 is in the fixture already" }

SubRx @'
  {v:'16.39',what:
'@ @'
  {v:'16.40',what:'end of raid party summary: each result reaches the party, and the run card lists every player with how it ended, kills and haul',
   run:function(){
     if(typeof netSumTake!=='function'||typeof netSumDraw!=='function'||!document.getElementById('oc_party')) return 'this build has no party summary';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,roster:NET.roster,sum:NET.sum,peers:NET.peers}, el=document.getElementById('oc_party'), bad=[], t, r;
     try{
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'}]; NET.sum={};
       NET.sum[1]={how:'dead',k:0,v:0};
       r=netSumTake({state:'in'},{t:'sum',how:'extract',k:3,v:1240});
       t=String(el.textContent);
       if(r!=='sum') bad.push('the host result was not taken ('+r+')');
       if(t.indexOf('YOUR PARTY')<0||t.indexOf('KITE')<0||t.indexOf('EXTRACTED')<0||t.indexOf('3 kills')<0||t.indexOf('1,240c')<0) bad.push('the card does not show the host out with 3 kills and 1,240c: '+t);
       if(t.indexOf('YOU')<0||t.indexOf('KILLED')<0) bad.push('the card does not show this player killed: '+t);
       NET.sum={}; netSumDraw(); t=String(el.textContent);
       if(t.indexOf('STILL UP TOP')<0) bad.push('a player with no result is not shown still up top: '+t);
       NET.on=false; netSumDraw();
       if(el.style.display!=='none') bad.push('the summary shows outside a party');
     } finally { NET.on=keep.on; NET.role=keep.role; NET.seat=keep.seat; NET.roster=keep.roster; NET.sum=keep.sum; NET.peers=keep.peers; el.style.display='none'; el.innerHTML=''; }
     return bad.length?bad.join('; '):null; }},
  {v:'16.39',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
