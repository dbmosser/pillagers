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

if ($s.Contains("  {v:'33.41',what:")) { throw "check 33.41 is in the fixture already" }

SubRx @'
  {v:'33.40',what:
'@ @'
  {v:'33.41',what:'the air-strike plate stands 8 px (times the HUD zoom) over the belt at 1080p and 4k, and never overlaps the belt or an item in hand',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof airPlateAt!=='function'||typeof drawHand!=='function') return 'SKIP: no raid or held-item renderer';
     var bad=[], g, p, ow=W, oh=H, hp=hudPlate, hc, oldHand, oldWheel, gear, edges, nr=NET.role, ns=NET.seat, no=NET.on, sizes=[[1920,1080],[3840,2160]], i, z, bw, bh, y, right, hand, box, k, c;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; hc=g.hotCells; oldHand=p.hand; oldWheel=g.wheel; gear=HUDBOX.gear; edges=EDGEBOX;
       HUDBOX.gear=null; EDGEBOX={}; g.wheel=null; NET.on=false; NET.role='host'; NET.seat=0;
       for(i=0;i<sizes.length;i++){
         W=sizes[i][0]; H=sizes[i][1]; z=Math.max(1,hudRes());
         y=H-110*z; right=W/2+160*z; bw=LH(200)*z; bh=LH(28)*z;
         g.hotCells=[{x:W/2-200*z,y:y,w:80*z,h:80*z},{x:right-80*z,y:y,w:80*z,h:80*z}];
         p.hand=null; box=airPlateAt(bw,bh,z);
         if(Math.abs((y-(box.y+bh))-Math.round(8*z))>1) bad.push(W+': the gap over the belt is '+Math.round(y-(box.y+bh))+', not '+Math.round(8*z));
         p.hand={k:'bandage',t:0.4,len:1.2}; hand=null;
         hudPlate=function(x,y2,w,h){ if(!hand) hand={x:x,y:y2,w:w,h:h}; return hp.apply(this,arguments); };
         try{ drawHand(); }finally{hudPlate=hp;}
         if(!hand){bad.push(W+': no held-item panel');continue;}
         box=airPlateAt(bw,bh,z);
         if(box.x<hand.x+hand.w&&box.x+bw>hand.x&&box.y<hand.y+hand.h&&box.y+bh>hand.y) bad.push(W+': plate overlaps the held item');
         for(k=0;k<g.hotCells.length;k++){ c=g.hotCells[k]; if(box.x<c.x+c.w&&box.x+bw>c.x&&box.y<c.y+c.h&&box.y+bh>c.y) bad.push(W+': plate overlaps the belt'); }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       hudPlate=hp; W=ow; H=oh; NET.role=nr; NET.seat=ns; NET.on=no;
       if(g&&p){g.hotCells=hc;p.hand=oldHand;g.wheel=oldWheel;} if(gear!==undefined)HUDBOX.gear=gear; if(edges!==undefined)EDGEBOX=edges;
       try{if(__state()&&!__state().over)__endRaid('abandon');}catch(_e){} __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'33.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
