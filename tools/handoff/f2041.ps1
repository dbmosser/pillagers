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

if ($s.Contains("  {v:'20.41',what:")) { throw "check 20.41 is in the fixture already" }

SubRx @'
  {v:'20.40',what:
'@ @'
  {v:'20.41',what:'your own gunshot reaches the party: fired in a shared raid it plays in your ears and is passed to the other window at where you stand',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof fireWeapon!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oFx=netFxNoise, fw=[], g, w, hit=null;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       w=g.player.wep; if(!w||w.id==='fists') return 'SKIP: staging: no gun in hand';
       netFxNoise=function(t,x,y,wid){ fw.push({t:String(t),x:x,y:y,w:wid}); return true; };
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       fireWeapon(g.player,w,g.player.x+200,g.player.y,true);
       fw.forEach(function(f){ if(f.t==='shot') hit=f; });
       if(!hit) bad.push('your own shot was never passed to the party ('+fw.map(function(f){ return f.t; }).join(',')+')');
       else{
         if(Math.abs(hit.x-g.player.x)>2||Math.abs(hit.y-g.player.y)>2) bad.push('your shot was placed at '+Math.round(hit.x)+','+Math.round(hit.y)+', not where you stand');
         if(hit.w!==w.id) bad.push('your shot was passed on without its gun ('+hit.w+')');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netFxNoise=oFx;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
