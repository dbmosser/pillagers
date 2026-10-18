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

if ($s.Contains("  {v:'29.04',what:")) { throw "check 29.04 is in the fixture already" }

SubRx @'
  {v:'29.03',what:
'@ @'
  {v:'29.04',what:'cw-padcap: with a pad on, the tactical belt next gun keycap names the pad next gun button (RB as bound), not D-DOWN; on the keyboard it still names F',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid here';
     var bad=[], g, p, gk=[], k, E0=null, oK=keys, PK={}, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, gp, c, want;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function poll(){ var bt=[], q; for(q=0;q<17;q++) bt.push({pressed:false,value:0}); gp={connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     function cap(){ var a=(g.beltCaps||[]).filter(function(x){ return x.k==='KeyF'; }); return a.length?a[0]:null; }
     for(k in PAD) PK[k]=PAD[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; p.iv=99; E0=g.ents; g.ents=[]; keys={};
       for(k in ITEMS) if(ITEMS[k].use==='gun'&&ITEMS[k].gk&&WEAPONS[ITEMS[k].gk]&&WEAPONS[ITEMS[k].gk].mag>0&&gk.length<2) gk.push(k);
       if(gk.length<2) return 'SKIP: staging: fewer than two guns';
       p.wep=cl(ITEMS[gk[0]].gk); p.ammo=p.wep.mag; p.sec=cl(ITEMS[gk[1]].gk); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0; p.reserve=60;
       // keyboard
       PAD.on=false; __frame(0); __frame(0); c=cap();
       if(!c) return 'SKIP: staging: no next gun keycap on the keyboard';
       if(c.s!==String(keyLabel('KeyF','F'))) bad.push('keyboard next gun cap says '+c.s+' (want '+keyLabel('KeyF','F')+')');
       // controller
       PAD.prev=[]; poll(); PAD.on=true; __frame(0); __frame(0);
       if(!padOn()) return 'SKIP: staging: the pad did not come on';
       c=cap(); want=String(padB(pbn(5)));
       if(!c) bad.push('pad: no next gun keycap drawn');
       else{
         if((/D-DOWN/).test(c.s)) bad.push('pad: the next gun cap says '+c.s+', and D-DOWN opens the item wheel');
         if(c.s!==want) bad.push('pad: the next gun cap says '+c.s+' (want '+want+', the pad next gun button)');
       }
       if(PADLABEL.KeyF!=='D-DOWN') bad.push('PADLABEL.KeyF moved to '+PADLABEL.KeyF);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete navigator.getGamepads; if(hadOwn) navigator.getGamepads=kNG; }catch(_n){}
       try{ for(k in PAD) if(!(k in PK)) delete PAD[k]; for(k in PK) PAD[k]=PK[k]; keys=oK; if(g&&E0) g.ents=E0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
