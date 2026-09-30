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

if ($s.Contains("  {v:'17.43',what:")) { throw "check 17.43 is in the fixture already" }

SubRx @'
  {v:'17.42',what:
'@ @'
  {v:'17.43',what:'graphics options: Settings has Render resolution, Frame cap and Effects rows; a lower resolution draws fewer pixels at once, the frame cap skips a frame that comes too soon, and reduced effects make fewer sparks',
   run:function(){
     if(typeof gfxScaleNow!=='function'||typeof frameCapSkip!=='function') return 'this build has no graphics options';
     if(typeof resize!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: no canvas or raid in this fixture';
     var bad=[], c0={s:CFG.gfxScale,f:CFG.fpsCap,x:CFG.fxLevel}, ks=(GAMEOPTS||[]).map(function(o){ return o.k; }), w1, w2, n1, n2, a, b, c;
     ['gfxScale','fpsCap','fxLevel'].forEach(function(k){ if(ks.indexOf(k)<0) bad.push('Settings has no '+k+' row'); });
     try{
       CFG.gfxScale=1; resize(); w1=cv.width;
       CFG.gfxScale=0.5; resize(); w2=cv.width;
       if(!(w2<w1*0.6&&w2>w1*0.4)) bad.push('Low resolution drew '+w2+' pixels across, not about half of '+w1);
       CFG.fpsCap=30; CAP_LAST=0;
       a=frameCapSkip(1000); b=frameCapSkip(1010); c=frameCapSkip(1040);
       if(a||!b||c) bad.push('a 30 frame cap did not skip a frame 10 ms after the last and keep one 40 ms after ('+a+','+b+','+c+')');
       CFG.fpsCap=0; if(frameCapSkip(2000)||frameCapSkip(2001)) bad.push('with the cap off a frame was skipped');
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(G&&G.sparks){
         CFG.fxLevel=1; G.sparks.length=0; spark(100,100,'#fff',30,100); n1=G.sparks.length;
         CFG.fxLevel=0; G.sparks.length=0; spark(100,100,'#fff',30,100); n2=G.sparks.length;
         if(!(n2<n1)) bad.push('reduced effects made '+n2+' sparks, full made '+n1);
         G.sparks.length=0;
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CFG.gfxScale=c0.s; CFG.fpsCap=c0.f; CFG.fxLevel=c0.x; CAP_LAST=0;
       try{ resize(); }catch(_r){}
       try{ __endRaid('abandon'); __topClear(); }catch(_e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
