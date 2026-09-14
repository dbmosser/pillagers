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
  {v:'14.30',what:
'@ @'
  {v:'14.31',what:'a lightning bolt does not reach the player under a roof: a bolt 60 units from him in the open with a clear line hits him, and a bolt 40 units from him inside a building does not (weather audit finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof strikeTick!=='function'||typeof roofAt!=='function'||typeof losClear!=='function'||typeof WEATHER==='undefined') return 'SKIP: no storm strikes in this build';
     var storm=null; for(var i=0;i<WEATHER.length;i++) if(WEATHER[i].lightning){ storm=WEATHER[i]; break; }
     if(!storm) return 'SKIP: no lightning weather';
     var bad=[], hits=0, _dp=damagePlayer, g0=null, wx0=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; wx0=g.wx;
       g.ents.length=0; p.downed=false;
       g.wx=storm; g.wxNext=null; g.strikeAt=999;
       damagePlayer=function(){ hits++; };
       var bolt=function(x,y){ g.strikes=[{x:x,y:y,t:0.001,hit:0}]; hits=0; strikeTick(0.016); return hits; };
       // CONTROL: in the open, a bolt 60 units away with a clear line hits him. A fixed scan, no random draw.
       var open=null, dirs=[[60,0],[-60,0],[0,60],[0,-60]];
       for(var gy=300;gy<WORLD_H-300&&!open;gy+=140) for(var gx=300;gx<WORLD_W-300&&!open;gx+=140){
         if(roofAt(gx,gy)) continue;
         for(var dd=0;dd<dirs.length;dd++){ var bx=gx+dirs[dd][0], by=gy+dirs[dd][1];
           if(!roofAt(bx,by)&&losClear(bx,by,gx,gy,g.map.segs)&&losClear(gx-12,gy,gx+12,gy,g.map.segs)){ open={x:gx,y:gy,bx:bx,by:by}; break; } }
       }
       if(!open) return 'SKIP: found no open ground with a clear line for the control';
       p.x=open.x; p.y=open.y;
       if(!bolt(open.bx,open.by)) bad.push('control: a bolt 60 units away in the open did not hit him, so this check cannot see a hit');
       // THE FIX: inside a building, a bolt 40 units away.
       var B=(g.map.buildings||[]).filter(function(b){ return b&&b.w>160&&b.h>160&&roofAt(b.x+b.w/2,b.y+b.h/2); })[0];
       if(!B) bad.push('control: no roofed building big enough to stand in');
       else{
         p.x=B.x+B.w/2; p.y=B.y+B.h/2;
         if(bolt(p.x+40,p.y)) bad.push('a bolt landing 40 units from him inside a building hit him under the roof');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       damagePlayer=_dp;
       try{ if(g0){ g0.strikes=[]; g0.wx=wx0; g0.lightning=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
