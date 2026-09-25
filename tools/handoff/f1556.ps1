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
  {v:'15.55',what:
'@ @'
  {v:'15.56',what:'a door key is never hidden in THE VAULT CASE or behind another locked door: on COLD STORAGE at seed 4242, with a Foreman Office key staged in a box inside the Blast Freezer and every other box but THE VAULT CASE out of the key draw, no key goes into THE VAULT CASE and the staged box keeps only its own key, and with one box clear of every locked room left in the draw both door keys go into that box (keys audit finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkContainer!=='function'||typeof FIXED_MAPS==='undefined'||!FIXED_MAPS[0]||typeof WORLD_W!=='number'||typeof WORLD_H!=='number') return 'SKIP: this build has no containers, fixed maps or world size';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var LK=FIXED_MAPS[0].locked||[];
     if(LK.length<2) return 'SKIP: the first map has fewer than two locked rooms in this build';
     var A=LK[0], B=LK[1], kA='key_'+A.id, kB='key_'+B.id;
     if(!ITEMS[kA]||!ITEMS[kB]) return 'SKIP: the two locked rooms have no key items in this build';
     var _mk=mkContainer, bad=[], snap=null, S=null, why='';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var inRoom=function(c,L,m){ return c.x>L.x-m&&c.x<L.x+L.w+m&&c.y>L.y-m&&c.y<L.y+L.h+m; };
     var sealed=function(c,m){ for(var q=0;q<LK.length;q++) if(inRoom(c,LK[q],m)) return true; return false; };
     var keysIn=function(c){ var o=[], l=(c&&c.loot)||[]; for(var q=0;q<l.length;q++) if(String(l[q]).indexOf('key_')===0) o.push(String(l[q])); return o; };
     var nm=function(k){ return (ITEMS[k]&&ITEMS[k].name)||k; };
     // One ascent with mkContainer wrapped. Every key a box rolls is taken out. The first ordinary box is set down in the middle
     // of room A holding room B's key. THE VAULT CASE is moved to the middle of the map if it stood within 40 of a locked room.
     // With open set, the next ordinary box standing 240 clear of every locked room (more than a pad push) is left alone. Every
     // other box carries the strongbox flag, which keeps it out of the key draw. So on v15.55 room B's key is already kept by
     // the box behind room A's door, and room A's key can only go to THE VAULT CASE, or to the open box when there is one.
     var ascend=function(open){
       var T={decoy:null,open:null,vault:null,vaultSealed:true,made:0,g:null};
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       mkContainer=function(x,y,type){
         var c=_mk.apply(this,arguments);
         try{
           T.made++;
           c.loot=(c.loot||[]).filter(function(k){ return String(k).indexOf('key_')!==0; });
           var ord=(type==='crate'||type==='locker'||type==='safe'||type==='body');
           if(type==='jackpot'){ if(sealed(c,40)){ c.x=WORLD_W/2; c.y=WORLD_H/2; } T.vault=c; T.vaultSealed=sealed(c,40); }
           else if(ord&&!T.decoy){ c.x=A.x+A.w/2; c.y=A.y+A.h/2; c.loot.push(kB); T.decoy=c; }
           else if(ord&&open&&!T.open&&!sealed(c,240)) T.open=c;
           else c.strong=1;
         }catch(_w){}
         return c;
       };
       try{ __deploy({kit:[],safe:null,mapIx:0,seed:4242}); }
       finally{ mkContainer=_mk; }
       T.g=__state();
       return T;
     };
     // CONTROL for each ascent: a live raid on COLD STORAGE with its authored rooms, the staged boxes built into it, the box in
     // room A still inside it with room B's key, THE VAULT CASE clear of every room, and no box pushed before THE VAULT CASE,
     // which are the boxes the key draw saw, left in the draw but the staged ones.
     var ready=function(T,open){
       var t=T.g, i, c;
       if(!t||!t.player||t.over||!Array.isArray(t.containers)) return 'no live raid';
       var gl=(t.map&&t.map.locked)||[];
       if(gl.length!==LK.length||gl[0].id!==A.id||gl[1].id!==B.id||gl[0].x!==A.x||gl[0].y!==A.y) return 'the raid is not on COLD STORAGE with its authored locked rooms';
       var vi=t.containers.indexOf(T.vault), di=t.containers.indexOf(T.decoy), oi=t.containers.indexOf(T.open);
       if(!T.made||!T.decoy||vi<0||di<0||di>vi) return 'the staged boxes were not built into this raid';
       if(T.vault.type!=='jackpot'||T.vault.tag!=='THE VAULT CASE') return 'the jackpot built is not THE VAULT CASE';
       if(T.vaultSealed) return 'THE VAULT CASE could not be set clear of the locked rooms';
       if(!inRoom(T.decoy,A,0)||T.decoy.strong||T.decoy.cache) return 'the box set down inside '+A.name+' did not stay inside it in the draw';
       if(keysIn(T.decoy).indexOf(kB)<0) return 'the staged '+nm(kB)+' did not stay in the box inside '+A.name;
       if(open&&(!T.open||oi<0||oi>vi||T.open.strong||T.open.cache)) return 'no ordinary box clear of every locked room was left in the draw';
       for(i=0;i<vi;i++){ c=t.containers[i]; if(c===T.decoy||c===T.open) continue; if(!c.cache&&!c.strong) return 'a box other than the staged ones stayed in the key draw'; }
       return '';
     };
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: no box clear of the locked rooms is in the draw. Room A's key has nowhere legal to go.
       S=ascend(false);
       why=ready(S,false);
       if(why) return skip(why+' (first ascent)');
       var vk=keysIn(S.vault), dk=keysIn(S.decoy);
       if(vk.length) bad.push('a door key was hidden in THE VAULT CASE, the one box the map never marks: it holds the '+vk.map(nm).join(' and '));
       if(dk.length!==1) bad.push('the box behind the '+A.name+' door holds '+dk.map(nm).join(' and ')+', so a door key was put behind another locked door');
       if(S.g&&!S.g.over) __endRaid('abandon');
       // TWO: one ordinary box clear of every locked room is in the draw. Both door keys must go into it.
       S=ascend(true);
       why=ready(S,true);
       if(why) return skip(why+' (second ascent)');
       var ok=keysIn(S.open);
       if(ok.indexOf(kB)<0) bad.push('the only '+nm(kB)+' on the map sat in a box behind the '+A.name+' door and none was put in the open box, so '+B.name+' needed a second key first');
       if(ok.indexOf(kA)<0) bad.push('no '+nm(kA)+' went into the one box clear of every locked room'+(keysIn(S.vault).indexOf(kA)>=0?', it went into THE VAULT CASE':''));
       vk=keysIn(S.vault); dk=keysIn(S.decoy);
       if(vk.length) bad.push('with an open box in the draw THE VAULT CASE still holds the '+vk.map(nm).join(' and '));
       if(dk.length!==1) bad.push('with an open box in the draw the box behind the '+A.name+' door holds '+dk.map(nm).join(' and '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       mkContainer=_mk;
       try{ var gl2=__state(); if(gl2&&!gl2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
