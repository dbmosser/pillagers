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

if ($s.Contains("  {v:'36.00',what:")) { throw "check 36.00 is in the fixture already" }

SubRx @'
  {v:'35.99',what:
'@ @'
  {v:'36.00',what:'menus master pass 2026-10-28: the KIA card with a full hit history (8 rows, the most HOW IT WENT shows) fits his 4K card (840 layout px) without scrolling: HOW IT WENT and DAMAGE TAKEN rows at line height 1.4, and on the KIA card the lost money and lost item tiles sit closer; it ran 71px over, so the how did that run feel button sat under the log run button',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, man, k, win, rows, i, fs, lh, fb, wb, ab, HL=[], S=[['CRAWLER','CLAWS',12],['SENTRY','AUTOCANNON',14],['RUSTY VANCE','AUTO RIFLE',11],['BULWARK','SHOTGUN',10]], hp=100;
     for(i=0;i<10;i++){ hp=(i<9)?Math.max(0,hp-S[i%4][2]):0; HL.push({t:30+i*14,n:S[i%4][0],w:S[i%4][1],a:S[i%4][2],hp:hp}); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(typeof CAREER_ON==='number') CAREER_ON=0;
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       if(g.tel) g.tel.hitLog=JSON.parse(JSON.stringify(HL));
       __endRaid('dead');
       man=document.getElementById('oc_manifest'); k=man&&man.querySelector('.ockia');
       win=man&&man.closest('.ocwin');
       if(!k||!win) return 'the KIA card has no side by side tables ('+[!!k,!!win].join(',')+')';
       rows=[].slice.call(k.children[0].children,2);
       if(rows.length!==8) bad.push('HOW IT WENT lists '+rows.length+' hits, not the 8 it keeps');
       for(i=0;i<rows.length;i++){ fs=parseFloat(getComputedStyle(rows[i]).fontSize); lh=rows[i].offsetHeight; if(lh>fs*1.4+2.5){ bad.push('HOW IT WENT row '+(i+1)+' is '+lh+'px tall at '+fs+'px type (over 1.4 plus 2)'); break; } }
       win.style.setProperty('max-height','840px','important');
       if(win.scrollHeight>win.clientHeight+1) bad.push('at his 4K card height (840) the KIA card with 8 hits scrolls '+(win.scrollHeight-win.clientHeight)+'px');
       fb=win.querySelector('.fbhead'); ab=win.querySelector('.ocacts');
       if(fb&&ab){ wb=fb.getBoundingClientRect(); if(wb.bottom>ab.getBoundingClientRect().top+1) bad.push('the how did that run feel button sits under the log run button'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(win) win.style.removeProperty('max-height'); }catch(_w){}
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ if(typeof CAREER_ON==='number') CAREER_ON=c0; }catch(_c){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
