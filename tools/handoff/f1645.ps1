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

if ($s.Contains("  {v:'16.45',what:")) { throw "check 16.45 is in the fixture already" }

SubRx @'
  {v:'16.44',what:
'@ @'
  {v:'16.45',what:'settings in a raid: the pause box opens Settings, and a raid length change moves the running clock at once',
   run:function(){
     var b=document.getElementById('pausesetbtn');
     if(!b||typeof gameOptRaidNow!=='function') return 'the pause box has no way into Settings';
     var kG=G, kS=CFG.raidSec, kNet=NET.on, r, bad=[], oSay=say;
     try{
       say=function(){};
       NET.on=false;
       G={over:false,sim:false,raidLen:540,timeLeft:440,t:100};
       CFG.raidSec=900; r=gameOptRaidNow(540);
       if(!r||G.raidLen!==900||Math.abs(G.timeLeft-800)>1) bad.push('540 to 900 with 100 s played left '+G.timeLeft+' of '+G.raidLen);
       G={over:false,sim:false,raidLen:540,timeLeft:100,t:440};
       CFG.raidSec=360; gameOptRaidNow(540);
       if(G.timeLeft!==30) bad.push('shortening past the time played left '+G.timeLeft+' s, not the 30 s floor');
     } finally { G=kG; CFG.raidSec=kS; NET.on=kNet; say=oSay; }
     try{ b.click(); var m=document.getElementById('settingsmodal'); if(!m||!m.classList.contains('on')) bad.push('the Settings button did not open Settings'); if(m) m.classList.remove('on'); }catch(e){ bad.push('the Settings button threw '+e.message); }
     return bad.length?bad.join('; '):null; }},
  {v:'16.44',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
