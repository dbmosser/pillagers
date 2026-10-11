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

if ($s.Contains("  {v:'23.35',what:")) { throw "check 23.35 is in the fixture already" }

SubRx @'
  {v:'23.34',what:
'@ @'
  {v:'23.35',what:'arcade13, his order 2026-10-11: the arcade HUD draws no CONDITIONS panel, no CURRENT PILLAGERS board and no notoriety stamp, keeps the EXTRACT compass, and counts DROPPING IN during the drop-in hold',
   run:function(){
     var bad=[], g, cx=null, ft=null, own=false, seen=[], i, hasE=false, hasD=false,
         nC='CONDI'+'TIONS', nB='CURRENT PIL'+'LAGERS', nE='EXTR'+'ACT', nD='DROPPING'+' IN', nN='NOTOR'+'IETY ';
     function trace(){
       var f; seen=[]; cx=hcv.getContext('2d'); ft=cx.fillText; own=true;
       cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
       try{ for(f=0;f<3;f++) __loop(performance.now()+f*16.7); if(!seen.length){ try{ drawHUD(); }catch(_dh){} } }
       finally{ delete cx.fillText; own=false; }
     }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={};
       ARCADE.banner=null; ARCADE.holdT=0; g.mapOpen=false; g.bagOpen=false;
       g.notoAt=g.t; g.notoN=1; g.notoWhy='X';
       trace();
       if(__state()!==g||g.over) return 'the arcade raid ended';
       if(!seen.length) return 'SKIP: the HUD drew no text';
       for(i=0;i<seen.length;i++){
         if(seen[i]===nC) bad.push('the arcade HUD draws the CONDITIONS panel');
         if(seen[i].indexOf(nB)>=0) bad.push('the arcade HUD draws the CURRENT PILLAGERS board');
         if(seen[i].indexOf(nN)===0) bad.push('the arcade HUD draws the notoriety stamp');
         if(seen[i].indexOf(nE)===0) hasE=true;
         if(seen[i].indexOf(nD)===0) bad.push('DROPPING IN is drawn with no hold running');
       }
       if(!hasE) bad.push('the arcade HUD lost the EXTRACT compass readout');
       if(HUDBOX.cond) bad.push('the CONDITIONS box is still laid out');
       if(HUDBOX.raiders) bad.push('the CURRENT PILLAGERS box is still laid out');
       g.notoAt=null;
       ARCADE.holdT=2;
       trace();
       for(i=0;i<seen.length;i++) if(seen[i].indexOf(nD)===0) hasD=true;
       if(!hasD) bad.push('no DROPPING IN countdown during the drop-in hold (holdT '+ARCADE.holdT+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&cx){ try{ delete cx.fillText; }catch(_df){} }
       keys={};
       try{ if(typeof ARCADE==='object') ARCADE.holdT=0; }catch(_h){}
       try{ if(g) g.notoAt=null; }catch(_n){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
