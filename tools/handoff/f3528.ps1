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

if ($s.Contains("  {v:'35.28',what:")) { throw "check 35.28 is in the fixture already" }

SubRx @'
  {v:'35.27',what:
'@ @'
  {v:'35.28',what:'cw-wheeldrophint: while an item picked up off the wheel is held, the hint over the wheel says drop on a key, not release to take out',
   run:function(){
     var bad=[], g, p, w, m, bi, an, pt, has;
     function idx(k2){ var q; for(q=0;q<w.list.length;q++) if(w.list[q].k===k2) return q; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','frag'],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; G.bagOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       g=G; p=g.player; keys={}; mouse.down=false; p.hand=null; g.drag=null; g.wheel=null;
       has=function(rx){ return pt.some(function(h){ return rx.test(String(h.t)); }); };
       mouse.x=W/2; mouse.y=H/2; keys.KeyQ=true; raidKey('KeyQ',false,null); w=g.wheel;
       if(!w) throw new Error('Q opened no wheel');
       m=w.list.length; bi=idx('bandage'); if(bi<0) throw new Error('no bandage slot on the wheel');
       an=-Math.PI/2+bi*(Math.PI*2/m); mouse.x=w.mx+Math.cos(an)*220; mouse.y=w.my+Math.sin(an)*220; updatePlayer(0.016);
       pt=txRecord(function(){ __drawHUD(); });
       if(!has(/release to take out/i)) bad.push('control: the open wheel does not say release to take out');
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
       if(!g.drag||!g.drag.fromWheel) throw new Error('staging: a press on the bandage picked nothing up');
       updatePlayer(0.016);
       pt=txRecord(function(){ __drawHUD(); });
       if(!has(/drop on a key/i)) bad.push('the held item does not say drop on a key');
       if(has(/release to take out/i)) bad.push('the held item still says release to take out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(G){ G.drag=null; G.wheel=null; if(G.player) G.player.hand=null; } mouse.down=false; }catch(_d){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
