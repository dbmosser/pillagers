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

if ($s.Contains("  {v:'26.97',what:")) { throw "check 26.97 is in the fixture already" }

SubRx @'
  {v:'26.96',what:
'@ @'
  {v:'26.97',what:'career2, his yes to the armory codex (30): a gun is filed once it has been held, the page lists every gun with its rarity and NOT FOUND for the unseen, the raid scan files a gun in the backpack, an old save loads, and the page closes on CLOSE and on ESC',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof codexNote!=='function'||typeof codexOpen!=='function') return 'there is no armory codex in this build';
     var bad=[], snap=null, g=null, i, L, tiles, no, yes, t, m, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, srcs, hooked=false, q;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); delete q.codex; delete q.codexSeen;
       // ONE: filing, and what is not a gun
       if(codexNote('fists')||codexNote('nosuchgun')||codexNote('')) bad.push('ONE: a non-gun was filed');
       if(!codexNote('rifle')) bad.push('ONE: the rifle was not filed');
       if(codexNote('rifle')) bad.push('ONE: the rifle was filed twice');
       if(!codexHas('rifle')||codexHas('lmg')) bad.push('ONE: codexHas is wrong');
       // TWO: the stash scan files the armoury, the stash and the backpack
       q.weapons=['pistol','smg']; q.stash=['gun_magnum','scrap']; q.kit=['gun_lmg_v'];
       codexScan();
       if(!codexHas('pistol')||!codexHas('smg')||!codexHas('magnum')||!codexHas('lmg_v')) bad.push('TWO: the stash scan missed a gun ('+Object.keys(q.codex).join(',')+')');
       if(codexHas('scrap')) bad.push('TWO: scrap was filed');
       // THREE: the page lists every gun, found and not found
       L=codexGuns();
       if(L.length<19) bad.push('THREE: the codex lists '+L.length+' guns, not every one');
       renderCodex();
       tiles=document.querySelectorAll('#codexgrid .cxt'); no=document.querySelectorAll('#codexgrid .cxt.no'); yes=document.querySelectorAll('#codexgrid .cxt.yes');
       if(tiles.length!==L.length) bad.push('THREE: '+tiles.length+' tiles for '+L.length+' guns');
       if(yes.length!==codexFound()) bad.push('THREE: '+yes.length+' found tiles for '+codexFound()+' found');
       for(i=0;i<no.length;i++){ t=no[i].textContent; if(t.indexOf('NOT FOUND')<0) bad.push('THREE: an unfound tile does not say NOT FOUND'); if(t.indexOf(WEAPONS[no[i].getAttribute('data-gun')].name)>=0){ bad.push('THREE: an unfound tile names its gun'); break; } }
       if(tiles.length&&!/COMMON|UNCOMMON|RARE|ELITE|GOLD/.test(tiles[tiles.length-1].textContent)) bad.push('THREE: a tile does not carry its rarity');
       // FOUR: the button on the stash, and the page opens and closes on CLOSE and ESC
       renderHub();
       t=document.getElementById('codexbtn');
       if(!t||t.textContent.indexOf('ARMORY')<0) bad.push('FOUR: no ARMORY button on the stash');
       else {
         t.onclick();
         m=document.getElementById('codexmodal');
         if(!m||!m.classList.contains('on')) bad.push('FOUR: the button did not open the page');
         else {
           if(!document.getElementById('closecodex')) bad.push('FOUR: the page has no CLOSE');
           if(!backOut()||m.classList.contains('on')) bad.push('FOUR: ESC did not close the page');
           t=document.getElementById('codexbtn');
           if(t){ t.onclick(); if(!m.classList.contains('on')) bad.push('FOUR: the page did not open again'); document.getElementById('closecodex').click(); if(m.classList.contains('on')) bad.push('FOUR: CLOSE did not close the page'); }
         }
       }
       // FIVE: a gun in the raid backpack is filed by the raid scan
       delete q.codex; q.kit=[]; q.stash=[]; q.weapons=['pistol'];
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.bag.push('gun_dmr'); g.cxT=0;
       careerTick(0.016);
       if(!codexHas('dmr')) bad.push('FIVE: the raid scan missed a Marksman Rifle in the backpack');
       if(!codexHas(g.player.wep.id)) bad.push('FIVE: the raid scan missed the gun in his hands');
       g.bag.push('gun_whisper'); careerTick(0.5);
       if(codexHas('whisper')) bad.push('FIVE: the scan ran twice inside a second');
       // SIX: the main loop calls the tick, and an old save with no codex loads
       srcs=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       hooked=srcs.indexOf('careerTick'+'(dt)')>=0;
       if(!hooked) bad.push('SIX: the raid loop does not call careerTick');
       __endRaid('abandon'); __topClear();
       delete q.codex; delete q.codexSeen;
       try{ renderHub(); renderCodex(); }catch(ex){ bad.push('SIX: an old save with no codex threw: '+(ex&&ex.message||ex)); }
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ CAREER_ON=c0; }catch(_c0){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ var mm=document.getElementById('codexmodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
