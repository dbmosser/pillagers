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

SubRx @'
  {v:'15.19',what:
'@ @'
  {v:'15.20',what:'a hire who got out before you is not called left behind: he extracted on his own, you died, and his line on the outcome card says he made it out on his own with no cut, and no cut is paid (hire audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__identityIds)) return 'SKIP: this fixture cannot hire, deploy and end a raid';
     if(typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: no pillager identities in this build';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: this build has no outcome card in the page';
     var bad=[], snap=null, g=null, i;
     var LEFT='left out '+'there', OWN='out on his '+'own';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var ids=__identityIds(); if(!ids.length) return 'SKIP: no identity to hire';
       var tag='';
       for(i=0;i<IDENTITIES.length;i++) if(IDENTITIES[i].id===ids[0]) tag=String(IDENTITIES[i].tag||'');
       if(!tag) return 'SKIP: the first identity has no name to read on the card';
       __P().merc=ids[0];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       var M=null, row=null;
       for(i=0;i<g.ents.length;i++) if(g.ents[i].merc){ M=g.ents[i]; break; }
       for(i=0;i<(g.roster||[]).length;i++) if(g.roster[i].ref&&g.roster[i].ref.merc){ row=g.roster[i]; break; }
       // CONTROL: the hire came up with you and has the roster row his extraction stamps.
       if(!M||!row||row.ref!==M) return 'SKIP: the hire did not come up with a roster row on this seed';
       // He ran low, fled and extracted: his extraction stamps the row out with his haul and takes him off the map. Then you die.
       row.out=true; row.outAt=0; row.val=4321;
       g.ents.splice(g.ents.indexOf(M),1); g.mercDead=0;
       if(g.ents.indexOf(M)>=0) return 'SKIP: the hire could not be taken off the map here';
       var c0=__P().credits;
       man.innerHTML='';
       __endRaid('dead');
       // CONTROL: the raid ended as a death, the card was drawn and the hire contract was settled.
       if(g.over!=='dead'||!oc.classList.contains('on')||!String(man.textContent||'').length) return 'SKIP: the death card was not drawn here';
       if(__P().merc) return 'SKIP: the hire contract was not settled at the end of this raid';
       // His line is its own span and starts with his name. The hit list drawn above the lines comes first, so the last such span is his.
       var sp=man.querySelectorAll('span'), hl='';
       for(i=0;i<sp.length;i++){ var st=String(sp[i].textContent||''); if(st.indexOf(tag)===0) hl=st; }
       // CONTROL: the card carries a line for the hire, and it is not the death benefit line.
       if(!hl) return 'SKIP: the card carries no line for the hire here';
       if(hl.indexOf(' died.')>=0) return 'SKIP: the card read the hire as killed here ('+hl.slice(0,80)+')';
       if(hl.indexOf(LEFT)>=0) bad.push('your hire extracted on his own before you died, and the card says: '+hl.slice(0,90));
       else if(hl.indexOf(OWN)<0) bad.push('the card line for a hire who got out before you does not say he made it out on his own: '+hl.slice(0,90));
       if(__P().credits-c0===432) bad.push('a death paid the ten percent cut of the 4,321 your hire carried out, though the cut needs you both out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
