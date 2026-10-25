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

if ($s.Contains("  {v:'34.77',what:")) { throw "check 34.77 is in the fixture already" }

SubRx @'
  {v:'34.76',what:
'@ @'
  {v:'34.77',what:'a reload and a forged gun keep the pixel gun on a pixel body; the forge shine sheds on the quality ladder; the vector look still draws its gun',
   run:function(){
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     if(typeof pixDrawOp!=='function'||typeof gunHeld!=='function') return 'SKIP: no pixel painter';
     if(typeof pxGunLive!=='function') return 'a reload and a forged gun still flip the pixel body to the vector gun (no pxGunLive)';
     var bad=[], g, st, i, og=gunHeld, ol=pxGunLive, nv=0, nl=0, sq=GFXQ.particles;
     function run(tag,wep,rl,pix,part,wantV,wantL){
       st.own=Object.assign({},g.player,{wep:wep}); st.rl=rl; CFG.xfPix=pix; GFXQ.particles=part;
       for(i=0;i<16;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',0,st); }
       nv=0; nl=0;
       for(i=0;i<4;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',0,st); }
       if(wantV===0&&nv>0) bad.push(tag+': the vector gun was drawn on the pixel body');
       if(wantV===1&&nv===0) bad.push(tag+': no vector gun with the pixel look off');
       if(wantL===1&&nl===0) bad.push(tag+': no live bits over the pixel gun');
       if(wantL===0&&nl>0) bad.push(tag+': live bits drawn when they should not be');
     }
     try{
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player) return 'SKIP: no raid';
       st={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
       gunHeld=function(){ nv++; return og.apply(this,arguments); };
       pxGunLive=function(){ nl++; return ol.apply(this,arguments); };
       wc.save(); wc.setTransform(1,0,0,1,0,0);
       try{
         run('plain gun',{id:'rifle'},0,1,1,0,0);
         run('reload',{id:'rifle'},0.55,1,1,0,0);
         run('reload mid',{id:'rifle'},0.2,1,1,0,1);
         run('forged',{id:'rifle',fk:1},0,1,1,0,1);
         run('forged element',{id:'rifle',fk:2,el:'fire'},0.5,1,1,0,1);
         run('forged, quality step',{id:'rifle',fk:2,el:'fire'},0,1,0,0,0);
         run('reload, pixel look off',{id:'rifle'},0.55,0,1,1,-1);
         run('forged, pixel look off',{id:'rifle',fk:1},0,0,1,1,-1);
       }finally{ wc.restore(); }
     }finally{ gunHeld=og; pxGunLive=ol; GFXQ.particles=sq; CFG.xfPix=1; try{ __endRaid(); }catch(_e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'34.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
