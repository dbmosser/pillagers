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

if ($s.Contains("  {v:'33.88',what:")) { throw "check 33.88 is in the fixture already" }

SubRx @'
  {v:'33.87',what:
'@ @'
  {v:'33.88',what:'cw-cx-propsshape: pixel crate raised lids and locker/safe swung doors change the actual cached silhouette; kind details do not expose hidden rarity',
   run:function(){
     if(typeof pixContDetail!=='function') return 'no kind details';
     var cfg=CFG.xfPix, pw=pixWrap, bad=[], last=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0);
       pixWrap=function(){ var e=pw.apply(this,arguments); if(e) last=e; return e; };
       function body(type,open,best){
         var c={x:340,y:350,type:type,r:15,opened:open,loot:[],best:best||'common',time:1,prog:0}; last=null;
         for(var i=0;i<3&&!last;i++){ pixFrame(); drawContS(c); }
         return last;
       }
       ['crate','locker','safe'].forEach(function(t){
         var closed=body(t,false), opened=body(t,true);
         if(!closed||!opened){ bad.push(t+' did not cache'); return; }
         if(t==='crate'&&opened.c.height<closed.c.height+6) bad.push('crate lid is not visibly raised');
         if(t!=='crate'&&opened.c.width<closed.c.width+3) bad.push(t+' door does not change the silhouette');
         var base=t==='locker'?12:16;
         if(opened.c.width>base+6) bad.push(t+' door exceeds the existing footprint limit');
         [closed,opened].forEach(function(e){ var p=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data; for(var j=3;j<p.length;j+=4) if(p[j]&&p[j]!==255){ bad.push(t+' has soft cached alpha'); break; } });
       });
       var a=body('cache',false,'common'), b=body('cache',false,'gold');
       if(!a||a!==b) bad.push('hidden rarity changes the cache sprite');
       return bad.length?bad.join('; '):null;
     } finally{
       pixWrap=pw;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=cfg;
     }
   }},
  {v:'33.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
