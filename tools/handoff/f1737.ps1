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

if ($s.Contains("  {v:'17.37',what:")) { throw "check 17.37 is in the fixture already" }

SubRx @'
  {v:'17.36',what:
'@ @'
  {v:'17.37',what:'controller rumble: a hit buzzes the pad of the player hit, harder for a bigger hit; the Settings row turns it off; a pad nobody touched for a minute never buzzes; on one PC the player 2 window asks the player 1 window, which buzzes the pad it reads for him',
   run:function(){
     if(typeof padRumble!=='function'||typeof RUMBLE!=='object') return 'this build has no controller rumble';
     if(typeof pollPad!=='function'||typeof damagePlayer!=='function'||typeof netSameOnMsg!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: no raid or pad path in this fixture';
     var own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), NG=navigator.getGamepads, calls=[], sent=[], bad=[];
     var keep={same:NET.same,pair:NET.pair}, oPost=netSamePost, k0=keys, r0=CFG.rumble, sv={gp:RUMBLE.gp,other:RUMBLE.other,usedAt:RUMBLE.usedAt,at:RUMBLE.at,s:RUMBLE.s};
     function pad(ax){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:false,value:0,touched:false});
       return {connected:true,id:'rumble check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[ax||0,0,0,0],
         vibrationActuator:{playEffect:function(t,o){ calls.push(o); return Promise.resolve('complete'); }}}; }
     function hit(n){ RUMBLE.at=0; RUMBLE.s=0; var p=G.player; p.iv=0; p.hp=100; p.downed=false; damagePlayer(n,'other','check'); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||G.over) return 'SKIP: staging: no raid';
       CFG.rumble=1;
       navigator.getGamepads=function(){ return [pad(0.9)]; }; pollPad();
       navigator.getGamepads=function(){ return [pad(0)]; }; pollPad();
       calls.length=0; hit(10);
       if(!calls.length) bad.push('a hit on a player whose pad is in use did not buzz it');
       var small=calls.length?calls[calls.length-1].strongMagnitude:0;
       calls.length=0; hit(40);
       var big=calls.length?calls[calls.length-1].strongMagnitude:0;
       if(!(big>small)) bad.push('a bigger hit did not buzz harder ('+small+' then '+big+')');
       CFG.rumble=0; calls.length=0; hit(20);
       if(calls.length) bad.push('the pad buzzed with Controller rumble set to Off');
       CFG.rumble=1; RUMBLE.usedAt=-1e9; calls.length=0; hit(20);
       if(calls.length) bad.push('a pad nobody touched for a minute buzzed');
       navigator.getGamepads=function(){ return []; };
       NET.same='p2'; NET.pair='zqxrum'; RUMBLE.gp=null; RUMBLE.usedAt=performance.now();
       netSamePost=function(m){ sent.push(m); return true; };
       hit(20);
       if(!sent.some(function(m){ return m&&m.t==='rumble'&&m.s>0; })) bad.push('a hit in the player 2 window did not ask the player 1 window to buzz his pad');
       NET.same='host'; RUMBLE.other=pad(0); calls.length=0;
       netSameOnMsg({t:'rumble',pair:'zqxrum',s:0.5,ms:120});
       if(!calls.length) bad.push('the player 1 window did not buzz the pad it reads for player 2');
     } finally {
       if(own) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(e){} }
       netSamePost=oPost; NET.same=keep.same; NET.pair=keep.pair; CFG.rumble=r0; keys=k0||{};
       RUMBLE.gp=sv.gp; RUMBLE.other=sv.other; RUMBLE.usedAt=sv.usedAt; RUMBLE.at=sv.at; RUMBLE.s=sv.s;
       try{ pollPad(); }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
