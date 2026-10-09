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

if ($s.Contains("  {v:'21.21',what:")) { throw "check 21.21 is in the fixture already" }

SubRx @'
  {v:'21.20',what:
'@ @'
  {v:'21.21',what:'an armoury gun a party member drops stays on his carried list until someone else takes it: the drop keeps it, the host tells him only when another seat takes it, and a guest pile never strips the host list',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof dropItem!=='function') return 'SKIP: no raid or party here';
     if(typeof netGunTold!=='function'||typeof netGunGoneTake!=='function') return 'control: a dropped armoury gun has no way to be told taken';
     var NK={}, k, bad=[], oSend=netSend, sent=[], gk=null, key=null, rs0, i, ks=Object.keys(ITEMS), g, ct;
     for(i=0;i<ks.length;i++) if(/^gun_/.test(ks[i])&&ITEMS[ks[i]]&&ITEMS[ks[i]].gk&&WEAPONS[ITEMS[ks[i]].gk]){ key=ks[i]; gk=ITEMS[key].gk; break; }
     if(!key) return 'SKIP: no armoury gun item here';
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       rs0=P.raidSpliced;
       netSend=function(q,m){ sent.push({seat:q&&q.seat,m:JSON.parse(JSON.stringify(m))}); return true; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       g.spliced=[gk]; P.raidSpliced=[gk]; g.bag.push(key);
       dropItem(g.bag.length-1);
       if(!sent.some(function(s){ return s.m.t==='pile'; })) return 'SKIP: staging: no pile word went out';
       if(g.spliced.indexOf(gk)<0) bad.push('the drop took the gun off his carried list before anyone took it');
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'},{seat:2,state:'in'}]; sent=[];
       ct={dropped:1,dropBy:1,loot:[],x:g.player.x,y:g.player.y};
       netGunTold(ct,[key],1);
       if(sent.length) bad.push('the dropper taking his own gun back was told it was taken');
       netGunTold(ct,[key],2);
       if(!sent.some(function(s){ return s.seat===1&&s.m.t==='gungone'&&s.m.k===gk; })) bad.push('another seat taking the gun did not tell the dropper');
       g.spliced=['zz_hostgun',gk];
       netGunsGone(ct,[key]);
       if(g.spliced.indexOf(gk)<0) bad.push('a pile a party member dropped took a gun off the host list');
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; g.spliced=[gk]; P.raidSpliced=[gk];
       netGunGoneTake({seat:0,state:'in'},{t:'gungone',k:gk});
       if(g.spliced.indexOf(gk)>=0||P.raidSpliced.indexOf(gk)>=0) bad.push('the word that the gun was taken did not take it off his lists');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       if(rs0!==undefined) P.raidSpliced=rs0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
