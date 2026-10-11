$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# TACTICAL BELT AND GUN LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          say((_gw8n+' on key '+(_onCell+1)).toUpperCase(),'info',(_gwTi&&_gwTi.use!=='gun')?{sub:(_gwTi.name+' on key '+(d.fromHot+1)).toUpperCase()}:null);   // v22.43: the shooter voice
'@ @'
          say((_gw8n+' to slot '+(_onCell+1)).toUpperCase(),'info',(_gwTi&&_gwTi.use!=='gun')?{sub:(_gwTi.name+' to slot '+(d.fromHot+1)).toUpperCase()}:null);   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
            _gaI=ITEMS[_gaP]; if(_gaI) _gaM={sub:(_gaI.name+' on key '+(d.fromHot+1)).toUpperCase()};
'@ @'
            _gaI=ITEMS[_gaP]; if(_gaI) _gaM={sub:(_gaI.name+' to slot '+(d.fromHot+1)).toUpperCase()};   // v22.xx (R52): the slot word
'@

SubRx @'
          say((_gw8n+' on key '+(_onCell+1)).toUpperCase(),'info',_gaM);   // the shooter voice
'@ @'
          say((_gw8n+' to slot '+(_onCell+1)).toUpperCase(),'info',_gaM);   // the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
            say((((_gNow&&_gNow.name)||_dit.name)+' on key '+(HC.i+1)).toUpperCase(),'info',_gLost?{sub:_gLost.trim()}:null);
'@ @'
            say((((_gNow&&_gNow.name)||_dit.name)+' to slot '+(HC.i+1)).toUpperCase(),'info',_gLost?{sub:_gLost.trim()}:null);   // v22.xx (R52): the slot word
'@

SubRx @'
              var _gSub=[_gLost.trim(),_gunKeyHint].filter(function(_gs){ return !!_gs; }).join(' \u00b7 '); say((((_gUp&&_gUp.name)||_dit.name)+' on key '+(HC.i+1)).toUpperCase(),'info',_gSub?{sub:_gSub}:null);
'@ @'
              var _gSub=[_gLost.trim(),_gunKeyHint].filter(function(_gs){ return !!_gs; }).join(' \u00b7 '); say((((_gUp&&_gUp.name)||_dit.name)+' to slot '+(HC.i+1)).toUpperCase(),'info',_gSub?{sub:_gSub}:null);   // v22.xx (R52): the slot word
'@

SubRx @'
          say('GUNS ONLY','info',{sub:'KEY '+(HC.i+1)});   // v22.43: the shooter voice
