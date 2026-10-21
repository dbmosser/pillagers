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

if ($s.Contains("  {v:'33.83',what:")) { throw "check 33.83 is in the fixture already" }

SubRx @'
  {v:'33.82',what:
'@ @'
  {v:'33.83',what:'cw-pixhub (86e) ship 5: the extraction ring line, the Undercroft station posts, mainframe racks and the dropped crate go through pixWrap as hard alpha scene sprites at the scene density; a throw inside pixWrap leaves wc as the world context',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     if(!(window.__deploy&&window.__frame&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], calls=[], pw0=pixWrap, cfg0=CFG.xfPix, wc0, i, j, e, px, aa, a1, src, got, ik, c;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       wc0=wc;
       src=String(render2D);
       if(src.indexOf("pixWrap('xz:'")<0) bad.push('the extraction ring does not go through pixWrap');
       src=String(drawHubWorld);
       if(src.indexOf("pixWrap('hs:'")<0) bad.push('the Undercroft station post does not go through pixWrap');
       if(src.indexOf("pixWrap('hr'")<0) bad.push('the Undercroft rack does not go through pixWrap');
       pixWrap=function(key,w2,h2,d,paint,x,y,o){ var r=pw0.apply(this,arguments); calls.push({key:key,d:d,e:r}); return r; };
       pixFrame();
       ik=Object.keys(ITEMS)[0];
       for(i=0;i<3;i++){ calls.length=0; pixFrame(); hubDrawDrop({x:G.player.x,y:G.player.y,k:ik,id:'t'}); if(calls.length&&calls[0].e) break; }
       got=calls.filter(function(q){ return q.key==='hd'; })[0];
       if(!got) bad.push('the dropped crate was never drawn through the adapter');
       else if(!got.e) bad.push('the dropped crate fell back to vector');
       else {
         if(got.d!==PIX_ENV) bad.push('the dropped crate is not at the scene density');
         e=got.e; px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data; aa=0; a1=0;
         for(j=3;j<px.length;j+=4){ if(px[j]===255) a1++; else if(px[j]!==0) aa++; }
         if(aa) bad.push('the crate sprite has '+aa+' soft alpha pixels');
         if(!a1) bad.push('the crate sprite is empty');
         if(e.c.width*e.d<24||e.c.height*e.d<16) bad.push('the crate sprite '+e.c.width*e.d+'x'+e.c.height*e.d+' is smaller than its 26x20 footprint');
       }
       pixWrap=pw0;
       try{ pixWrap('px-throw-test2',20,20,PIX_ENV,function(){ throw new Error('forced'); },G.player.x,G.player.y,{up:10}); }catch(_t){}
       if(wc!==wc0) bad.push('a forced throw inside pixWrap left wc pointing at the scratch');
       return bad.length?bad.slice(0,8).join('; '):null;
     } catch(err){
       return 'pixhub check: '+String(err&&err.message||err);
     } finally {
       pixWrap=pw0;
       CFG.xfPix=cfg0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
