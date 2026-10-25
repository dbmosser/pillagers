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

if ($s.Contains("  {v:'34.72',what:")) { throw "check 34.72 is in the fixture already" }

SubRx @'
  {v:'34.71',what:
'@ @'
  {v:'34.72',what:'a crowbar swing or punch keeps the pixel body on a plain look (no flip to the vector art)',
   run:function(){
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     if(typeof pixDrawOp!=='function'||typeof pxLookOf!=='function') return 'SKIP: no pixel painter';
     var bad=[], g, st, b0, i, sv=P.cosOutfit, lk;
     try{
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       st={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
       P.cosOutfit='outnone'; lk=pxLookOf(st);
       if(!lk||pxIsSet(lk.clothes)) return 'SKIP: the hero is not a plain look';
       wc.save(); wc.setTransform(1,0,0,1,0,0);
       try{
         [['a punch',0.1,0],['a crowbar swing',0,0.1]].forEach(function(q){
           G.punchT=q[1]; G.barT=q[2]; CFG.xfPix=1; b0=PIX.bodies;
           for(i=0;i<4;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'fist',0,st); }
           if(PIX.bodies===b0) bad.push(q[0]+' on a plain look was not drawn in pixels');
           CFG.xfPix=0; b0=PIX.bodies;
           for(i=0;i<4;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'fist',0,st); }
           if(PIX.bodies!==b0) bad.push(q[0]+' drew a pixel body with the pixel look off');
           CFG.xfPix=1;
         });
       }finally{ wc.restore(); G.punchT=0; G.barT=0; CFG.xfPix=1; }
     }finally{ P.cosOutfit=sv; try{ __endRaid(); }catch(_e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'34.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
