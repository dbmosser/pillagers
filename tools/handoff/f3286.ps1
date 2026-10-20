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

if ($s.Contains("  {v:'32.86',what:")) { throw "check 32.86 is in the fixture already" }

SubRx @'
  {v:'32.85',what:
'@ @'
  {v:'32.86',what:'the air-strike plate keeps its belt right edge and clears the actual held-item panel at 1080p and 4k for host and join layouts, while an empty hand keeps its former position',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof airPlateAt!=='function'||typeof drawHand!=='function') return 'SKIP: no raid or held-item renderer';
     var bad=[], g, p, ow=W, oh=H, hp=hudPlate, hc, oldHand, oldWheel, gear, edges, nr=NET.role, ns=NET.seat, no=NET.on, sizes=[[1920,1080],[3840,2160]], roles=['host','join'], i, j, z, bw, bh, y, right, hand, box, empty, expectedY;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; hc=g.hotCells; oldHand=p.hand; oldWheel=g.wheel; gear=HUDBOX.gear; edges=EDGEBOX;
       HUDBOX.gear=null; EDGEBOX={}; g.wheel=null; NET.on=false;
       for(i=0;i<sizes.length;i++) for(j=0;j<roles.length;j++){
         W=sizes[i][0]; H=sizes[i][1]; NET.role=roles[j]; NET.seat=j; z=Math.max(1,hudRes());
         y=H-110*z; right=W/2+160*z; bw=LH(200)*z; bh=LH(28)*z;
         g.hotCells=[{x:W/2-200*z,y:y,w:80*z,h:80*z},{x:right-80*z,y:y,w:80*z,h:80*z}];
         p.hand={k:'bandage',t:0.4,len:1.2}; hand=null;
         hudPlate=function(x,y,w,h){ if(!hand) hand={x:x,y:y,w:w,h:h}; return hp.apply(this,arguments); };
         try{ drawHand(); }finally{hudPlate=hp;}
         if(!hand){bad.push(W+' '+roles[j]+': no held-item panel');continue;}
         box=airPlateAt(bw,bh,z);
         if(box.x<hand.x+hand.w&&box.x+bw>hand.x&&box.y<hand.y+hand.h&&box.y+bh>hand.y) bad.push(W+' '+roles[j]+': air-strike plate overlaps the held item');
         if(box.x<hand.x+hand.w&&box.y+bh>hand.y-Math.round(8*z)) bad.push(W+' '+roles[j]+': the vertical fallback has no 8px gap');
         if(Math.abs(box.x+bw-right)>1) bad.push(W+' '+roles[j]+': the plate lost the belt right edge');
         if(box.x<0||box.y<0||box.x+bw>W||box.y+bh>H) bad.push(W+' '+roles[j]+': the plate leaves the screen');
         p.hand=null; empty=airPlateAt(bw,bh,z); expectedY=Math.round(y-64*z-Math.round(8*z)-bh);
         if(Math.abs(empty.x+bw-right)>1||Math.abs(empty.y-expectedY)>1) bad.push(W+' '+roles[j]+': an empty hand changed the former placement');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       hudPlate=hp; W=ow; H=oh; NET.role=nr; NET.seat=ns; NET.on=no;
       if(g&&p){g.hotCells=hc;p.hand=oldHand;g.wheel=oldWheel;} if(gear!==undefined)HUDBOX.gear=gear; if(edges!==undefined)EDGEBOX=edges;
       try{if(__state()&&!__state().over)__endRaid('abandon');}catch(_e){} __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'32.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
