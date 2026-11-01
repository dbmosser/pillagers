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

# UNDERCROFT: WHOEVER STANDS LOWER ON SCREEN IS DRAWN IN FRONT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  DR.push({k:p.y-((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y)*0.5:0),pl:1});

'@ @'
  // v36.xx (cw-crowdsort), HIS NOTE (2026-10-31, a picture of his pillager drawn over a crowd pillager standing lower on screen): "if the player is
  // standing above a another pillager in the undercroft, then the player should effectively be behind them". The crowd used to be drawn in one
  // pass before him, so a pillager in front of him (lower on screen) was painted under him. Each crowd body is queued here with its feet y as the
  // sort key, the same list as the walls, the posts, the party and him, so whoever stands lower on screen is drawn later and covers the one behind.
  // THE CROWD, v6.54: idle, a slow bob, and the ones in a group shift their stance now and then so a conversation reads as a conversation.
  var _cw=HB.crowd||[];
  // v8.07: the errands tick here rather than in updateHubWorld, because this
  // pass is the one that always has a dt and keeps running behind an open
  // modal. The floor should not freeze because he opened the Shop.
  tickHubCrowd(dt);
  // v7.53, his live report: nobody stands on anybody. Any pair closer than
  // 24 units shares a push apart, a few pixels a frame, so a stack melts in
  // under a second and the hired man cannot merge with a huddle he follows
  // you into. Bounds-clamped; the pace/talk offsets ride on top untouched.
  for(var _si2=0;_si2<_cw.length;_si2++){
    for(var _sj2=_si2+1;_sj2<_cw.length;_sj2++){
      var _A2=_cw[_si2],_B2=_cw[_sj2];
      if(_A2.away>0||_B2.away>0) continue;   // v8.07: not in the room
      var _sx2=(_B2.x+(_B2.hx||0))-(_A2.x+(_A2.hx||0)),
          _sy2=(_B2.y+(_B2.hy||0))-(_A2.y+(_A2.hy||0)),
          _sd2=Math.hypot(_sx2,_sy2);
      if(_sd2<26){
        if(_sd2<0.001){ _sx2=Math.cos(_si2*2.4); _sy2=Math.sin(_si2*2.4); _sd2=1; }
        var _pu2=Math.min(84*dt,(26-_sd2)*30*dt);
        _A2.x=clamp(_A2.x-_sx2/_sd2*_pu2,34,HUBW-34); _A2.y=clamp(_A2.y-_sy2/_sd2*_pu2,34,HUBH-34);
        _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
        collide(_A2,HB.dwalls); collide(_B2,HB.dwalls);   // v10.60: a shove never lands anyone in a wall
      }
    }
  }
  for(var _ci=0;_ci<_cw.length;_ci++){
    var _c=_cw[_ci];
    // v6.64, his note: they move. A worker paces a short beat between two points,
    // which reads as carrying something back and forth; a talker sways and turns as
    // if mid-sentence. Both are pure functions of the clock, so nothing to update.
    var _mv=0;
    if(_c.mercTag&&HB.player){
      var _dxm=HB.player.x-_c.x,_dym=HB.player.y-_c.y,_dm=Math.hypot(_dxm,_dym)||1;
      if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; collide(_c,HB.dwalls); }   // v10.60
      _c.face=Math.atan2(_dym,_dxm);
    }
    if(_c.away>0) continue;                  // v8.07: he is up top
    if(_c.walking){
      // v8.07: travelling owns the body. The pacing offset would fight the
      // walk and the conversational sway would read as a stagger.
      _c.hx=0; _c.hy=0; _mv=1;
    } else if(_c.job==='work'){
      var _w=Math.sin(HB.t*_c.rate+_c.t0);
      _c.hx=Math.cos(_c.face)*_w*_c.amp;
      _c.hy=Math.sin(_c.face)*_w*_c.amp*0.5;
      _mv=Math.abs(Math.cos(HB.t*_c.rate+_c.t0))>0.35?1:0;
    } else if(_c.job==='talk'){
      _c.hx=Math.sin(HB.t*0.8+_c.t0)*2.2;
      _c.hy=Math.cos(HB.t*0.6+_c.t0)*1.4;
    }
    var _ph=_c.walking?((_c.step||0)*3)
                      :Math.sin(HB.t*(_c.job==='work'?3.4:1.6)+_c.t0)*(_c.job==='work'?1.5:0.5);
    var _fc=_c.face+((_c.talk&&!_c.walking)?Math.sin(HB.t*0.7+_c.t0)*0.34:0);
    DR.push({k:_c.y+(_c.hy||0),cr:_c,ph:_ph,fc:_fc,mv:_mv});
  }
  DR.push({k:p.y-((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y)*0.5:0),pl:1});

'@

