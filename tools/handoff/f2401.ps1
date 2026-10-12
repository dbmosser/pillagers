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

if ($s.Contains("  {v:'24.01',what:")) { throw "check 24.01 is in the fixture already" }

SubRx @'
  {v:'24.00',what:
'@ @'
  {v:'24.01',what:'forge1: a 612 Longshot round player 2 puts into a Choir DORSAL SPINE lands on the host, and a 1600 shot word is still thrown away',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netShotTake!=='function'||typeof netEntsInit!=='function'||typeof netEntsHost!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g, e=null, ch=null, i, c, r, pa={state:'in',seat:1}, m, nm;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[pa]; NET.up=[];
       if(!netEntsHost()) return 'SKIP: staging: the window does not read as the host';
       netEntsInit(g);
       for(i=0;i<g.ents.length;i++){ c=g.ents[i]; if(!c||c.hp<=0||c.downed||c.finished||c.merc||c.friendlyPC||c.kind==='peddler'||c.kind==='stray'||c.kind==='snitch') continue; if(c.kind==='choir'){ ch=c; break; } if(!e) e=c; }
       if(ch) e=ch;
       if(!e||!e.nid) return 'SKIP: staging: no body to shoot';
       nm=(ch&&typeof weakOf==='function'&&weakOf(ch))?weakOf(ch).filter(function(w){ return w.mult>=3.5; })[0]:null;
       e.hp=900; e.armor=0; e.overheat=0; e.htImmune=0; e.roll=0;
       m={t:'shot',id:e.nid,dmg:612};
       if(nm) m.wk=nm.name;
       r=netShotTake(pa,m);
       if(r!=='shot') bad.push('the host threw away a 612 hit on a '+e.kind+' ('+r+')');
       else if(Math.abs(e.hp-288)>0.01) bad.push('a 612 hit on a '+e.kind+' at 900 health left '+e.hp);
       e.hp=900; e.overheat=0; e.htImmune=0;
       r=netShotTake(pa,{t:'shot',id:e.nid,dmg:1400});
       if(r!=='shot') bad.push('the host threw away a 1400 hit ('+r+')');
       e.hp=900;
       r=netShotTake(pa,{t:'shot',id:e.nid,dmg:1600});
       if(r!=='bad'||e.hp!==900) bad.push('a 1600 shot word was taken ('+r+', '+e.hp+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
