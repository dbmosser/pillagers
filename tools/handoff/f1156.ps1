$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.56 CHECK, inserted before the v11.55 entry.
SubRx @'
  {v:'11.55',what:'the XP printed on the outcome card is exactly the XP the profile banks for that run, with the weather (or night, or dose) multiplier in play',
'@ @'
  {v:'11.56',what:'reviving a pillager you downed clears the kill attribution on him, so a later death at other hands is not credited to you; the revive itself still stands him up friendly',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__sim&&window.__keys)) return 'SKIP: this fixture cannot revive a man';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, R=null, i, bad=[];
     for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.merc&&!e.finished){ R=e; break; } }
     if(!R) return 'SKIP: no pillager to down';
     // You downed him: the downing shot stamped byPlayer. He lies within reach.
     R.downed=1; R.byPlayer=true; R.hostile=true; R.friendlyPC=0; R.x=p.x+20; R.y=p.y;
     g.over=false; p.downed=false; g.revLock=0;
     var K=__keys(); for(var q in K) delete K[q]; K['KeyE']=true;
     try{ __sim(0.15); }catch(e2){ bad.push('the step threw: '+String(e2&&e2.message||e2).slice(0,80)); }
     delete K['KeyE'];
     // CONTROL: the revive happened at all, or the flag reading proves nothing.
     if(!(R.downed===0&&R.friendlyPC===1)) bad.push('control: E next to the downed man did not revive him (downed '+R.downed+', friendlyPC '+R.friendlyPC+')');
     // THE FIX: his next death is no longer yours.
     else if(R.byPlayer) bad.push('the revived man still carries byPlayer, so a crawler killing him later would be your kill, your contract tick and a grudge');
     __topClear(); __cleanProfile();
     return bad.length?bad.join('; '):null; }},
  {v:'11.55',what:'the XP printed on the outcome card is exactly the XP the profile banks for that run, with the weather (or night, or dose) multiplier in play',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
