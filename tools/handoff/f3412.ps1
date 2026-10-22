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

if ($s.Contains("  {v:'34.12',what:")) { throw "check 34.12 is in the fixture already" }

SubRx @'
  {v:'34.11',what:
'@ @'
  {v:'34.12',what:'both teammate pad lost tags draw a visible 24px controller glyph in warn with a 2px stroke',
   run:function(){
     var nk=Object.assign({},NET), stroke=ctx.stroke, rec=[], bad=[], g, icon=uiIconPath('controller');
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       if(!icon)return 'controller path is missing';
       ctx.stroke=function(p){if(p===icon){var m=ctx.getTransform(),s=Math.hypot(m.a,m.b)/(DPR||1);rec.push({w:18*s,line:ctx.lineWidth*s,c:ctx.strokeStyle});}return stroke.apply(this,arguments);};
       ['host','p2'].forEach(function(side){
         NET.same=side;NET.pair='pad-glyph-check';NET.padPeerLost=true;rec=[];
         var t=netPadHud(),z=Math.max(.75,Math.min(2.2,H/1080)),r=rec[0];
         if(t!==(side==='host'?'p2 pad lost':'p1 pad lost')||rec.length!==1){bad.push(side+': missing one controller glyph');return;}
         if(Math.abs(r.w-24*z)>.1||Math.abs(r.line-2*z)>.1||r.c!==UIC.warn)bad.push(side+': controller glyph width/stroke/colour is wrong ('+r.w+', '+r.line+', '+r.c+')');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.stroke=stroke;try{__endRaid('abandon');}catch(e){}__topClear();
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
     }
   }},
  {v:'34.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
