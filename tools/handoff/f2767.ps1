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

if ($s.Contains("  {v:'27.67',what:")) { throw "check 27.67 is in the fixture already" }

SubRx @'
  {v:'27.66',what:
'@ @'
  {v:'27.67',what:'cloud-menus-nuke-reduced-flash: REDUCED FLASHING also tones down the site going up: the white-out by flashK and its blooms by the same factors flash() uses; off draws them as before',
   run:function(){
     if(typeof tickNuke!=='function'||typeof flashK!=='function'||typeof wc==='undefined'||!wc) return 'SKIP: this fixture has no clock-out white-out';
     var bad=[], f0=CFG.flashRed, g, i, seen, desc=null, R={};
     function setup(){ __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var gg=__state(); gg.player.iv=99; gg.ents.length=0; return gg; }
     function bloom(){ g.flashes.length=0; g.nukeT=0.5; g.nukeAcc=1; tickNuke(0.01); return g.flashes.length?g.flashes[g.flashes.length-1]:null; }
     function whiteout(){
       seen=[]; g.nuking=1; g.nukeT=1.0;
       Object.defineProperty(wc,'fillStyle',{configurable:true,get:function(){ return desc.get.call(wc); },set:function(v){ if(typeof v==='string'&&v.indexOf('rgba(255,236,196,')===0) seen.push(parseFloat(v.slice(17))); desc.set.call(wc,v); }});
       try{ __frame(0.016); } finally { delete wc.fillStyle; }
       g.nuking=0; g.nukeT=0;
       return seen.length?seen[seen.length-1]:null;
     }
     try{
       for(var pr=Object.getPrototypeOf(wc);pr&&!desc;pr=Object.getPrototypeOf(pr)) desc=Object.getOwnPropertyDescriptor(pr,'fillStyle');
       if(!desc||!desc.set) return 'SKIP: the canvas fillStyle cannot be watched';
       for(i=0;i<2;i++){
         CFG.flashRed=i;
         g=setup();
         var b=bloom(), a=whiteout();
         if(!b) return 'SKIP: the barrage pushed no bloom';
         if(a===null) return 'SKIP: the white-out was not drawn';
         R[i]={r:b.r,life:b.life,a:a};
         __endRaid('abandon');
       }
       if(Math.abs(R[0].life-0.5)>1e-9||R[0].r<180||R[0].r>340) bad.push('REDUCED FLASHING off changed the barrage bloom: '+JSON.stringify(R[0]));
       if(Math.abs(R[0].a-0.92)>0.002) bad.push('REDUCED FLASHING off changed the white-out: '+R[0].a);
       if(Math.abs(R[1].life-0.5*0.7)>1e-9||R[1].r<180*0.6-1e-9||R[1].r>340*0.6+1e-9) bad.push('REDUCED FLASHING on did not make the barrage bloom smaller and shorter as flash() does: '+JSON.stringify(R[1]));
       if(Math.abs(R[1].a-0.92*0.45)>0.002) bad.push('REDUCED FLASHING on did not tone down the white-out: alpha '+R[1].a+' (wanted '+(0.92*0.45).toFixed(3)+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ delete wc.fillStyle; }catch(_d){}
       try{ if(G){ G.nuking=0; G.nukeT=0; G.flashes.length=0; } }catch(_n){}
       try{ if(G&&!G.over&&state==='raid') __endRaid('abandon'); }catch(_e){}
       CFG.flashRed=f0;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
