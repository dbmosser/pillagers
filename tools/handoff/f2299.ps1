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

if ($s.Contains("  {v:'22.99',what:")) { throw "check 22.99 is in the fixture already" }

SubRx @'
  {v:'22.98',what:
'@ @'
  {v:'22.99',what:'the offer line, the hostile count on a called ring and the teammate Waypoint read as caps callouts: an offer reads NAME OFFERS ITEM with [T] TAKE and the seconds, the giver reads OFFER SENT with ITEM TO NAME and the seconds, two hostiles converging on the ring read 2 HOSTILES CLOSING IN, and a teammate mark reads NAME WAYPOINT with its distance, never Marker',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof drawGiftLine!=='function'||typeof drawHUD!=='function'||typeof netWpDraw!=='function'||typeof GIFT_T==='undefined'||typeof PAD==='undefined') return 'SKIP: no offer line, ring band or teammate Waypoint here';
     var bad=[], g=null, p=null, z, s, i, tr, nm, NM, TK, hit, live=[], keep={on:NET.on,seat:NET.seat,roster:NET.roster,wps:NET.wps}, padK=PAD.on,
         OY=' offers '+'you', CV='conver'+'ging', MK='MARK'+'ER', KID='ZQX'+'KID';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.bagOpen=false; g.mapOpen=false; p.downed=false;
       NET.on=false; NET.seat=0; NET.roster=[{seat:0,name:'Host'},{seat:1,name:'Zqxkid'}];
       PAD.on=false; TK='['+keyLabel('KeyT','T')+'] TAKE';
       nm=ITEMS.codex?ITEMS.codex.name:'codex'; NM=String(nm).toUpperCase();
       // ONE: an offer to this player
       g.giftOut=null; g.giftIn={id:'tr8a',k:'codex',from:1,t:g.t};
       s=String(drawGiftLine()||'');
       if(s.indexOf(KID+' OFFERS '+NM)!==0||s.indexOf(TK)<0||!/\d+s$/.test(s)||s.indexOf(OY)>=0) bad.push('an offer reads '+JSON.stringify(s)+', not '+KID+' OFFERS '+NM+' with '+TK+' and the seconds');
       // TWO: his own offer, waiting
       g.giftIn=null; g.giftOut={id:'tr8b',k:'codex',to:1,t:g.t};
       s=String(drawGiftLine()||'');
       if(s.indexOf('OFFER '+'SENT')!==0||s.indexOf(NM+' TO '+KID)<0||!/\d+s$/.test(s)||s.indexOf('Wait'+'ing')>=0) bad.push('the giver reads '+JSON.stringify(s)+', not OFFER SENT with '+NM+' TO '+KID+' and the seconds');
       g.giftOut=null;
       // THREE: two hostiles closing on the ring he called
       z=g.active; if(!z) return 'SKIP: staging: no ring';
       for(i=0;i<g.ents.length&&live.length<2;i++) if(g.ents[i]&&g.ents[i].hp>0) live.push(g.ents[i]);
       if(live.length<2) return 'SKIP: staging: fewer than two live hostiles';
       g.ents.length=0; g.ents.push(live[0],live[1]);
       live[0].state='chase'; live[1].state='chase'; live[0].x=z.x+400; live[0].y=z.y; live[1].x=z.x-400; live[1].y=z.y;
       g.beaconT=20; z.beaconT=20; g.shipHold=null; p.x=z.x; p.y=z.y;
       tr=__textTrace(function(){ drawHUD(); });
       hit=null;
       for(i=0;i<tr.length;i++){ if(tr[i].t.indexOf(CV)>=0) bad.push('the ring band reads '+JSON.stringify(tr[i].t)); if(/^2 HOSTILES CLOSING IN$/.test(tr[i].t)) hit=tr[i].t; }
       if(!hit) bad.push('two hostiles converging on the called ring were not drawn as 2 HOSTILES CLOSING IN');
       // FOUR: a teammate Waypoint
       NET.wps={1:{x:p.x+300,y:p.y+40}};
       tr=__textTrace(function(){ ctx.save(); try{ netWpDraw(); } finally { ctx.restore(); } });
       hit=null;
       for(i=0;i<tr.length;i++){ if(tr[i].t.indexOf(MK)>=0) bad.push('the teammate mark reads '+JSON.stringify(tr[i].t)); if(tr[i].t.indexOf(KID+' WAY'+'POINT')===0&&/\d+m$/.test(tr[i].t)) hit=tr[i].t; }
       if(!hit) bad.push('the teammate mark was not drawn as '+KID+' WAYPOINT with its distance');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       PAD.on=padK; NET.on=keep.on; NET.seat=keep.seat; NET.roster=keep.roster; NET.wps=keep.wps; keys={};
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; if(!g2.over){ g2.beaconT=null; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
