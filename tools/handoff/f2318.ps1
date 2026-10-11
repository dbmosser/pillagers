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

if ($s.Contains("  {v:'23.18',what:")) { throw "check 23.18 is in the fixture already" }

SubRx @'
  {v:'23.17',what:
'@ @'
  {v:'23.18',what:'player 2 sees the kill number on his killing shot: on a linked window the kill is worked out from the damage sent, solo and the host read the health as before',
   run:function(){
     if(typeof hitKills!=='function') return 'control: no hitKills, the linked window reads health the host has not taken off yet';
     var bad=[], on0=NET.on, pe0=netEntsPeer;
     try{
       NET.on=false;
       if(hitKills({hp:5},23)) bad.push('solo: a body still on 5 health counts as killed');
       if(!hitKills({hp:0},23)) bad.push('solo: a body on 0 health does not count as killed');
       NET.on=true; netEntsPeer=function(){ return true; };
       if(!hitKills({hp:10},23)) bad.push('linked window: a 23 damage round into 10 health is not a kill');
       if(hitKills({hp:50},23)) bad.push('linked window: a 23 damage round into 50 health counts as a kill');
       var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd='_dn,_dc,hitKills'+'(en,edmg));';
       if(src.split(nd).length-1<2) bad.push('the damage number and the party copy do not both ask hitKills');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NET.on=on0; netEntsPeer=pe0; }
     return bad.length?bad.join('; '):null; }},
  {v:'23.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
