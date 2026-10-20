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

if ($s.Contains("  {v:'32.75',what:")) { throw "check 32.75 is in the fixture already" }

SubRx @'
  {v:'32.74',what:
'@ @'
  {v:'32.75',what:'the shadow store keeps its sprites when the sprite scale changes between world and figures, so frames paint no new shadow canvases',
   run:function(){
     if(typeof shadowE!=='function'||typeof SHADSPR==='undefined') return 'no shadow store';
     var rc=document.createElement, rd=wc.drawImage, made=0, dr=[], i, n1, n3;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||!__state().player) return 'SKIP: no raid';
       document.createElement=function(t){ if(String(t).toLowerCase()==='canvas') made++; return rc.apply(document,arguments); };
       wc.drawImage=function(im,x,y,w,h){ if(im&&im.width&&arguments.length===5) dr.push(w); return rd.apply(wc,arguments); };
       SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=0;
       for(i=0;i<3;i++){
         wc.save(); wc.setTransform(1,0,0,1,0,0); shadowE(100,100,37,19,0.41); wc.restore();
         wc.save(); wc.setTransform(2,0,0,2,0,0); shadowE(100,100,37,19,0.41); wc.restore();
         if(i===0){ n1=made; }
       }
       n3=made;
       if(n3!==n1) return 'frames 2 and 3 made '+(n3-n1)+' new shadow canvases (the store emptied on every scale change)';
       if(Object.keys(SHADSPR.m).length<2) return 'the store holds '+Object.keys(SHADSPR.m).length+' entries, not one per scale';
       if(dr.length<6||Math.abs(dr[0]-dr[1])>1) return 'a shadow at scale 1 and 2 differs in size: '+dr[0]+' vs '+dr[1];
       return null;
     } finally {
       document.createElement=rc; wc.drawImage=rd;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