SubRx @'
    } else {
      // THE CROWD, v6.54. Behind him in the draw order and idle: a slow bob, and the
      // ones in a group shift their stance now and then so a conversation reads as a
      // conversation rather than as furniture facing each other.
      var _cw=HB.crowd||[];
      // v8.07: the errands tick here rather than in updateHubWorld, because this
      // pass is the one that always has a dt and keeps running behind an open
      // modal. The floor should not freeze because he opened the Shop.
      tickHubCrowd(dt);
      // v7.53, his live report: nobody stands on anybody. Any pair closer than
      // 24 units shares a push apart, a few pixels a frame, so a stack melts in
      // under a second and the hired man cannot merge with a huddle he follows
      // you into. Bounds-clamped; the pace/talk offsets ride on top untouched.
      for(var _si2=0;_si2<_cw.length;_si2++){
        for(var _sj2=_si2+1;_sj2<_cw.length;_sj2++){
          var _A2=_cw[_si2],_B2=_cw[_sj2];
          if(_A2.away>0||_B2.away>0) continue;   // v8.07: not in the room
          var _sx2=(_B2.x+(_B2.hx||0))-(_A2.x+(_A2.hx||0)),
              _sy2=(_B2.y+(_B2.hy||0))-(_A2.y+(_A2.hy||0)),
              _sd2=Math.hypot(_sx2,_sy2);
          if(_sd2<26){
            if(_sd2<0.001){ _sx2=Math.cos(_si2*2.4); _sy2=Math.sin(_si2*2.4); _sd2=1; }
            var _pu2=Math.min(84*dt,(26-_sd2)*30*dt);
            _A2.x=clamp(_A2.x-_sx2/_sd2*_pu2,34,HUBW-34); _A2.y=clamp(_A2.y-_sy2/_sd2*_pu2,34,HUBH-34);
            _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
            collide(_A2,HB.dwalls); collide(_B2,HB.dwalls);   // v10.60: a shove never lands anyone in a wall
          }
        }
      }
      for(var _ci=0;_ci<_cw.length;_ci++){
        var _c=_cw[_ci];
        // v6.64, his note: they move. A worker paces a short beat between two points,
        // which reads as carrying something back and forth; a talker sways and turns as
        // if mid-sentence. Both are pure functions of the clock, so nothing to update.
        var _mv=0;
        if(_c.mercTag&&HB.player){
          var _dxm=HB.player.x-_c.x,_dym=HB.player.y-_c.y,_dm=Math.hypot(_dxm,_dym)||1;
          if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; collide(_c,HB.dwalls); }   // v10.60
          _c.face=Math.atan2(_dym,_dxm);
        }
        if(_c.away>0) continue;                  // v8.07: he is up top
        if(_c.walking){
          // v8.07: travelling owns the body. The pacing offset would fight the
          // walk and the conversational sway would read as a stagger.
          _c.hx=0; _c.hy=0; _mv=1;
        } else if(_c.job==='work'){
          var _w=Math.sin(HB.t*_c.rate+_c.t0);
          _c.hx=Math.cos(_c.face)*_w*_c.amp;
          _c.hy=Math.sin(_c.face)*_w*_c.amp*0.5;
          _mv=Math.abs(Math.cos(HB.t*_c.rate+_c.t0))>0.35?1:0;
        } else if(_c.job==='talk'){
          _c.hx=Math.sin(HB.t*0.8+_c.t0)*2.2;
          _c.hy=Math.cos(HB.t*0.6+_c.t0)*1.4;
        }
        var _ph=_c.walking?((_c.step||0)*3)
                          :Math.sin(HB.t*(_c.job==='work'?3.4:1.6)+_c.t0)*(_c.job==='work'?1.5:0.5);
        var _fc=_c.face+((_c.talk&&!_c.walking)?Math.sin(HB.t*0.7+_c.t0)*0.34:0);
        var _lk=_c.look||{};
        var _fd2=(_c.fade===undefined)?1:clamp(_c.fade,0,1);
        if(_fd2<1){ wc.save(); wc.globalAlpha=_fd2; }
        drawOp(_c.x+(_c.hx||0),_c.y+(_c.hy||0),_fc,_ph,_c.coat,0,0,'none',0,
          {hero:0,moving:!!_mv,sprint:false,ads:false,hurt:0,rl:0,
           skin:_lk.skin,hair:_lk.hair,hat:_lk.hat,cut:_lk.cut,faceIx:_lk.faceIx,
           beard:_lk.beard,eyes:_lk.eyes,faceMark:_lk.faceMark,boots:_lk.boots,gloves:_lk.gloves,pack:_lk.pack,patch:_lk.patch,tattoo:_lk.tattoo,   // v10.24: the whole look
           build:_lk.build,own:_c});
        if(_fd2<1) wc.restore();
      }

'@ @'
    } else if(it.cr){
      // v36.xx (cw-crowdsort): one crowd body, drawn where its feet y sorts it among the walls, the posts, the party and him.
      var _hcc=it.cr,_hlk=_hcc.look||{};
      var _hfd=(_hcc.fade===undefined)?1:clamp(_hcc.fade,0,1);
      if(_hfd<1){ wc.save(); wc.globalAlpha=_hfd; }
      drawOp(_hcc.x+(_hcc.hx||0),_hcc.y+(_hcc.hy||0),it.fc,it.ph,_hcc.coat,0,0,'none',0,
        {hero:0,moving:!!it.mv,sprint:false,ads:false,hurt:0,rl:0,
         skin:_hlk.skin,hair:_hlk.hair,hat:_hlk.hat,cut:_hlk.cut,faceIx:_hlk.faceIx,
         beard:_hlk.beard,eyes:_hlk.eyes,faceMark:_hlk.faceMark,boots:_hlk.boots,gloves:_hlk.gloves,pack:_hlk.pack,patch:_hlk.patch,tattoo:_hlk.tattoo,   // v10.24: the whole look
         build:_hlk.build,own:_hcc});
      if(_hfd<1) wc.restore();
    } else {

'@

SubRx @'
var VER='36.95';
'@ @'
var VER='36.96';
'@

$pat = "(?m)^  now:'v36\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.96: In the Undercroft you stand behind a pillager who is lower on screen than you, and in front of one who is higher. Check 36.96 fails on v36.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
