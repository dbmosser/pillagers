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

if ($s.Contains("  {v:'34.32',what:")) { throw "check 34.32 is in the fixture already" }

SubRx @'
  {v:'34.31',what:
'@ @'
  {v:'34.32',what:'the end cards: the xp line is short, the title is 32px, the feedback line is a bordered button, the haul tiles sit under the loss figure, and the raid feed waits behind the abandon question',
   run:function(){
     var bad=[], man, vis, h1, fb, pb, w, tl, lo, ti, i;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __endRaid('dead');
       man=document.getElementById('oc_manifest');
       vis=man.cloneNode(true); tl=vis.querySelectorAll('.ocsr'); for(i=0;i<tl.length;i++) tl[i].parentNode.removeChild(tl[i]);
       vis=(vis.textContent||'').replace(/\s+/g,' ');
       if(/penalty for|in all/i.test(vis)) bad.push('the death card still shows the long xp sentence: "'+vis.slice(0,140)+'"');
       if(!/\+\d+ xp\s*\W+\s*50% penalty/i.test(vis)) bad.push('the death card xp line is not "+n xp . 50% penalty": "'+vis.slice(0,140)+'"');
       if(!/penalty for failure to extract/.test((man.textContent||'').replace(/\s+/g,' '))) bad.push('the penalty sentence left the card text, it should stay hidden');
       h1=document.querySelector('#outcome h1');
       if(!h1||parseFloat(getComputedStyle(h1).fontSize)>32.5) bad.push('the end card title is '+(h1?getComputedStyle(h1).fontSize:'missing')+', the guide says 32px');
       fb=document.getElementById('fbhead');
       if(!fb||parseFloat(getComputedStyle(fb).borderTopWidth)<1) bad.push('the how did that run feel line has no border, it reads as dead text');
       lo=man.querySelector('.ocloss'); ti=man.querySelector('.octiles');
       if(lo&&ti&&ti.getBoundingClientRect().top<lo.getBoundingClientRect().top) bad.push('the haul tiles sit above the loss figure');
       if(typeof feedWaits!=='function') bad.push('no feedWaits: the feed draws over the abandon question');
       else {
         pb=document.getElementById('pausebox'); w=pb.classList.contains('asking');
         pb.classList.add('asking'); if(!feedWaits()) bad.push('the feed does not wait while the abandon question is up');
         if(!w) pb.classList.remove('asking');
       }
       return bad.length?bad.join(' | '):null;
     } finally {
       try{ var _p=document.getElementById('pausebox'); if(_p) _p.classList.remove('asking'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
