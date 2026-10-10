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

if ($s.Contains("  {v:'22.22',what:")) { throw "check 22.22 is in the fixture already" }

SubRx @'
  {v:'22.21',what:
'@ @'
  {v:'22.22',what:'in a raid at full health with only Medkits, a press on the Medical belt key picks up no Bandage, and once hurt the same press picks up the Medkit',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof hotbarSlots!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse) return 'SKIP: no raid belt here';
     var bad=[], oSay=say, oBlip=blip, g=null, sl, hi=-1, i, hc0, mx0=mouse.x, my0=mouse.y, d1, d2;
     function press(){ g.hotCells=[{x:7,y:9,w:30,h:30,i:hi}]; mouse.x=21; mouse.y=23; g.drag=null; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); return g.drag; }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       say=function(){}; blip=function(){};
       hc0=g.hotCells;
       g.bagOpen=false; g.mapOpen=false; g.trade=null;
       g.bag=['medkit','medkit']; g.player.healQ=0; g.player.hp=g.player.maxhp;
       sl=hotbarSlots(); for(i=0;i<sl.length;i++) if(sl[i].k==='heal'){ hi=i; break; }
       if(hi<0) return 'SKIP: staging: no Medical key on the belt';
       if(sl[hi].icon!=='bandage'||sl[hi].count!==2) return 'SKIP: staging: at full health the Medical key shows '+sl[hi].icon+' x'+sl[hi].count;
       d1=press();
       if(d1&&d1.key==='bandage') bad.push('at full health with only Medkits a press on the Medical key picked up a Bandage the backpack does not hold');
       else if(d1) bad.push('at full health the press on the Medical key picked up '+d1.key);
       g.player.hp=Math.max(1,Math.round(g.player.maxhp*0.3));
       sl=hotbarSlots();
       if(!(sl[hi]&&sl[hi].k==='heal'&&sl[hi].icon==='medkit')) bad.push('control: hurt, the Medical key shows '+(sl[hi]&&sl[hi].icon));
       else { d2=press(); if(!(d2&&d2.key==='medkit')) bad.push('control: hurt, a press on the Medical key did not pick up the Medkit'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; blip=oBlip; mouse.x=mx0; mouse.y=my0;
       try{ var g2=__state(); if(g2){ g2.drag=null; if(hc0!==undefined) g2.hotCells=hc0; if(!g2.over){ g2.bag=[]; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
