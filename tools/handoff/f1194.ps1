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

# v11.94 CHECK, inserted before the v11.93 entry. His four lines are driven
# through the real code with the say calls recorded: a Crier at the last
# instant of its windup, a Pillbox with no health, the revive spent and
# pressed, and a container search picked up at six percent.
SubRx @'
  {v:'11.93',what:'ENTER in the title name box commits the name, and the start button commits whatever is typed there (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.94',what:'the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, and the self-revive says one per raid (his three wording notes of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy and step';
     if(typeof mkSnitch!=='function'||typeof mkListener!=='function'||typeof selfRevive!=='function'||typeof updatePlayer!=='function') return 'SKIP: a maker or verb is missing in this build';
     var bad=[], said=[], realSay=say;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
       // ONE: the Crier, at the last instant of its alarm windup.
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='snitch') g.ents[i].hp=0;   // the map's own criers, out of the way
       var cr=mkSnitch(p.x+240,p.y); cr.state='alarm'; cr.wind=0.01; cr.markX=p.x; cr.markY=p.y; cr.lost=0; g.ents.push(cr);
       __ents(0.1);
       if(!said.some(function(t){ return t.indexOf('The Crier raised the alarm.')===0; })) bad.push('the alarm line does not name the Crier (said: '+said.filter(function(t){ return /larm/.test(t); }).join(' | ').slice(0,90)+')');
       if(said.some(function(t){ return t.indexOf('Alarm went out. It')===0||t.indexOf('Alarm went out. They')===0; })) bad.push('the old Alarm went out line still prints');
       // TWO: the Pillbox, destroyed.
       said.length=0;
       var L=mkListener(p.x+300,p.y+40); L.hp=0; g.ents.push(L);
       __ents(0.1);
       if(!said.some(function(t){ return /destroyed\. It has stopped listening/.test(t); })) bad.push('the Pillbox death line does not say destroyed (said: '+said.join(' | ').slice(0,90)+')');
       // THREE: the self-revive, spent and pressed, and the down line.
       said.length=0; p.downed=true; p.revived=true; selfRevive();
       if(!said.some(function(t){ return t==='Self-revive spent. One per raid.'; })) bad.push('the spent revive does not say one per raid (said: '+said.join(' | ').slice(0,90)+')');
       said.length=0; p.downed=false; p.revived=false; p.hp=5; p.armor=0; p.iv=0;
       damagePlayer(40,null,'crawler',p.x+20,p.y);
       if(!said.some(function(t){ return /You get one per raid\./.test(t); })) bad.push('the down line does not say one per raid (said: '+said.join(' | ').slice(0,90)+')');
       p.downed=false; p.hp=100;
       // FOUR: a container search picked up at six percent.
       var ct=null; for(i=0;i<g.containers.length&&!ct;i++) if(g.containers[i]&&g.containers[i].time>0&&!g.containers[i].done) ct=g.containers[i];
       if(!ct) bad.push('control: no searchable container on the map');
       else {
         p.x=ct.x+18; p.y=ct.y; ct.prog=ct.time*0.06; g.searching=null; g.searchT=0; keys={}; keys['KeyE']=true; said.length=0;
         updatePlayer(0.016);
         keys={};
         if(!said.some(function(t){ return t==='Search resumed, 6% done.'; })) bad.push('the resumed search does not say Search resumed (said: '+said.join(' | ').slice(0,90)+')');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ say=realSay; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.hp=100; g2.searching=null; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.93',what:'ENTER in the title name box commits the name, and the start button commits whatever is typed there (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
