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

if ($s.Contains("  {v:'27.24',what:")) { throw "check 27.24 is in the fixture already" }

SubRx @'
  {v:'27.23',what:
'@ @'
  {v:'27.24',what:'his order: one persistent feed at the bottom left takes the raid lines: pickups counted in their rarity colour, alerts, objectives, teammate lines, kills and medals; ten lines, the newest at the bottom, full for six seconds then dimmed, clear of the body corner and the controls list',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame) return 'SKIP: no raid here';
     if(typeof feedAdd!=='function'||typeof feedDraw!=='function'||typeof FEEDBOX==='undefined') return 'this build has no feed';
     var bad=[], g, F, i, a, b, ln, R, k;
     function find(t){ for(var j=0;j<F.lines.length;j++) if(F.lines[j].txt.indexOf(t)===0) return F.lines[j]; return null; }
     function idx(t){ for(var j=0;j<F.lines.length;j++) if(F.lines[j].txt.indexOf(t)===0) return j; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       say('Scrap Metal','pick',{item:'scrap',n:1}); say('Scrap Metal','pick',{item:'scrap',n:1});
       say('Bandage','pick',{item:'bandage',tag:'SLOT 6'});
       say('SIEGE INCOMING','crit',{sub:'6 MACHINES'});
       say('CACHE MARKED','obj',{sub:'TEAMMATE PINGED A STRONGBOX'});
       say('PLAYER 2 IS BACK UP','ally');
       say('Extraction A open.','info'); say('Extraction A open.','info');
       say('BACKPACK FULL','pick',{key:'bagfull',c:'danger'}); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger'}); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger'});
       say('NOT IN THE FEED','log');
       F=g.fd; if(!F||!F.lines) return 'the raid has no feed';
       a=find('Scrap Metal'); if(!a) bad.push('the pickup is not in the feed'); else { if(a.n!==2) bad.push('two pickups of one item read x'+a.n+', not x2'); if(a.fk!=='loot') bad.push('a pickup is kind '+a.fk); if(a.col!==feedItemCol('scrap')) bad.push('the pickup is not in its rarity colour'); }
       a=find('SIEGE INCOMING'); if(!a||a.fk!=='danger') bad.push('the alert is not in the feed as a danger line');
       a=find('CACHE MARKED'); if(!a||a.fk!=='obj') bad.push('the objective is not an objective line');
       a=find('PLAYER 2 IS BACK UP'); if(!a||a.fk!=='team') bad.push('the teammate line is not a team line');
       a=find('Extraction A open.'); if(!a) bad.push('an info line is not in the feed'); else if(a.n!==1) bad.push('a line said twice at once reads x'+a.n);
       a=find('BACKPACK FULL'); if(!a) bad.push('BACKPACK FULL is not in the feed'); else if(a.n!==1) bad.push('a per-frame line is counted x'+a.n);
       if(find('NOT IN THE FEED')) bad.push('a log line is shown in the feed');
       if(!(idx('Scrap Metal')<idx('Bandage')&&idx('Bandage')<idx('SIEGE INCOMING')&&idx('SIEGE INCOMING')<idx('CACHE MARKED')&&idx('CACHE MARKED')<idx('PLAYER 2 IS BACK UP')&&idx('PLAYER 2 IS BACK UP')<idx('Extraction A open.'))) bad.push('the lines are not in the order they were said');
       for(k=0;k<50;k++) say('FILL '+k,'info');
       if(F.lines.length>FEED.keep) bad.push('the feed keeps '+F.lines.length+' lines, over '+FEED.keep);
       if(F.lines[F.lines.length-1].txt.indexOf('FILL 49')!==0) bad.push('the newest line is not at the end');
       __frame(0.016); __frame(0.016);
       R=FEEDBOX; if(!R.on) bad.push('the feed zone is not laid out');
       else {
         if(R.rows.length!==FEED.show) bad.push('the feed shows '+R.rows.length+' lines, not '+FEED.show);
         if(R.rows.length&&R.rows[0].t.indexOf('FILL 49')!==0) bad.push('the newest line is not the bottom line');
         if(R.x>W*0.2||R.x+R.w>W*0.45) bad.push('the feed is not in the bottom left ('+R.x+','+R.w+')');
         if(HUDBOX.body&&R.y+R.h>HUDBOX.body.y+0.5) bad.push('the feed runs into the body corner');
         if(HUDBOX.legend&&g.legendOn&&HUDBOX.legend.y+HUDBOX.legend.h>R.y+0.5&&HUDBOX.legend.x<R.x+R.w) bad.push('the controls list is on top of the feed');
         if(R.rows.length>1&&!(R.rows[0].y>R.rows[1].y)) bad.push('the lines do not run upward from the newest');
       }
       // 6 s bright, then dimmed to 35 percent and kept
       F.t+=FEED.hold+FEED.fade+1;
       ln=F.lines[F.lines.length-1];
       if(feedAlpha(ln)>FEED.dim+0.001||feedAlpha(ln)<FEED.dim-0.001) bad.push('an old line reads '+feedAlpha(ln)+', not '+FEED.dim);
       say('FRESH LINE','info'); ln=F.lines[F.lines.length-1];
       if(ln.txt!=='FRESH LINE'||feedAlpha(ln)!==1) bad.push('a new line is not full bright');
       F.t+=FEED.hold-1; if(feedAlpha(ln)!==1) bad.push('a line is dimmed before six seconds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
