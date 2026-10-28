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

if ($s.Contains("  {v:'36.08',what:")) { throw "check 36.08 is in the fixture already" }

SubRx @'
  {v:'36.07',what:
'@ @'
  {v:'36.08',what:'g-84 burst numbers clear the target nameplate, each other and the local body in both local and received party paths',
   run:function(){
     var g,p,e,all,rec=[],oF=wc.fillText,oS=wc.strokeText,oN=CFG.dmgNumbers,oOn=NET.on,bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.on=false;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;all=g.ents.slice();CFG.dmgNumbers=1;
       e=mkSentry(p.x+150,p.y);e.nid=123456789;e.state='chase';g.ents=[e];g.dmgN=[];
       dmgNum(e.x,e.y-e.r*2.7,1234,'#6fd8ff',false,e);g.dmgN[0].hits=10;g.dmgN[0].pop=0.12;
       dmgNum(e.x,e.y-e.r*1.1,48,'#FFF6DC',false,e);
       dmgNum(e.x,e.y-e.r*2.7,324,'#ff8a3c',false,'p'+e.nid);
       dmgNum(p.x,p.y-26,18,'#ff5a4a',false,'self');
       wc.fillText=function(t,x,y){if(wc.fillStyle!==INK){var px=parseFloat((wc.font.match(/([\d.]+)px/)||[])[1]);rec.push({text:String(t),x:x,y:y,px:px,w:wc.measureText(String(t)).width});}};
       wc.strokeText=function(){};drawDmgNums();
       if(rec.length!==4) bad.push('expected four actual coloured number draws, got '+rec.length);
       var npx=parseFloat((FS(TYPE.micro).match(/([\d.]+)px/)||[])[1]),top=e.y-spriteTop(e)-8-Math.ceil(npx*1.35)+3;
       for(var i=0;i<rec.length;i++){
         var a=rec[i];
         if(a.text==='18'){if(a.y>p.y-66)bad.push('self damage still crowds the head/reticle');}
         else if(a.y+a.px*0.2>top-7.5) bad.push('number '+a.text+' covers the target nameplate');
         if(a.text!=='18'&&a.x-a.w/2<e.x+npx/2+4&&a.x+a.w/2>e.x-npx/2-4&&a.y+a.px*0.2>top-4-Math.max(24,npx*2)&&a.y-a.px*0.85<top-4) bad.push('number '+a.text+' covers the alert mark');
         for(var j=0;j<i;j++){var b=rec[j];if(a.x-a.w/2<b.x+b.w/2+7&&a.x+a.w/2>b.x-b.w/2-7&&a.y-a.px*0.85<b.y+b.px*0.2+7&&a.y+a.px*0.2>b.y-b.px*0.85-7)bad.push('number '+a.text+' overlaps '+b.text);}
       }
       if(g.dmgN[0].x!==e.x||g.dmgN[0].y!==e.y-e.r*2.7||g.dmgN[0].n!==1234||g.dmgN[0].hits!==10)bad.push('layout changed stored hit data');
       rec=[];CFG.dmgNumbers=0;drawDmgNums();if(rec.length)bad.push('disabled numbers still draw');
     }catch(err){bad.push('threw: '+(err&&err.message||err));}
     finally{wc.fillText=oF;wc.strokeText=oS;CFG.dmgNumbers=oN;NET.on=oOn;try{if(g){g.dmgN=[];if(all)g.ents=all;}__endRaid('abandon');}catch(_e){}__topClear();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
