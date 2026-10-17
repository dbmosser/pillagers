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

if ($s.Contains("  {v:'28.81',what:")) { throw "check 28.81 is in the fixture already" }

SubRx @'
  {v:'28.80',what:
'@ @'
  {v:'28.81',what:'cw-feedsp: score is SP since lean2, and the feed still treats an SP figure as a figure: a medal label " +100 SP" is no line of its own, a kill popup "+50 SP" joins the kill line, a "+70 SP" pick is a money row',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof feedLabel!=='function') return 'SKIP: no arcade or feed here';
     var bad=[], g=null, rs=say, n0, r, kl, ml;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       say=function(){};
       feedS(); n0=g.fd.lines.length;
       r=feedLabel(' +100'+' SP','#ffc04a');
       if(r||g.fd.lines.length!==n0) bad.push('a medal figure label made a line of its own ('+(g.fd.lines.length-n0)+' new)');
       kl=feedKillLine('YOU',true,false,'SCAV',HUDC.danger,' DESTROYED'); n0=g.fd.lines.length;
       r=feedLabel('+50'+' SP','#ffc04a');
       if(!kl||g.fd.lines.length!==n0||kl.money!=='+50'+' SP') bad.push('a kill popup +50 SP did not join the kill line (money '+(kl&&kl.money)+', lines '+(g.fd.lines.length-n0)+' new)');
       ml=feedSay('+70'+' SP','pick',{});
       if(!ml||ml.fk!=='money') bad.push('a +70 SP pick is not a money row ('+(ml&&ml.fk)+')');
       return bad.length?bad.join('; '):null;
     } finally {
       say=rs;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     } }},
  {v:'28.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
