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

if ($s.Contains("  {v:'16.35',what:")) { throw "check 16.35 is in the fixture already" }

SubRx @'
  {v:'16.34',what:
'@ @'
  {v:'16.35',what:'his controller rule: player 2 takes the first controller and a second controller goes to player 1, who otherwise plays keyboard and mouse',
   run:function(){
     if(typeof netPadFor!=='function'||typeof netPadWant!=='function'||typeof NET==='undefined') return 'SKIP: this build has no same machine controllers';
     function pd(ix){ return {connected:true,index:ix,id:'probe',buttons:[],axes:[]}; }
     var two=[pd(0),pd(1)], one=[pd(0)], bad=[], keep=NET.same, keepIx=NET.padIx;
     if(netPadFor('p2',-1,-1,two)!==0) bad.push('player 2 with no pick is not on the first controller ('+netPadFor('p2',-1,-1,two)+')');
     if(netPadFor('host',-1,-1,two)!==1) bad.push('player 1 with no pick is not on the second controller ('+netPadFor('host',-1,-1,two)+')');
     if(netPadFor('host',-1,-1,one)!==-1) bad.push('with one controller player 1 took it from player 2');
     if(netPadFor('host',-1,1,two)!==0) bad.push('with player 2 on controller 2 by pick, player 1 is not on controller 1');
     if(netPadFor('host',1,-1,two)!==1) bad.push('a player 1 pick is not kept');
     try{ NET.same='host'; NET.padIx=-1; if(netPadWant()!==-2) bad.push('player 1 with no pick takes no controller handed over ('+netPadWant()+')'); }
     finally{ NET.same=keep; NET.padIx=keepIx; }
     return bad.length?bad.join('; '):null; }},
  {v:'16.34',what:
'@


SubRx @'
       if(PAD.on) bad.push('the host with no controller picked plays a pad (buttons down '+downs()+')');
'@ @'
       if(!PAD.on||!PAD.prev[0]||PAD.prev[3]) bad.push('the host with no controller picked does not play the second controller, his rule of 2026-09-27 (buttons down '+downs()+')');   // v16.35
'@

SubRx @'
       if(keys.KeyF||keys.KeyE) bad.push('the host with no controller picked holds a key from a pad (F '+!!keys.KeyF+', E '+!!keys.KeyE+')');
'@ @'
       if(keys.KeyF) bad.push('the host with no controller picked holds a key from the player 2 pad (F '+!!keys.KeyF+')');   // v16.35
'@

SubRx @'
       if(netSameOnMsg(fwd(0,1,[2]))!=='padnone') bad.push('the host with no pick took a state handed over');
'@ @'
       if(netSameOnMsg(fwd(0,1,[2]))!=='pad') bad.push('the host with no pick refused the second controller player 2 handed over');   // v16.35
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
