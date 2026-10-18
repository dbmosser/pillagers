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

if ($s.Contains("  {v:'30.69',what:")) { throw "check 30.69 is in the fixture already" }

SubRx @'
  {v:'30.68',what:
'@ @'
  {v:'30.69',what:'in the party arcade demo both windows call the two seats Player 1 and Player 2 whatever the saves are named (his order of 2026-10-18: p1 and p2 should look and behave the same), so a name over a teammate head, on the team bar and in the feed agree; outside the arcade the roster names stand as they were; a seat outside the party is still nobody',
   run:function(){
     if(typeof netSeatName!=='function'||typeof ARCADE==='undefined'||!ARCADE||typeof NET==='undefined'||!NET) return 'SKIP: this build has no seat names or no party arcade';
     var keep={roster:NET.roster,on:ARCADE.on,solo:ARCADE.solo}, bad=[], a, b, c, d;
     try{
       NET.roster=[{seat:0,name:'ZQX HOST'},{seat:1,name:'ZQX GUEST'},{seat:2,name:'ZQX THIRD'}];
       ARCADE.on=0; ARCADE.solo=0;
       if(netSeatName(0)!=='ZQX HOST'||netSeatName(1)!=='ZQX GUEST'||netSeatName(2)!=='ZQX THIRD') bad.push('control: outside the arcade the roster names do not stand ('+netSeatName(0)+', '+netSeatName(1)+', '+netSeatName(2)+')');
       ARCADE.on=1;
       a=netSeatName(0); b=netSeatName(1); c=netSeatName(2); d=netSeatName(5);
       if(String(a).toLowerCase()!=='player 1') bad.push('in the party arcade seat 0 is called '+a+', not Player 1');
       if(String(b).toLowerCase()!=='player 2') bad.push('in the party arcade seat 1 is called '+b+', not Player 2');
       if(c!=='ZQX THIRD') bad.push('in the party arcade a third seat lost its roster name ('+c+')');
       if(d!==null) bad.push('a seat outside the party has a name: '+d);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ NET.roster=keep.roster; ARCADE.on=keep.on; ARCADE.solo=keep.solo; }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'30.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
