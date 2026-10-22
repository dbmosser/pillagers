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

if ($s.Contains("  {v:'33.99',what:")) { throw "check 33.99 is in the fixture already" }

SubRx @'
  {v:'33.98',what:
'@ @'
  {v:'33.99',what:'Undercroft text follows the guide: 32px cream title, 20px stations, one 56px raid hero, 16px hints in key chips and the experimental caption preserved',
   run:function(){
     if(typeof hubFloorHints!=='function') return 'the floor still has the tiny unframed hint line';
     var oW=wc.fillText,oC=ctx.fillText,oR=ctx.strokeRect,oPad=padOn,words=[],hud=[],chips=[],wn=WNSEEN,near,legend;
     function font(c){ var m=/([\d.]+)px/.exec(c.font); return m?parseFloat(m[1]):0; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!__hubEnter()||!HB) return 'no hub';
       __topClear(); document.getElementById('title').classList.remove('on');
       near=HB.near; legend=HB.legend; HB.near=null; HB.legend=false; WNSEEN=1;
       var R=Math.max(1,hudRes()),S=hubScale();
       wc.fillText=function(s,x,y){ words.push({s:String(s),px:font(wc)*wc.getTransform().a,c:wc.fillStyle}); return oW.apply(this,arguments); };
       wc.save(); wc.setTransform(1,0,0,1,0,0); try{ hubStationNames(S,0,0); }finally{ wc.restore(); }
       var raid=words.filter(function(t){return t.s==='ENTER RAID!';})[0];
       if(!raid||Math.abs(raid.px-56*R)>.2||raid.c!==UIC.acc) return 'raid station lacks the 56px lime hero';
       for(var i=0;i<HB.stations.length;i++){
         var st=HB.stations[i]; if(st.id==='lift') continue;
         var sign=words.filter(function(t){return t.s===st.label;})[0];
         if(!sign||Math.abs(sign.px-20*R)>.2||sign.c!==UIC.tx_2) return 'station size or colour: '+st.id;
       }
       var exp=words.filter(function(t){return t.s==='***EXPERIMENTAL***';})[0];
       if(!exp||Math.abs(exp.px-16*R)>.2) return 'experimental caption missing or below 16px';
       ctx.fillText=function(s,x,y){ hud.push({s:String(s),px:font(ctx),c:ctx.fillStyle}); return oC.apply(this,arguments); };
       ctx.strokeRect=function(x,y,w,h){ chips.push(h); return oR.apply(this,arguments); };
       padOn=function(){return false;}; drawHubHUD(0,0);
       var title=hud.filter(function(t){return t.s==='THE UNDERCROFT';})[0];
       if(!title||title.px!==32||title.c!==UIC.tx_1) return 'title is not 32px cream';
       var use=hud.filter(function(t){return t.s==='USE STATION';})[0];
       if(!use||Math.abs(use.px-16*R)>.2||chips.length<3) return '16px control words and key chips missing';
       hud=[]; chips=[]; padOn=function(){return true;}; hubFloorHints();
       if(!hud.some(function(t){return t.s===keyLabel('KeyE','E');})||!hud.some(function(t){return t.s===padB('L STICK');})||chips.length<3) return 'pad key chips do not follow last input';
       return null;
     }finally{
       wc.fillText=oW;ctx.fillText=oC;ctx.strokeRect=oR;padOn=oPad;WNSEEN=wn;
       if(HB){HB.near=near;HB.legend=legend;}
       try{__endRaid('abandon');}catch(e){} __topClear();
     }
   }},
  {v:'33.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
