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
  {v:'15.97',what:
'@ @'
  {v:'15.98',what:'the imported friend remembers what you did to him: with his own ledger record at one kill and standing minus two, the next raid builds him hostile with a grudge, no friendly flag and standing minus two; with the record at no kills and standing three, as a revive leaves it, he is friendly with no grudge at standing three; and with no record at all he is friendly with no grudge as before (ghost audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof applyGhost!=='function'||typeof idRec!=='function') return 'SKIP: no imported friend or ledger in this build';
     if(!(WEAPONS&&WEAPONS.pistol&&WEAPONS.pistol.mag)) return 'SKIP: this build has no Scav Pistol to hand him';
     var bad=[], snap=null, keepGhost=null, GK='ghost_ZQXFRIEND';   // the key applyGhost gives the friend, with a tag no report carries
     function friend(){ return {tag:'ZQXFRIEND',wep:'pistol',wepName:'Scav Pistol',runs:4,ext:1,rate:25,avgHaul:0}; }
     // One raid built with the friend imported and his record staged as given, the raid after the one that wrote it; the
     // friend's body is read as the build left it, before any frame runs.
     function build(rec){
       var g0=__state(); if(g0&&!g0.over) __endRaid('abandon');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var P2=__P(); P2.ghost=friend(); P2.rivals={};
       if(rec) P2.rivals[GK]=rec;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||g.over) return null;
       var gh=null, k;
       for(k=0;k<g.ents.length;k++) if(g.ents[k].ghost){ gh=g.ents[k]; break; }
       if(!gh){ applyGhost(); for(k=0;k<g.ents.length;k++) if(g.ents[k].ghost){ gh=g.ents[k]; break; } }
       if(!gh) return {none:1};
       return {ident:gh.ident,hostile:gh.hostile,fpc:gh.friendlyPC?1:0,grudge:!!gh.grudge,standing:gh.standing,rec:(__P().rivals||{})[GK]||null};
     }
     function word(r){ return 'hostile '+r.hostile+', friendly flag '+r.fpc+', grudge '+r.grudge+', standing '+r.standing; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P())); keepGhost=__P().ghost;
       // CONTROL: with no record on the ledger the import places him friendly with no grudge, keyed as his ledger writes are, on either build.
       var C=build(null);
       if(!C) return 'SKIP: no live raid';
       if(C.none) return 'SKIP: no imported friend was placed in the raid';
       if(C.ident!==GK) return 'SKIP: the friend is keyed '+C.ident+' rather than '+GK+', so the record staged here is not the one his ledger writes land on';
       if(C.fpc!==1||C.grudge||C.hostile!==false) return 'SKIP: with no record the friend was not placed friendly ('+word(C)+'), so the import path cannot be read here';
       // ARM A: his record as the death path leaves it after you killed him once. He must come up hostile with a grudge and no
       // friendly flag, at his own standing.
       var A=build({kills:1,deaths:0,met:1,standing:-2});
       if(!A||A.none) return 'SKIP: the friend was not placed in the raid built with his kill on the ledger';
       if(!A.rec||A.rec.kills!==1) return 'SKIP: the kill staged on his record did not survive the raid build ('+JSON.stringify(A.rec)+')';
       if(A.hostile!==true||A.fpc!==0||A.grudge!==true) bad.push('with one kill on his own record the friend was built '+word(A)+': he will remember that was said, and nothing remembered');
       if(A.standing!==-2) bad.push('with his record at standing -2 the friend was built at standing '+A.standing+', the standing of the body he took rather than his own');
       // ARM B: his record as the revive leaves it, standing up and no kill. He stays friendly with no grudge, at his own standing.
       var B=build({kills:0,deaths:0,met:1,standing:3});
       if(!B||B.none) return 'SKIP: the friend was not placed in the raid built with the revive on the ledger';
       if(B.fpc!==1||B.grudge||B.hostile!==false) bad.push('with a revive and no kill on his record the friend was built '+word(B)+' rather than friendly with no grudge');
       if(B.standing!==3) bad.push('with his record at standing 3 after a revive the friend was built at standing '+B.standing+', so the nod he owes you comes from a stranger');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(snap) __P().ghost=keepGhost; }catch(_g){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
