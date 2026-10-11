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

if ($s.Contains("  {v:'22.88',what:")) { throw "check 22.88 is in the fixture already" }

SubRx @'
  {v:'22.87',what:
'@ @'
  {v:'22.88',what:'the map story on a lore card: standing at the story sets the read flags once and draws its name and its whole body wrapped on a card inside the screen, while no feed row, alert or line said holds the story; 400 away the card is gone',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef&&window.__textTrace)) return 'SKIP: this fixture cannot deploy, step or trace';
     var bad=[], g, p, st, t0, f=0, K, i, j, tr, L, s, nd, frag, got=0, lines=0, out=0, ttl=false;
     function step(n,x,y){ for(var q=0;q<n&&!g.over;q++){ p.x=x; p.y=y; g.ents.length=0; __loop(t0+(++f)*16.7); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       st=g.map&&g.map.story; if(!st||!st.text) return 'SKIP: this map has no story';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9;
       g.storyRead=0; if(g.tel) g.tel.storyRead=0;
       g.msgT=0; g.msg=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.msgLog=[];
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       step(8,st.x,st.y+20);
       if(g.over) return 'SKIP: staging: the raid ended';
       if(g.storyRead!==1||!g.tel||g.tel.storyRead!==1) bad.push('standing at the story did not set the read flags (storyRead '+g.storyRead+')');
       nd=String(st.text).slice(0,24);
       L=g.msgLog||[];
       for(i=0;i<L.length;i++){ s=String(L[i].m)+' '+String(L[i].sub||''); if(s.indexOf(nd)>=0){ bad.push('a '+L[i].k+' line was said with the story text ('+s.length+' characters)'); break; } }
       if(String(g.msg||'').indexOf(nd)>=0) bad.push('the feed holds the story ('+String(g.msg).length+' characters)');
       if(g.alert&&String(g.alert.m).indexOf(nd)>=0) bad.push('the alert lane holds the story');
       g.alert=null; g.alertQ=[]; p.prep=null; p.prepA=null;
       if(g.lore) g.lore.at=(g.t||0)-1;
       tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} });
       for(i=0;i<tr.length;i++){
         s=String(tr[i].t);
         if(s===String(st.name).toUpperCase()) ttl=true;
         if(s.length>=8&&String(st.text).indexOf(s)>=0&&s!==String(st.text)){
           got+=s.length; lines++;
           if(tr[i].align==='left'&&(tr[i].x<0||tr[i].x+tr[i].w>W+1)) out++;
         }
       }
       if(!lines) bad.push('the story body was not drawn on a card');
       else {
         if(lines<2) bad.push('the story body was drawn on one line, not wrapped');
         if(got<String(st.text).length*0.85) bad.push('only '+got+' of '+String(st.text).length+' story characters were drawn');
         if(out) bad.push(out+' story lines ran off the screen');
       }
       if(!ttl) bad.push('the story name was not drawn as a caps title');
       // 400 AWAY: the card is gone.
       step(4,st.x+400,st.y+20);
       if(g.lore) bad.push('400 away the story card was still up');
       else {
         tr=__textTrace(function(){ try{ drawHUD(); }catch(_h2){} });
         for(i=0;i<tr.length;i++){ s=String(tr[i].t); if(s.length>=8&&String(st.text).indexOf(s)>=0){ bad.push('400 away the story was still drawn'); break; } }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var K2=__keysRef(); for(var k3 in K2) delete K2[k3]; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.lore=null; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
