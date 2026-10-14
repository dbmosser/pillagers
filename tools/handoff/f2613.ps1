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

if ($s.Contains("  {v:'26.13',what:")) { throw "check 26.13 is in the fixture already" }

SubRx @'
  {v:'26.12',what:
'@ @'
  {v:'26.13',what:'the self-revive says so on screen: SELF-REVIVE USED with Back on your feet as the detail, and a second one is refused with its own line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof selfRevive!=='function') return 'SKIP: no self-revive here';
     var bad=[], g=null, p=null, said=[], realSay=say, up;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false;
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)||''}); return realSay.apply(this,arguments); };
       p.downed=true; p.revived=false; said.length=0;
       selfRevive();
       if(!said.some(function(l){ return l.m==='SELF-REVIVE USED'; })) bad.push('the self-revive said nothing on screen ('+JSON.stringify(said.map(function(l){ return l.m; }))+')');
       else if(!said.some(function(l){ return l.m==='SELF-REVIVE USED'&&l.sub==='Back on your feet.'; })) bad.push('the self-revive line has no detail');
       if(p.downed||!p.revived) bad.push('the self-revive did not get him up');
       p.downed=true; said.length=0; up=selfRevive();
       if(up) bad.push('control: a second self-revive in one raid worked');
       if(!said.some(function(l){ return l.m.indexOf('Self-revive spent')===0; })) bad.push('control: the spent self-revive is not refused with its own line');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
