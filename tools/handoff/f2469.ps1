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

if ($s.Contains("  {v:'24.69',what:")) { throw "check 24.69 is in the fixture already" }

SubRx @'
  {v:'24.68',what:
'@ @'
  {v:'24.69',what:'feat4c, his order 2026-10-12 (32 more interiors): a keycard per vault in a box outside, an elite kill drops one, VAULT OPEN pays 500',
   run:function(){
     var bad=[], g, p, V, L, i, j, c, nk, kc, m0, e, before, rows=[], realSay=null, own=false,
         kboxes=function(gg){ return gg.containers.filter(function(cc){ return cc&&cc.loot&&cc.loot.indexOf('keycard')>=0; }); };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!ITEMS.keycard) return 'no Vault Keycard item';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player; if(typeof arcadeShieldOff==='function') arcadeShieldOff(); ARCADE.holdT=0;
       L=g.map.locked||[]; V=L.filter(function(R){ return R.arc; });
       if(!V.length) return 'SKIP: no vaults in this DEMO raid';
       kc=kboxes(g); nk=kc.length;
       if(nk<V.length) bad.push(nk+' boxes hold a keycard for '+V.length+' vaults');
       for(i=0;i<kc.length;i++){ c=kc[i];
         for(j=0;j<L.length;j++) if(c.x>L[j].x&&c.x<L[j].x+L[j].w&&c.y>L[j].y&&c.y<L[j].y+L[j].h) bad.push('a keycard box stands inside '+L[j].name);
         if(c.cache||c.strong) bad.push('a keycard went into a cache or strongbox'); }
       // a plain kill with keycards out drops nothing; an elite kill drops a KEYCARD box
       realSay=say; own=true; say=function(mm,l,o){ rows.push(String(mm)); };
       before=kboxes(g).length;
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e); G.arcKillN=0; __ents(0.016);
       if(g.ents.indexOf(e)>=0) bad.push('the plain crawler did not die');
       if(kboxes(g).length!==before) bad.push('a plain first kill dropped a keycard while keycards are out');
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=1; e.hp=0; g.ents.push(e); __ents(0.016);
       if(g.ents.indexOf(e)>=0) bad.push('the elite crawler did not die');
       if(kboxes(g).length!==before+1) bad.push('an elite kill left '+(kboxes(g).length-before)+' new keycard boxes, not 1');
       if(rows.indexOf('KEYCARD DROPPED')<0) bad.push('no KEYCARD DROPPED callout ('+rows.join(' | ')+')');
       say=realSay; own=false;
       // opening a vault pays 500
       L=V[0]; p.x=L.doorX; p.y=L.doorY; p.downed=false; g.searching=null;
       g.bag=g.bag.filter(function(b){ return !(ITEMS[b]&&ITEMS[b].use==='key'); }); g.bag.push('keycard');
       m0=ARCADE.mine|0;
       keys={}; keys.KeyE=true; __sim(0.05); keys={};
       if(!L.open) bad.push('the keycard did not open '+L.name);
       else if((ARCADE.mine|0)-m0<500) bad.push('opening '+L.name+' raised the score by '+((ARCADE.mine|0)-m0)+', not 500');
       // a plain raid: no keycards anywhere
       keys={}; try{ if(ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(g&&!g.over&&kboxes(g).length) bad.push('a plain raid has '+kboxes(g).length+' keycard boxes');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&realSay){ try{ say=realSay; }catch(_rs){} }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
