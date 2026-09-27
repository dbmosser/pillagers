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

if ($s.Contains("  {v:'16.62',what:")) { throw "check 16.62 is in the fixture already" }

SubRx @'
  {v:'16.61',what:
'@ @'
  {v:'16.62',what:'on a linked window a downed pillager copy run by the host is not offered for pick up, while a downed pillager of its own still is',
   run:function(){
     if(typeof updatePlayer!=='function'||typeof netEntMake!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no body copies';
     var bad=[], cp=null, loc=null, k0=null;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       k0=keys; keys={};
       cp=netEntMake(990001,'raider',G.player.x+20,G.player.y); cp.downed=1;
       G.ents.push(cp); G.nearDown=null; updatePlayer(0.016);
       if(G.nearDown===cp) bad.push('a downed pillager copy the host runs is offered for pick up on this window');
       G.ents.splice(G.ents.indexOf(cp),1);
       loc=netEntMake(990002,'raider',G.player.x+20,G.player.y); loc.downed=1; delete loc.net;
       G.ents.push(loc); G.nearDown=null; updatePlayer(0.016);
       if(G.nearDown!==loc) return 'SKIP: staging: a downed pillager of this window was not offered either, so the scan did not run';
       G.ents.splice(G.ents.indexOf(loc),1);
     } finally { try{ if(k0) keys=k0; if(G&&G.ents){ if(cp&&G.ents.indexOf(cp)>=0) G.ents.splice(G.ents.indexOf(cp),1); if(loc&&G.ents.indexOf(loc)>=0) G.ents.splice(G.ents.indexOf(loc),1); G.nearDown=null; } __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
