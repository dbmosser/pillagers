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

if ($s.Contains("  {v:'24.62',what:")) { throw "check 24.62 is in the fixture already" }

SubRx @'
  {v:'24.61',what:
'@ @'
  {v:'24.62',what:'feat4a, his order 2026-10-12 (32 more interiors): the Vault Keycard opens any locked room in DEMO and nothing but a vault door elsewhere',
   run:function(){
     var bad=[], g, p, R, n0, stand=function(gg,RR){ var pp=gg.player; pp.x=RR.doorX; pp.y=RR.doorY; pp.downed=false; pp.dying=false; gg.searching=null; keys={}; keys.KeyE=true; __sim(0.05); keys={}; },
         cnt=function(gg,k){ var n=0,j; for(j=0;j<gg.bag.length;j++) if(gg.bag[j]===k) n++; return n; },
         room=function(gg){ var j,L=(gg.map&&gg.map.locked)||[]; for(j=0;j<L.length;j++) if(L[j].id==='cs_freezer') return L[j]; return null; };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!ITEMS.keycard) return 'no Vault Keycard item';
       if(typeof keyFits!=='function') return 'no keyFits';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player; if(typeof arcadeShieldOff==='function') arcadeShieldOff(); ARCADE.holdT=0;
       R=room(g); if(!R) return 'SKIP: no cs_freezer room on the arcade map';
       if(R.open) return 'SKIP: cs_freezer starts open';
       g.bag=g.bag.filter(function(b){ return !(ITEMS[b]&&ITEMS[b].use==='key'); });
       g.bag.push('keycard');
       stand(g,R);
       if(!R.open) bad.push('DEMO: a Vault Keycard at the BLAST FREEZER door did not open it');
       if(cnt(g,'keycard')!==0) bad.push('DEMO: the keycard was not spent');
       if(!keyFits(ITEMS.keycard,{id:'zz',arc:0})) bad.push('DEMO: keyFits says a keycard does not fit a plain door');
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over||g.arcade) return bad.concat(['SKIP: no plain raid']).join('; ');
       R=room(g); if(!R) return bad.concat(['SKIP: no cs_freezer room in a plain raid']).join('; ');
       g.bag=g.bag.filter(function(b){ return !(ITEMS[b]&&ITEMS[b].use==='key'); });
       g.bag.push('keycard');
       stand(g,R);
       if(R.open) bad.push('a plain raid: the keycard opened the BLAST FREEZER');
       if(cnt(g,'keycard')!==1) bad.push('a plain raid: the keycard was spent on a map door');
       if(!keyFits(ITEMS.keycard,{id:'zz',arc:1})) bad.push('a plain raid: keyFits says a keycard does not fit a vault door');
       if(!R.open){
         g.bag.push('key_cs_freezer');
         stand(g,R);
         if(!R.open) bad.push('a plain raid: key_cs_freezer no longer opens its door');
         if(cnt(g,'key_cs_freezer')!==0) bad.push('a plain raid: the freezer key was not spent');
         if(cnt(g,'keycard')!==1) bad.push('a plain raid: the keycard was spent beside the freezer key');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
