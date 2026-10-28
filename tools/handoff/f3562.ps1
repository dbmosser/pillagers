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

if ($s.Contains("  {v:'35.62',what:")) { throw "check 35.62 is in the fixture already" }

SubRx @'
  {v:'35.61',what:
'@ @'
  {v:'35.62',what:'OS motion defaults render as defaults, while saved departures from them remain marked as changed',
   run:function(){
     var om=window.matchMedia, go=P.gameOpts, tk=P.tuned, sub=SETSUB, reduced=true, bad=[];
     function inspect(tag,k,changed){
       var b=document.getElementById('go_'+k);
       if(!b) bad.push(tag+': no '+k+' row');
       else if(!!b.style.color!==changed) bad.push(tag+': '+k+' changed marker '+b.style.color);
     }
     function draw(){ applyGameOpts(); SETSUB=''; renderSettings(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       window.matchMedia=function(q){ return q==='(prefers-reduced-motion: reduce)'?{matches:reduced,media:q}:(om?om.call(window,q):{matches:false,media:q}); };
       P.gameOpts={}; P.tuned={}; draw();
       if(CFG.shake!==0.5||CFG.fxInt!==0.5) bad.push('OS motion defaults changed');
       inspect('OS defaults','shake',false); inspect('OS defaults','fxInt',false);
       P.gameOpts={shake:2,fxInt:0}; draw();
       inspect('saved full','shake',true); inspect('saved full','fxInt',true);
       if(CFG.shake!==1||CFG.fxInt!==1) bad.push('saved full was overridden');
       reduced=false; P.gameOpts={}; draw();
       inspect('ordinary defaults','shake',false); inspect('ordinary defaults','fxInt',false);
       P.gameOpts={shake:0,fxInt:2}; draw();
       inspect('saved off','shake',true); inspect('saved off','fxInt',true);
       return bad.length?bad.join('; '):null;
     } finally {
       window.matchMedia=om; P.gameOpts=go; P.tuned=tk; SETSUB=sub;
       __topClear(); __resetCfg();
       try{ renderSettings(); __topClear(); }catch(_e){}
     }
   }},
  {v:'35.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
