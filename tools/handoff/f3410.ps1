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

if ($s.Contains("  {v:'34.10',what:")) { throw "check 34.10 is in the fixture already" }

SubRx @'
  {v:'34.09',what:
'@ @'
  {v:'34.10',what:'teammate pad lost uses the 32px title on a 64px dark panel with a 24px gap from the message stack',
   run:function(){
     var nk=Object.assign({},NET), ft=ctx.fillText, panel=uiPanel, tags=[], boxes=[], g, bad=[], probe=document.createElement('canvas').getContext('2d');
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;
       // v28.xx (cw-cx-padlostfocus): canvas serializes weight 700 as bold; compare browser-normalized font and colour.
       probe.font=uiFont('title',1);probe.fillStyle=UIC.tx_1;
       ctx.fillText=function(s){if(/^p[12] pad lost$/.test(String(s)))tags.push({font:ctx.font,c:ctx.fillStyle});return ft.apply(this,arguments);};
       uiPanel=function(c,x,y,w,h,a){if(a===UIC.warn)boxes.push({w:w,h:h,y:ctx.getTransform().f/(DPR||1)});return panel.apply(this,arguments);};
       ['host','p2'].forEach(function(side){
         NET.same=side;NET.pair='tag-focus-check';NET.padPeerLost=true;tags=[];boxes=[];
         var label=netPadHud(),b=boxes[0],t=tags[0],z=Math.max(.75,Math.min(2.2,H/1080));
         if(label!==(side==='host'?'p2 pad lost':'p1 pad lost')||tags.length!==1||boxes.length!==1){bad.push(side+': one warning was not drawn');return;}
         if(t.font!==probe.font||t.c!==probe.fillStyle)bad.push(side+': warning is not the 32px primary text title ('+t.font+', '+t.c+'; expected '+probe.font+', '+probe.fillStyle+')');
         if(b.h!==64||b.w<280)bad.push(side+': warning panel is too small');
         if(b.y<Math.max(HUDBOSSB,HUDGIFTB,HUDMSGB)+24*z-1)bad.push(side+': warning is less than 24px clear of the centre stack');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillText=ft;uiPanel=panel;try{__endRaid('abandon');}catch(e){}__topClear();
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
     }
   }},
  {v:'34.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
