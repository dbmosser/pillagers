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

if ($s.Contains("  {v:'28.89',what:")) { throw "check 28.89 is in the fixture already" }

SubRx @'
  {v:'28.88',what:
'@ @'
  {v:'28.89',what:'his order: hard enemies (elites, sentries, bulwarks, howlers) drop better loot, never a gun',
   run:function(){
     if(typeof hardBonus!=='function') return 'a hard enemy drops nothing extra (no hardBonus)';
     var bad=[], g=null, i, k, n, c, e, keep, found=null, p, x;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<40;i++){
         k=hardBonus({kind:'raider',elite:1,rig:'none'});
         if(k.length<1){ bad.push('an elite pillager adds no roll'); break; }
         for(n=0;n<k.length;n++) if(String(k[n]).indexOf('gun_')===0){ bad.push('a hard drop is a gun: '+k[n]); }
       }
       if(hardBonus({kind:'crawler'}).length) bad.push('a plain crawler adds a roll');
       if(hardBonus({kind:'sentry'}).length<1) bad.push('a sentry adds no roll');
       if(hardBonus({kind:'bulwark'}).length<1) bad.push('a bulwark adds no roll');
       if(hardBonus({kind:'raider',elite:1,merc:1}).length) bad.push('your hire adds a roll');
       p=g.player;
       keep=g.ents.slice();
       for(x=0;x<6&&!found;x++){
         e=mkCrawler(p.x+60+x*30,p.y+60); e.elite=1; e.hp=0; e.byPlayer=false; e.name='CWHARD'+x;
         g.ents.length=0; g.ents.push(e);
         updateEnts(0.016);
         for(i=g.containers.length-1;i>=0;i--){ c=g.containers[i]; if(c&&c.bot==='crawler'&&Math.abs(c.x-e.x)<1&&Math.abs(c.y-e.y)<1){ found=c; break; } }
         if(found&&found.loot.length<2) bad.push('an elite crawler wreck holds '+found.loot.length+' item, not 2');
       }
       if(!found) bad.push('a dead elite crawler left no wreck');
       g.ents.length=0; for(i=0;i<keep.length;i++) g.ents.push(keep[i]);
       return bad.length?bad.slice(0,4).join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
