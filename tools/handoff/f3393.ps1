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

if ($s.Contains("  {v:'33.93',what:")) { throw "check 33.93 is in the fixture already" }

SubRx @'
  {v:'33.92',what:
'@ @'
  {v:'33.93',what:'cw-cx-pixguard: a throwing bake draws the vector body, the third throw locks only its kind for this raid and writes one recorder line, a new raid retries',
   run:function(){
     if(typeof pixGuardBlocked!=='function')return 'no per-kind pixel guard';
     var cfg=CFG.xfPix, bake=pixWrapBake, oldDraw=drawOp0, body=pixDrawOp, w=wc, err=PIX.errs, active=PIXGUARD.active, g, saved=false, count=0, vec=0, serial;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=G;pixDropAll();wc=w;wc.save();saved=true;
       wc.setTransform(1,0,0,1,120,160);
       pixWrapBake=function(){count++;throw new Error('injected guard bake');};
       function paint(){wc.fillStyle='#eeb08a';wc.fillRect(-4,-12,8,12);vec++;}
       // v28.xx (cw-cx-pixguard): This is the adapter contract used by props: a false return calls the existing body painter.
       for(var i=0;i<6;i++){pixFrame();if(!pixWrap('guard-test|'+i,20,20,1,paint,0,0,{up:16}))paint();}
       if(count!==3||vec!==6)return 'throwing kind did not stay vector: bakes '+count+' vector bodies '+vec;
       if(!g.tel.pixGuard||g.tel.pixGuard.length!==1||g.tel.pixGuard[0].kind!=='guard-test')return 'guard did not record exactly one line';
       if(CFG.xfPix!==1)return 'guard turned off pixel look';
       pixWrapBake=bake;pixFrame();
       if(!pixWrap('other-kind',20,20,1,paint,0,0,{up:16}))return 'guard disabled a different kind';
       // v28.xx (cw-cx-pixguard): The public pillager dispatcher must draw its old body when a component throws, then stop trying after three.
       count=0;vec=0;drawOp0=function(){vec++;};
       pixDrawOp=function(){count++;throw new Error('injected pillager body');};
       var st={hero:1,own:g.player,moving:false,sprint:false,ads:false,bulk:0};
       for(i=0;i<5;i++){pixFrame();drawOp(0,0,0,0,'#aaa',0,0,'none',0,st);}
       if(count!==3||vec!==5)return 'pillager dispatcher failed vector fallback '+count+'/'+vec;
       if(g.tel.pixGuard.length!==2)return 'pillager guard recorded more than once';
       pixDrawOp=body;drawOp0=oldDraw;
       var over=g.over;g.over=true;
       if(pixGuardBlocked('pillager'))return 'guard continued after the raid ended';
       g.over=over;
       // v28.xx (cw-cx-pixguard): A different raid object is the lifetime boundary, independent of settings and cache resets.
       G={sim:0,tel:{},t:0};
       if(pixGuardBlocked('guard-test')||pixGuardBlocked('pillager'))return 'new raid inherited the guard';
       return null;
     }finally{
       G=g||G;wc=w;if(saved)wc.restore();pixWrapBake=bake;pixDrawOp=body;drawOp0=oldDraw;PIX.errs=err;PIXGUARD.active=active;
       if(g){g.drawErr=null;if(g.tel){g.tel.drawErr=null;g.tel.pixGuard=[];}}
       PIXGUARD.raid=null;PIXGUARD.kinds=Object.create(null);
       try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();CFG.xfPix=cfg;pixDropAll();pixFrame();
     }
   }},
  {v:'33.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
