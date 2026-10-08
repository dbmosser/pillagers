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

if ($s.Contains("  {v:'20.44',what:")) { throw "check 20.44 is in the fixture already" }

SubRx @'
  {v:'20.43',what:
'@ @'
  {v:'20.44',what:'focus aim toggled on a pad never rides into the next raid: with RS clicked to focus aim and the raid ended with it still on, the next raid starts with the toggle off, and its first pad frame with nothing held is not in focus aim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof pollPad!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no raid or pad path in this fixture';
     var bad=[], own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), NG=navigator.getGamepads, stubbed=false, PK={}, k, pad=null, oc;
     function mk(down){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:q===down,value:q===down?1:0,touched:q===down}); return {connected:true,id:'focus aim check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}; }
     function poll(down){ pad=mk(down); pollPad(); }
     function shut(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     for(k in PAD) PK[k]=PAD[k];
     try{ navigator.getGamepads=function(){ return [pad]; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ if(own) navigator.getGamepads=NG; else delete navigator.getGamepads; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       shut();
       // RS clicked once on a pad in the raid, the way a hand does it: down, then up.
       PAD.adsTog=false; PAD.adsT=0;
       poll(-1); poll(-1); poll(11); poll(-1);
       if(!PAD.adsTog||!G.player.ads) return 'SKIP: staging: an RS click did not turn focus aim on here (toggle '+PAD.adsTog+', aim '+G.player.ads+')';
       // The raid ends with focus aim still on, and the pad keeps polling under the end-of-raid card.
       G.player.downed=false; __endRaid('extract');
       oc=document.getElementById('outcome');
       if(!(oc&&oc.classList.contains('on'))) return 'SKIP: staging: the end-of-raid card did not come up';
       poll(-1); poll(-1);
       __topClear(); __cleanProfile();
       // The next raid.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no second raid';
       if(PAD.adsTog) bad.push('the next raid starts with the focus aim toggle from the last raid still on');
       shut(); poll(-1);
       if(G.player.ads) bad.push('on the first pad frame of the next raid, with nothing held, the player is in focus aim (slow walk, no sprint)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad(); }catch(_p){}
       try{ if(own) navigator.getGamepads=NG; else delete navigator.getGamepads; }catch(_r){}
       for(k in PAD) if(!(k in PK)) delete PAD[k];
       for(k in PK) PAD[k]=PK[k];
       try{ padBodyCls(); }catch(_b){}
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
