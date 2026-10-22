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

if ($s.Contains("  {v:'34.02',what:")) { throw "check 34.02 is in the fixture already" }

SubRx @'
  {v:'34.01',what:
'@ @'
  {v:'34.02',what:'map intel elites draw cream edged triangles rather than plain coloured dots',
   run:function(){
     var g=null, oldMove=ctx.moveTo,oldLine=ctx.lineTo,oldBegin=ctx.beginPath,oldFill=ctx.fill,oldStroke=ctx.stroke,path=[],found=0,edged=0, expect, e, z;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'no raid staged';
       g.intel=true; g.mapOpen=true; g.bagOpen=false; g.paused=true;
       e=g.ents[0]; if(!e) return 'no entity staged'; e.elite=true; e.downed=false; e.x=WORLD_W*.48; e.y=WORLD_H*.58;
       var p=mapProj(); z=hudRes(); expect=[p.ox+e.x*p.sc,p.oy+e.y*p.sc];
       function triangle(){return path.length===3&&Math.abs(path[0][0]-expect[0])<.1&&Math.abs(path[0][1]-(expect[1]-5*z))<.1&&Math.abs(path[1][0]-(expect[0]+4.5*z))<.1&&Math.abs(path[2][0]-(expect[0]-4.5*z))<.1;}
       ctx.beginPath=function(){path=[];return oldBegin.apply(this,arguments);};
       ctx.moveTo=function(x,y){path.push([x,y]);return oldMove.apply(this,arguments);};
       ctx.lineTo=function(x,y){path.push([x,y]);return oldLine.apply(this,arguments);};
       ctx.fill=function(){if(triangle()&&this.fillStyle===UIC.r_elite) found++;return oldFill.apply(this,arguments);};
       ctx.stroke=function(){if(triangle()&&this.strokeStyle===UIC.tx_1&&Math.abs(this.lineWidth-1.5*z)<.1) edged++;return oldStroke.apply(this,arguments);};
       drawMapOverlay();
       return !found?'elite intel has no triangle':!edged?'elite intel triangle has no cream edge':null;
     }finally{
       ctx.moveTo=oldMove;ctx.lineTo=oldLine;ctx.beginPath=oldBegin;ctx.fill=oldFill;ctx.stroke=oldStroke;
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'34.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
