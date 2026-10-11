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

if ($s.Contains("  {v:'23.33',what:")) { throw "check 23.33 is in the fixture already" }

SubRx @'
  {v:'23.32',what:
'@ @'
  {v:'23.33',what:'arcade11, his order 2026-10-11: walk-over loot, a box in reach is searched with no key and fast, a valuable scores into the pot and never enters the backpack',
   run:function(){
     var bad=[], g, p, ct=null, offs=[[20,0],[-20,0],[0,20],[0,-20]], i, f, t0, nb0, nb1, pot0, mine0, rows=[], realSay=null, own=false, tagd=false,
         nBand=function(){ var n=0,j; for(j=0;j<g.bag.length;j++) if(g.bag[j]==='bandage') n++; return n; };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       ARCADE.holdT=0; keys={};
       for(i=0;i<offs.length&&!ct;i++) if(losClear(p.x,p.y,p.x+offs[i][0],p.y+offs[i][1],g.vseg)) ct=mkContainer(p.x+offs[i][0],p.y+offs[i][1],'crate');
       if(!ct) return 'SKIP: no clear spot 20 units from the arcade drop';
       ct.loot=['scrap','bandage']; ct.best=bestRarity(ct.loot); ct.pulled=0; ct.prog=0; ct.opened=false;
       g.containers.push(ct);
       nb0=nBand(); pot0=ARCADE.pot|0; mine0=ARCADE.mine|0;
       realSay=say; own=true;
       say=function(m,l,o){ rows.push({m:String(m),l:l,tag:(o&&o.tag)||''}); };
       t0=performance.now();
       for(f=0;f<40;f++) __loop(t0+f*16.7);
       say=realSay; own=false;
       if(__state()!==g||g.over) return 'the arcade raid ended during the 40 frames';
       if(!ct.opened) bad.push('a crate 20 units away was not searched with no key in 40 frames (prog '+(+ct.prog||0).toFixed(3)+' of '+ct.time+', loot left '+ct.loot.length+')');
       if(g.bag.indexOf('scrap')>=0) bad.push('Scrap Metal went into the backpack');
       nb1=nBand();
       if(nb1!==nb0+1) bad.push('the bandage count went '+nb0+' to '+nb1+', not +1');
       if(!((ARCADE.pot|0)>pot0)) bad.push('the pot did not rise ('+pot0+' to '+ARCADE.pot+')');
       if((ARCADE.mine|0)-mine0!==(ARCADE.pot|0)-pot0) bad.push('the score rose '+((ARCADE.mine|0)-mine0)+' but the pot '+((ARCADE.pot|0)-pot0));
       for(i=0;i<rows.length;i++) if(rows[i].m===ITEMS.scrap.name&&rows[i].l==='pick'&&rows[i].tag.charAt(0)==='+') tagd=true;
       if(ct.opened&&!tagd) bad.push('the Scrap Metal pickup row has no +N tag');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&realSay){ try{ say=realSay; }catch(_rs){} }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
