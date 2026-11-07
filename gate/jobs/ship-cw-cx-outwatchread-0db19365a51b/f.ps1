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

if ($s.Contains("  {v:'37.55',what:")) { throw "check 37.55 is in the fixture already" }

SubRx @'
  {v:'37.54',what:
'@ @'
  {v:'37.55',what:'waiting status reads at least 32px at 1080p with a 64px bottom gap, without an action or rejoin prompt',run:function(){
    var g=null, text0=ctx.fillText, rect0=ctx.fillRect, draws=[], boxes=[], keep={}, k, staged=false;
    try{
      __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
      __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g) return 'no raid';
      for(k in NET)keep[k]=NET[k]; staged=true;
      NET.on=true; NET.role='host'; NET.specG=g; NET.pings=[]; NET.wps={}; g.player.specOut=1; g.waypoint=null; g.over='extract';
      ctx.fillText=function(t,x,y){draws.push({t:String(t).toLowerCase(),x:x,y:y,font:this.font});return text0.apply(this,arguments);};
      ctx.fillRect=function(x,y,w,h){boxes.push({x:x,y:y,w:w,h:h});return rect0.apply(this,arguments);};
      netWatchHud();
      var d=draws.filter(function(x){return x.t==='waiting';})[0], s=Math.max(1,hudRes());
      if(!d) return 'no waiting status';
      var f=/([\d.]+)px/.exec(d.font); if(!f||+f[1]<32*s-.1)return 'waiting type is below 32px at 1080p: '+d.font;
      var b=boxes.filter(function(x){return x.w>=200*s&&x.h>=60*s&&Math.abs(x.x+x.w/2-W/2)<1;})[0];
      if(!b||H-b.y-b.h<64*s-.1) return 'waiting panel lacks its 64px bottom gap';
      if(Math.abs(d.x-W/2)>1||d.y<b.y||d.y>b.y+b.h)return 'waiting is not centered in its panel';
      if(draws.some(function(x){return /press|continue|join/.test(x.t);}))return 'waiting promises an action that is not allowed';
      return null;
    }finally{
      ctx.fillText=text0;ctx.fillRect=rect0;
      if(staged){for(k in NET)if(!(k in keep))delete NET[k];for(k in keep)NET[k]=keep[k];}
      if(g)g.over=false;try{__endRaid('abandon');}catch(_e){}__topClear();
    }
  }},
  {v:'37.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
