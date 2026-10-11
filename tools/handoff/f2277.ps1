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

if ($s.Contains("  {v:'22.77',what:")) { throw "check 22.77 is in the fixture already" }

SubRx @'
  {v:'22.76',what:
'@ @'
  {v:'22.77',what:'lines nobody can see go: going down by damage says no DOWN line while the downed screen draws the SELF-REVIVE row, a hail with nobody near says only the earshot line and no narration, and the hauled aboard and abandon lines are not said under the outcome card',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)) return 'SKIP: this fixture cannot deploy or trace text';
     if(typeof damagePlayer!=='function'||typeof doEmote!=='function'||typeof drawHUD!=='function'||typeof EMOTES==='undefined') return 'SKIP: no damage, emotes or HUD in this build';
     var bad=[], g=null, p=null, _say=say, said=[], i, tr, dn, hi=-1, src, NB='nobody in '+'earshot', TH="say('They have "+"you", WO="say(_rc>0?('Walked "+"out";
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0;
       say=function(m){ said.push(String(m)); try{ return _say.apply(this,arguments); }catch(_s){} };
       // ONE: down by damage, the self-revive unspent.
       p.downed=false; p.revived=false; p.hp=5; p.armor=0; p.iv=0;
       damagePlayer(40,null,'crawler',p.x+20,p.y);
       if(!p.downed) return 'SKIP: staging: the hit did not put him down (hp '+p.hp+')';
       tr=__textTrace(function(){ drawHUD(); });
       if(!tr.some(function(o){ return o.t.indexOf('SELF-REVIVE')>=0; })) return 'SKIP: the downed screen drew no SELF-REVIVE row here, so it cannot be what says it';
       dn=said.filter(function(s){ return s.indexOf('DOWN')===0; });
       if(dn.length) bad.push('going down said '+dn.length+' lines under the downed screen that says it: '+dn.join(' | '));
       // TWO: a hail with nobody near, the gun down.
       p.downed=false; p.dying=false; p.hp=100; p.roll=0; p.ads=false; p.lastShot=-1e9; g.emoteCd=0; g.ents.length=0; said.length=0;
       for(i=0;i<EMOTES.length;i++) if(EMOTES[i].k==='hail') hi=i;
       if(hi<0) bad.push('SKIP: no hail emote in this build');
       else {
         doEmote(hi);
         if(!(g.emoteCd>0)) bad.push('SKIP: staging: the hail was not done ('+said.join(' | ')+')');
         else if(said.length!==1||said[0].toLowerCase().indexOf(NB)!==0) bad.push('a hail with nobody near said '+said.length+' lines, not only the earshot line: '+said.join(' | '));
       }
       // THREE: the hauled aboard and abandon lines, said in the frame the outcome card covers the raid.
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('');
       if(src.indexOf(TH)>=0) bad.push('the hauled aboard line is still said in the frame endRaid covers it');
       if(src.indexOf(WO)>=0) bad.push('the abandon line is still said in the click endRaid covers it');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=_say;
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; g2.emoteCd=0; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.dying=false; g2.player.hp=100; g2.player.revived=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
