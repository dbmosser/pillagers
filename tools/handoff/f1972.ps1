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

if ($s.Contains("  {v:'19.72',what:")) { throw "check 19.72 is in the fixture already" }

SubRx @'
  {v:'19.71',what:
'@ @'
  {v:'19.72',what:'the what is new card speaks controller on a controller: with a pad on, its last line names only walking, and without one it names ENTER',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';
     if(typeof pollPad!=='function'||typeof PAD==='undefined') return 'SKIP: no controller poll here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, on0=PAD.on, pad, sp, sk;
     pad={id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,connected:true,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:Array.apply(null,Array(17)).map(function(){ return {pressed:false,touched:false,value:0}; })};
     function grab(){ var i, hd=false, dm=null; rec.length=0; __wnseen(0); __hubFrame(0.016); for(i=0;i<rec.length;i++){ if(rec[i].indexOf('NEW IN v')===0) hd=true; if(!dm&&/dismiss$/.test(rec[i])) dm=rec[i]; } return {hd:hd,dm:dm}; }
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(t){ rec.push(String(t)); return o.apply(this,arguments); };
       navigator.getGamepads=function(){ pad.timestamp++; return [pad,null,null,null]; };
       pollPad(); PAD.on=true; sp=grab();
       navigator.getGamepads=function(){ return [null,null,null,null]; };
       pollPad(); PAD.on=false; sk=grab();
       if(!sp.hd||!sk.hd) return 'SKIP: the card was not drawn';
       if(!sp.dm) bad.push('on a controller the card has no dismiss line');
       else if(sp.dm.indexOf('ENTER')>=0) bad.push('on a controller the card still says '+sp.dm);
       if(!sk.dm||sk.dm.indexOf('ENTER')<0) bad.push('control: with keyboard and mouse the card does not name ENTER');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; if(had) navigator.getGamepads=og; else delete navigator.getGamepads; try{ pollPad(); }catch(_p){} PAD.on=on0; try{ padBodyCls(); }catch(_b){} P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
