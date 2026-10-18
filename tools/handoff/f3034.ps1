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

if ($s.Contains("  {v:'30.34',what:")) { throw "check 30.34 is in the fixture already" }

SubRx @'
  {v:'30.33',what:
'@ @'
  {v:'30.34',what:'the raider rises from underground at the start of a raid (1.3 s, any input ends it, drawn clipped at the ground) and sinks again over the boarding hold; a dropped pile of rare loot stands in a rarity light shaft, an unopened box never does (his picks 77 and 75)',
   run:function(){
     if(typeof ascentSink!=='function'||typeof lootShaft!=='function') return 'no rise from underground and no rarity light shaft (no ascentSink, no lootShaft)';
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, GR=CanvasGradient.prototype, ot=PR.translate, oa=GR.addColorStop, g=null, p, s0, s1, s2, i, k, rk=null, ck=null, hits=0, tr=0, c1, z, e, sh;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player;
       if(!g.rise) return 'a new raid starts with no rise from underground';
       s0=ascentSink(p);
       if(!(s0>40)) return 'the raider starts only '+s0+' px below the ground, not under it';
       PR.translate=function(x,y){ if(y>0&&(/ascentBegin/).test(String(new Error().stack))) tr++; return ot.apply(this,arguments); };
       __frame(); __frame();
       PR.translate=ot;
       if(!tr) return 'the rise is not drawn: the raider is not let down and clipped at the ground';
       g.t=g.rise.t0+0.65; s1=ascentSink(p);
       if(!(s1>0&&s1<s0)) return 'half way through the rise he is '+s1+' px down (start '+s0+')';
       g.t=g.rise.t0+RISE_SEC+0.3; s2=ascentSink(p);
       if(s2!==0||g.rise) return 'the rise is not over after '+(RISE_SEC+0.3)+' s';
       if(RISE_SEC>=2) return 'the rise is 2 s or longer';
       g.rise={t0:g.t,dur:RISE_SEC};
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'F13',key:'F13'}));
       if(ascentSink(p)!==0||g.rise) return 'a key press does not skip the rise';
       g.rise={t0:g.t,dur:RISE_SEC}; p.moving=true;
       if(ascentSink(p)!==0) return 'walking does not skip the rise';
       p.moving=false;
       if(!g.zones||!g.zones.length) return 'SKIP: no extraction zone';
       z=g.zones[0]; e=z.pullT;
       z.pullT=0.7; sh=ascentSink(p);
       if(!(sh>5&&sh<ASC_SINK-5)) return 'half way through the boarding hold he is '+sh+' px down';
       z.pullT=1.4; if(!(ascentSink(p)>=ASC_SINK-0.01)) return 'at the end of the boarding hold he has not sunk out of sight';
       z.pullT=null; if(ascentSink(p)!==0) return 'he is still sunk with no boarding hold';
       z.pullT=e;
       for(k in ITEMS){ if(ITEMS[k]&&!/^key_/.test(k)){ if(!rk&&dispR(k)==='rare') rk=k; if(!ck&&dispR(k)==='common') ck=k; } }
       if(!rk||!ck) return 'SKIP: no rare and common item to drop';
       g.rise=null;
       p.x=Math.round(p.x); 
       g.bag.push(rk); dropItem(g.bag.length-1); c1=g.containers[g.containers.length-1];
       if(!c1||!c1.dropped||c1.best!=='rare') return 'the dropped pile is not marked rare: '+(c1&&c1.best);
       p.x=c1.x; p.y=c1.y+40;
       GR.addColorStop=function(){ if((/lootShaft/).test(String(new Error().stack))) hits++; return oa.apply(this,arguments); };
       __frame(); __frame();
       if(!hits) return 'a dropped rare pile has no rarity light shaft';
       hits=0; c1.dropped=0; __frame(); __frame();
       if(hits) return 'a box that was not dropped (an unknown one) shows a rarity shaft';
       c1.dropped=1; c1.best='common'; hits=0; __frame(); __frame();
       if(hits) return 'a common pile shows a rarity shaft';
       return null;
     } finally {
       PR.translate=ot; GR.addColorStop=oa;
       try{ if(g) g.rise=null; }catch(_r){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
