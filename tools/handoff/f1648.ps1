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

if ($s.Contains("  {v:'16.48',what:")) { throw "check 16.48 is in the fixture already" }

SubRx @'
  {v:'16.47',what:
'@ @'
  {v:'16.48',what:'the kit wait never starts a raid from inside a raid: when its timer runs out after the host already went up another way nothing happens, and on the Undercroft floor it still sends the party up',
   run:function(){
     if(typeof netKitGo!=='function') return 'SKIP: this build has no kit wait';
     var keep={on:NET.on,role:NET.role,status:NET.status}, kS=state, oRef=netRefresh, went=0, bad=[];
     try{
       netRefresh=function(){};
       NET.on=true; NET.role='host';
       state='raid'; NET.kitWait={f:function(){ went++; },need:1,got:0,tm:0};
       netKitGo();
       if(went) bad.push('the kit wait ran out with the host already up top and started a second raid');
       if(NET.kitWait) bad.push('the kit wait was left standing up top');
       state='hub'; went=0; NET.kitWait={f:function(){ went++; },need:1,got:0,tm:0};
       netKitGo();
       if(went!==1) bad.push('control: on the Undercroft floor the kit wait no longer sends the party up');
     } finally { netRefresh=oRef; NET.on=keep.on; NET.role=keep.role; NET.status=keep.status; NET.kitWait=null; state=kS; }
     return bad.length?bad.join('; '):null; }},
  {v:'16.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
