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

if ($s.Contains("  {v:'36.36',what:")) { throw "check 36.36 is in the fixture already" }

SubRx @'
  {v:'36.35',what:
'@ @'
  {v:'36.36',what:'the undercroft has no key bars: station E prompts stay, keyboard and pad hints go, help keeps lift shortcuts and R still ascends',
   run:function(){
     var oF=ctx.fillText,own=Object.prototype.hasOwnProperty.call(ctx,'fillText'),oPad=padOn,oW=W,oH=H,oKeys=keys,oWN=WNSEEN,oOn=NET.on,oSame=NET.same;
     var rec=[],bad=[],lift=null,j,m,z,st,prompt,sub,g;
     function draw(){ rec=[]; drawHubHUD(0,0); return rec.join('|').toLowerCase(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; NET.same=0; keys={};
       if(!__hubEnter()||!HB) return 'no Undercroft';
       __topClear(); document.getElementById('title').classList.remove('on'); WNSEEN=1; HB.legend=false;
       ctx.fillText=function(t){ rec.push(String(t)); return oF.apply(this,arguments); };
       for(j=0;j<HB.stations.length;j++) if(HB.stations[j].id==='lift') lift=HB.stations[j];
       if(!lift) return 'no lift';
       for(z=0;z<2;z++){
         W=z?3840:1920; H=z?2160:1080;
         for(m=0;m<2;m++){
           padOn=m?function(){return true;}:function(){return false;};
           for(j=-1;j<HB.stations.length;j++){
             st=j<0?null:HB.stations[j]; HB.near=st;
             var text=draw();
             if(/quick ascent|the terms|use station|wasd/.test(text)) bad.push('hint remains at '+(st?st.id:'mid-room')+' '+W+' pad='+m);
             if(st){
               prompt='['+keyLabel('KeyE','E')+']  '+st.label;
               if(rec.indexOf(prompt)<0) bad.push('missing E prompt at '+st.id);
               sub=typeof st.sub==='function'?st.sub():st.sub;
               if(sub&&rec.indexOf(sub)>=0) bad.push('station sub row remains at '+st.id);
             }
           }
         }
       }
       W=oW; H=oH; HB.near=lift; HB.legend=true; padOn=function(){return false;};
       var help=draw();
       ['quick ascent','the terms','party','the map','wasd'].forEach(function(t){ if(help.indexOf(t)<0) bad.push('help lost '+t); });
       [['KeyR','quick ascent'],['KeyT','the terms'],['KeyF','party']].forEach(function(row){
         var i=rec.indexOf('lift: '+row[1]); if(i<1||rec[i-1]!==keyLabel(row[0],row[0].slice(3))) bad.push('help binding missing '+row[0]);
       });
       HB.legend=false; padOn=oPad;
       if(bad.length) return bad.join('; ');
       HB.player.x=lift.x; HB.player.y=lift.y+25; HB.eLock=false; keys={KeyR:true}; P.mapIx=0; pendSeed=4242;
       updateHubWorld(0.016); keys={};
       g=__state();
       if(state!=='raid'||!g||!g.player||g.over||g.sim) return 'R at the lift did not start quick ascent';
       return null;
     }finally{
       if(own) ctx.fillText=oF; else delete ctx.fillText;
       padOn=oPad; W=oW; H=oH; keys={}; WNSEEN=oWN;
       try{ __endRaid('abandon'); }catch(e){} __topClear();
       NET.on=oOn; NET.same=oSame; keys=oKeys;
     }
   }},
  {v:'36.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
