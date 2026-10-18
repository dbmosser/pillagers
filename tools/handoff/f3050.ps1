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

if ($s.Contains("  {v:'30.50',what:")) { throw "check 30.50 is in the fixture already" }

SubRx @'
  {v:'30.49',what:
'@ @'
  {v:'30.50',what:'his Q70: no tutorial prompt in the first demo raid; the controls card does not come up at the drop and the shield tag does not say MOVE TO START',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof arcadeCardOn!=='function'||typeof arcadeShieldRing!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g, seen=[], of, ownF=false;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; g.player.arcSh=1;
       if(arcadeCardOn()>0) bad.push('the controls card is up while the player is shielded at the drop ('+arcadeCardOn()+')');
       ownF=Object.prototype.hasOwnProperty.call(wc,'fillText'); of=wc.fillText;
       wc.fillText=function(t){ seen.push(String(t)); return of.apply(this,arguments); };
       arcadeShieldRing(g.player.x,g.player.y,true);
       if(seen.some(function(s){ return /MOVE TO/i.test(s); })) bad.push('the shield tag still says '+seen.join(' / '));
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(of){ if(ownF) wc.fillText=of; else delete wc.fillText; } }catch(_f){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
