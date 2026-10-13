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

if ($s.Contains("  {v:'26.01',what:")) { throw "check 26.01 is in the fixture already" }

SubRx @'
  {v:'26.00',what:
'@ @'
  {v:'26.01',what:'a pin the game makes by itself for a heal, a grenade or a plate hides nothing from the backpack grid: with Bandages, a Medkit and a plate on automatic pins the grid lists all of them, while a key he bound himself hides one copy and an automatic pin on a gun still hides the gun; and the peddler counts the same claims',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof bagStacks!=='function'||typeof pedBeltClaims!=='function') return 'SKIP: no backpack grid here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     if(!ITEMS.bandage||!ITEMS.medkit||!ITEMS.plate||!ITEMS.gun_dmr) return 'SKIP: no heals, plate or marksman rifle here';
     var bad=[], g=null, p=null;
     function count(k){ var n=0, st=bagStacks(), i; for(i=0;i<st.length;i++) if(st[i].key===k) n+=st[i].idxs.length; return n; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; g.ents.length=0; p.iv=99;
       g.bag=['bandage','bandage','medkit','plate','gun_dmr'];
       g.hotAssign={2:'gun_dmr',6:'bandage',7:'medkit',8:'plate'}; g.hotAuto={2:1,6:1,7:1,8:1};
       if(count('bandage')!==2||count('medkit')!==1||count('plate')!==1) bad.push('ONE: with automatic pins the grid lists '+count('bandage')+' Bandage, '+count('medkit')+' Medkit and '+count('plate')+' plate, not 2, 1 and 1');
       if(count('gun_dmr')!==0) bad.push('ONE: an automatic pin on a gun stopped hiding the gun from the grid ('+count('gun_dmr')+')');
       if((pedBeltClaims().bandage|0)!==0) bad.push('ONE: the peddler counts '+pedBeltClaims().bandage+' Bandage claimed by an automatic pin');
       g.hotAuto={2:1};
       if(count('bandage')!==1||count('medkit')!==0||count('plate')!==0) bad.push('TWO: with the keys he bound himself the grid lists '+count('bandage')+' Bandage, '+count('medkit')+' Medkit and '+count('plate')+' plate, not 1, 0 and 0');
       if((pedBeltClaims().bandage|0)!==1) bad.push('TWO: the peddler counts '+pedBeltClaims().bandage+' Bandage claimed by his own key, not 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
