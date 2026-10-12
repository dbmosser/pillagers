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

if ($s.Contains("  {v:'23.87',what:")) { throw "check 23.87 is in the fixture already" }

SubRx @'
  {v:'23.86',what:
'@ @'
  {v:'23.87',what:'his #29 and answer 33: the KIA card says KILLED BY who WITH what, and the KIA and EXTRACTED cards list DAMAGE TAKEN by source',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof damagePlayer!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, e=null, i, sub, man, last;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.armor=0; p.hp=100;
       for(i=0;i<g.ents.length;i++){ var c=g.ents[i]; if(c&&c.kind==='raider'&&c.name&&c.wep&&c.wep.name&&!c.merc){ e=c; break; } }
       if(!e) return 'SKIP: staging: no armed pillager';
       p.iv=0; damagePlayer(30,'sentry','SENTRY');
       p.iv=0; damagePlayer(30,'sentry','SENTRY');
       p.iv=0; damagePlayer(10,'raider',e.name);
       last=(g.tel.hitLog||[])[(g.tel.hitLog||[]).length-1];
       if(!last||last.w!==String(e.wep.name).toUpperCase()) bad.push('the last hit does not carry the pillager gun ('+(last&&last.w)+' against '+e.wep.name+')');
       if(g.tel.hitLog[0]&&g.tel.hitLog[0].w!=='AUTOCANNON') bad.push('a sentry hit reads '+g.tel.hitLog[0].w);
       __endRaid('dead');
       sub=(document.getElementById('oc_sub')||{}).textContent||''; man=(document.getElementById('oc_manifest')||{}).textContent||'';
       if(sub.indexOf('WITH '+String(e.wep.name).toUpperCase())<0) bad.push('the KIA line does not name the gun: '+sub.slice(0,90));
       if(man.indexOf('DAMAGE '+'TAKEN')<0) bad.push('the KIA card has no DAMAGE TAKEN block');
       else if(man.indexOf('SENTRY')<0||man.indexOf('-60')<0) bad.push('DAMAGE TAKEN does not total the sentry at 60: '+man.slice(0,160));
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return bad.length?bad.join('; '):'SKIP: no second raid';
       p=g.player; p.armor=0; p.hp=100; p.iv=0;
       damagePlayer(20,'sentry','SENTRY');
       __endRaid('extract');
       man=(document.getElementById('oc_manifest')||{}).textContent||'';
       if(man.indexOf('DAMAGE '+'TAKEN')<0) bad.push('the EXTRACTED card has no DAMAGE TAKEN block after a hit');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