'@ @'
          say('SLOT '+(HC.i+1)+' TAKES GUNS ONLY');   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
        say(((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' on key '+(HC.i+1)).toUpperCase());   // v22.58: the shooter voice
'@ @'
        say(((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' to slot '+(HC.i+1)).toUpperCase());   // v22.58: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
        say(((ITEMS[_wasKey]?ITEMS[_wasKey].name:'Item')+' off key '+(d.fromHot+1)).toUpperCase());   // v22.58: the shooter voice
'@ @'
        say(((ITEMS[_wasKey]?ITEMS[_wasKey].name:'Item')+' off slot '+(d.fromHot+1)).toUpperCase());   // v22.58: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
        var _gbTxt=(it.name+' on key '+(gi+1)).toUpperCase();   // v22.43: the shooter voice
'@ @'
        var _gbTxt=(it.name+' to slot '+(gi+1)).toUpperCase();   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
      var _beltTxt=(it.name+' on key '+(bi+1)).toUpperCase();   // v22.43: the shooter voice
'@ @'
      var _beltTxt=(it.name+' to slot '+(bi+1)).toUpperCase();   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
        var _svTxt=(it.name+' on key '+(_svi+1)).toUpperCase();
'@ @'
        var _svTxt=(it.name+' to slot '+(_svi+1)).toUpperCase();   // v22.xx (R52): the slot word
'@

SubRx @'
            say((ITEMS[_rpk].name+' received').toUpperCase(),'info',{sub:_rpKy>=0?('KEY '+(_rpKy+1)):(ITEMS[_rpk].use==='throw'?'ON BELT':'IN BACKPACK')});
'@ @'
            say((ITEMS[_rpk].name+' received').toUpperCase(),'info',{sub:_rpKy>=0?('SLOT '+(_rpKy+1)):(ITEMS[_rpk].use==='throw'?'ON BELT':'IN BACKPACK')});   // v22.xx (R52): the slot word
'@

SubRx @'
      for(var _pk in G.hotAssign) if(G.hotAssign[_pk]==='gun_'+_pushId){ _gunKeyHint=(oldW.name+' in backpack \u00b7 key '+(+_pk+1)).toUpperCase(); break; }
'@ @'
      for(var _pk in G.hotAssign) if(G.hotAssign[_pk]==='gun_'+_pushId){ _gunKeyHint=(oldW.name+' in backpack \u00b7 slot '+(+_pk+1)).toUpperCase(); break; }   // v22.xx (R52): the slot word
'@

SubRx @'
    if(oldIssued) _oldLine=oldW.name+' was issued kit, left behind.';
'@ @'
    if(oldIssued) _oldLine='Issued '+oldW.name+' left behind.';   // v22.xx (R52): issued gear, not kit; a detail
'@

SubRx @'
      _oldLine=oldW.name+' into the backpack.';
'@ @'
      _oldLine=oldW.name+' to backpack.';   // v22.xx (R52): a detail
'@

SubRx @'
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) _oldLine=oldW.name+' is yours; it goes back to the armoury.';
'@ @'
    else if(oldArm&&P.weapons.indexOf(oldW.id)>=0) _oldLine=oldW.name+' back to the armoury.';   // v22.xx (R52): no semicolon
'@

SubRx @'
                    :(g.name+(toSec?' to secondary':' equipped'));
'@ @'
                    :(g.name+(toSec?' stowed':' equipped')).toUpperCase();   // v22.xx (R52): X EQUIPPED, or X STOWED when it went to the other hand
'@

SubRx @'
  if(_kept&&!_oldLine) say(_newLine,'info',_gunKeyHint?{sub:_gunKeyHint}:null);
  else if(_gunKeyHint) say(_eqLine.replace(/\.$/,''),'info',{sub:_gunKeyHint});
  else say(_eqLine);
'@ @'
  // v22.xx, the raid text rewrite (R52): one caps headline, the gun he now has, and what happened to the gun it pushed out as the
  // detail with the slot it kept (Issued Scav Pistol left behind. / Meridian Lance back to the armoury.), never one long sentence.
  var _eqSub=[_oldLine,_gunKeyHint].filter(function(_es){ return !!_es; }).join(' \u00b7 ');
  say(_newLine,'info',_eqSub?{sub:_eqSub}:null);
'@

SubRx @'
  if(issued){ say('ISSUED KIT','info',{sub:'CANNOT STOW'}); return false; }   // v22.43: the shooter voice
'@ @'
  if(issued){ say('ISSUED GEAR STAYS IN YOUR HANDS'); return false; }   // v22.43: the shooter voice   // v22.xx (R52): issued gear, not kit
'@

SubRx @'
  if(!ITEMS['gun_'+g.id]){ say(g.name+' has no place in your backpack.'); return false; }
'@ @'
  if(!ITEMS['gun_'+g.id]){ say('CANNOT STOW THAT GUN','info',{sub:g.name+' has no backpack form.'}); return false; }   // v22.xx (R52)
'@

SubRx @'
  say(g.name+' into the backpack.'); blip('pick');
'@ @'
  say(g.name,'pick',{item:'gun_'+g.id,tag:'BACKPACK'}); blip('pick');   // v22.xx (R52): a pickup row tagged BACKPACK
'@

SubRx @'
      say(ITEMS[THROWKEYS[n]].name+' ready');
'@ @'
      say((ITEMS[THROWKEYS[n]].name+' ready').toUpperCase());   // v22.xx (R52)
'@

SubRx @'
  say(_unkeyed?'No throwable on your tactical belt.':'No throwables');
'@ @'
  say(_unkeyed?'NO THROWABLE ON THE TACTICAL BELT':'NO THROWABLES LEFT');   // v22.xx (R52)
'@

SubRx @'
      if(!G.sim){ say('Too tired to roll.'); blip('clank'); }
'@ @'
      if(!G.sim){ say('TOO TIRED TO ROLL'); blip('clank'); }   // v22.xx (R52)
'@

SubRx @'
  if(!G.sim) say('No '+((ITEMS[tk]&&ITEMS[tk].name)||'throwable')+' left. '+gunKeyLine());
'@ @'
  if(!G.sim) say(('No '+((ITEMS[tk]&&ITEMS[tk].name)||'throwable')+' left').toUpperCase(),'info',{sub:gunKeyLine()});   // v22.xx (R52): the gun key as the detail
'@

SubRx @'
  if(p.cooking){ if(!G.sim) say('Throw the one in your hand first.'); return; }   // v13.62: one grenade at a time
'@ @'
  if(p.cooking){ if(!G.sim) say('THROW THE ONE IN YOUR HAND FIRST'); return; }   // v13.62: one grenade at a time   // v22.xx (R52)
'@

SubRx @'
        if(!G.sim) say('No '+(HSC.name||'throwable')+' left. '+gunKeyLine());
'@ @'
        if(!G.sim) say(('No '+(HSC.name||'throwable')+' left').toUpperCase(),'info',{sub:gunKeyLine()});   // v22.xx (R52)
'@

SubRx @'
      if(HSC.count===0){ if(!G.sim) say('No '+(HSC.name||'item')+' left. '+gunKeyLine()); }
'@ @'
      if(HSC.count===0){ if(!G.sim) say(('No '+(HSC.name||'item')+' left').toUpperCase(),'info',{sub:gunKeyLine()}); }   // v22.xx (R52)
'@

SubRx @'
  if(p.jam>0){ p.jam-=dt; if(p.jam<=0&&!G.sim) say('Cleared.'); }
'@ @'
  if(p.jam>0){ p.jam-=dt; if(p.jam<=0&&!G.sim) say('JAM CLEARED'); }   // v22.xx (R52)
'@

SubRx @'
            say(p.wep.name+' jammed.');
'@ @'
            say((p.wep.name+' jammed').toUpperCase());   // v22.xx (R52)
'@

SubRx @'
var VER='23.04';
'@ @'
var VER='23.05';
'@

$pat = "(?m)^  now:'v23\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.05: Tactical belt and gun lines read as caps callouts with the slot word, such as MEDKIT TO SLOT 9 and SHOTGUN EQUIPPED. Check 23.05 fails on v23.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
