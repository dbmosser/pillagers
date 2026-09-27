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

if ($s.Contains("  {v:'16.72',what:")) { throw "check 16.72 is in the fixture already" }

SubRx @'
  {v:'16.71',what:
'@ @'
  {v:'16.72',what:'his controller layout: A rolls, B crouches, RT fires (never under the open backpack), LT and an RS click toggle focus aim, D-LEFT and D-RIGHT set the aim distance, X loots beside a box and reloads otherwise, Y holds the ring search, and the prompts name those buttons',
   run:function(){
     if(typeof pollPad!=='function'||typeof raidKey!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no controller raid path';
     var NGA=navigator.getGamepads, oRK=raidKey, bad=[], taps=[], down={}, val={}, r0, r1, k0=null;
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:!!down[q],value:(val[q]!==undefined?val[q]:(down[q]?1:0)),touched:!!down[q]}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function poll(){ pollPad(); }
     function tap(q){ down={}; val={}; poll(); down[q]=1; poll(); down={}; poll(); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       k0=keys; keys={};
       navigator.getGamepads=pad;
       raidKey=function(code){ taps.push(code); return oRK.apply(null,arguments); };
       G.bagOpen=false; G.mapOpen=false; poll();
       taps=[]; tap(0);
       if(taps.indexOf('Space')<0) bad.push('A did not roll ('+taps.join(',')+')');
       taps=[]; tap(1);
       if(taps.indexOf('ControlLeft')<0) bad.push('B did not crouch ('+taps.join(',')+')');
       down={}; val={7:1}; down[7]=1; poll();
       if(!mouse.down) bad.push('RT held did not fire');
       down={}; val={}; poll();
       down={6:1}; val={6:1}; poll();
       if(!(G.player&&G.player.ads)) bad.push('LT held did not focus aim');
       down={}; val={}; poll();
       r0=PAD.reach; down={15:1}; for(var i=0;i<20;i++) poll(); r1=PAD.reach; down={}; poll();
       if(!(r1>r0)) bad.push('D-RIGHT held did not push the aim distance out ('+r0+' to '+r1+')');
       r0=PAD.reach; down={14:1}; for(i=0;i<20;i++) poll(); r1=PAD.reach; down={}; poll();
       if(!(r1<r0)) bad.push('D-LEFT held did not pull the aim distance in ('+r0+' to '+r1+')');
       down={3:1}; poll();
       if(!keys['KeyX']) bad.push('Y held does not hold the ring search');
       down={}; poll();
       G.nearContainer=null; G.nearPad=null; G.nearDown=null; G.nearDoor=null; G.nearPed=null;
       down={2:1}; poll(); poll();
       if(!keys['KeyR']||keys['KeyE']) bad.push('X held with nothing in reach did not reload');
       down={}; poll();
       G.nearContainer=G.containers[0]||{x:0,y:0};
       down={2:1}; poll(); poll();
       if(!keys['KeyE']||keys['KeyR']) bad.push('X held beside a box did not search it');
       down={}; poll(); G.nearContainer=null;
       var ads0=!!PAD.adsTog; tap(11);
       if(!!PAD.adsTog===ads0||!(G.player&&G.player.ads)) bad.push('RS click did not toggle focus aim on');
       tap(11); poll();
       if(PAD.adsTog) bad.push('a second RS click did not toggle focus aim off');
       if(typeof zoomTarget==='function'&&typeof hotbarSlots==='function'&&hotbarSlots().length>1){
         var z0=zoomTarget(), h0=hotSel(), tN=performance.now();
         down={5:1}; for(i=0;i<2000000&&performance.now()-tN<350;i++) poll();   // pollPad is fast: the hold is timed, not counted
         down={}; poll();
         if(!(zoomTarget()>z0)) bad.push('RB held did not zoom in ('+z0.toFixed(3)+' to '+zoomTarget().toFixed(3)+')');
         if(hotSel()!==h0) bad.push('RB held also changed the belt slot');
         setZoom(z0); h0=hotSel(); tap(5);
         if(hotSel()===h0) bad.push('an RB tap did not change the belt slot');
       }
       G.bagOpen=true; down={7:1}; val={7:1}; poll();
       if(mouse.down) bad.push('RT fired under the open backpack');
       down={}; val={}; poll(); G.bagOpen=false;
       if(typeof keyLabel==='function'){ var _po=PAD.on; PAD.on=true; if(keyLabel('Space')!=='A'||keyLabel('ControlLeft')!=='B'||keyLabel('KeyG')!=='RT'||keyLabel('KeyR')!=='X'||keyLabel('KeyX')!=='Y') bad.push('the prompts name '+keyLabel('Space')+' for the roll, '+keyLabel('ControlLeft')+' for crouch, '+keyLabel('KeyG')+' for use, '+keyLabel('KeyR')+' for reload and '+keyLabel('KeyX')+' for the ring search'); PAD.on=_po; }
     } finally { navigator.getGamepads=NGA; raidKey=oRK; try{ down={}; val={}; mouse.down=false; if(G&&G.player) G.player.ads=false; keys=k0||{}; G.crouchTog=false; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.71',what:
'@

# His layout moved crouch to B (13.36 pressed the right stick) and counts B crouches as its action (16.58 counted rolls).
SubRx @'
     var T0=performance.now(), RS=11, LS=10;
'@ @'
     var T0=performance.now(), RS=1, LS=10;   // v16.72, his layout: B crouches
'@
SubRx @'
       raidKey=function(code){ if(code==='Space') rolls++; return oRK.apply(null,arguments); };
'@ @'
       raidKey=function(code){ if(code==='Space'||code==='ControlLeft') rolls++; return oRK.apply(null,arguments); };   // v16.72: B crouches now
'@

# Three checks were written around A as the trigger; his layout fires on RT, and check 16.72 covers RT.
foreach ($v in '14.24','14.21','14.20') {
  $rx = "(\{v:'" + [regex]::Escape($v) + "',what:'[^\n]*\n   run:function\(\)\{)"
  $c = ([regex]::Matches($script:s, $rx)).Count
  if ($c -ne 1) { throw "check $v head matched $c times" }
  $script:s = [regex]::Replace($script:s, $rx, { param($m) $m.Groups[1].Value + "`n     if(typeof PADTAP==='object'&&PADTAP[0]==='Space') return 'SKIP: his layout of v16.72 fires on RT, not A; check 16.72 covers the trigger';" })
}

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
