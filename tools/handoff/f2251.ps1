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

if ($s.Contains("  {v:'22.51',what:")) { throw "check 22.51 is in the fixture already" }

SubRx @'
  {v:'22.50',what:
'@ @'
  {v:'22.51',what:'the floor belt and Stash screen belt answers read like a shooter HUD (from the review of the four-gun belt, build 4): a click on an unbound Stash screen belt key answers in short ALL CAPS on the keyboard and on a pad, and the floor belt gun drag has no explaining sentence left (only gun, traded places, to slot, how to take a gun out of his hands)',
   run:function(){
     if(!window.__showScreen||!window.__P||!window.__topClear) return 'SKIP: this fixture cannot show the Stash screen';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], src=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n'), i;
     var OLD=[[' is your',' only gun, so there'],['\' traded',' places with \''],['\' to slot \'+(_hb8',''],['To take a gun',' out of your hands'],['Hover an item',' in the stash and press'],['Pick an item up',' with A first, then']];
     for(i=0;i<OLD.length;i++){ var nd=OLD[i].join(''); if(src.indexOf(nd)>=0) bad.push('the game still has the explaining line '+JSON.stringify(nd+'...')); }
     var P2=__P(), ha0=P2.hotAssign, hub=document.getElementById('hub'), hubWas=!!(hub&&hub.classList.contains('on')), pOn=(typeof PAD!=='undefined'&&PAD)?PAD.on:null;
     var shut=['stagemodal','sectormodal','outcome','title','pausebox'], was={}, si;
     for(si=0;si<shut.length;si++){ var se=document.getElementById(shut[si]); was[shut[si]]=!!(se&&se.classList.contains('on')); if(se) se.classList.remove('on'); }
     function clickSay(pad){
       if(typeof PAD!=='undefined'&&PAD) PAD.on=!!pad;
       P2.hotAssign={};
       __showScreen('hub'); if(hub) hub.classList.add('on');
       var cell=(hub||document).querySelector('[data-plan="5"]');
       if(!cell) return null;
       var t0=document.getElementById('hubtoast'); if(t0) t0.textContent='';
       window.__lastSay=null;
       try{ cell.click(); }catch(e1){}
       var t1=document.getElementById('hubtoast');
       return String((t1&&t1.textContent)||window.__lastSay||'').trim();
     }
     try{
       var r=[['keyboard',clickSay(false)],['pad',clickSay(true)]];
       for(i=0;i<r.length;i++){
         var s=r[i][1];
         if(s===null){ if(!bad.length) return 'SKIP: the Stash screen drew no belt key 6'; continue; }
         if(!s){ bad.push('on the '+r[i][0]+' a click on an unbound Stash screen belt key said nothing'); continue; }
         if(s!==s.toUpperCase()) bad.push('on the '+r[i][0]+' a click on an unbound Stash screen belt key says '+JSON.stringify(s)+', not a short ALL CAPS callout');
         if(/[.!?]$/.test(s)) bad.push('on the '+r[i][0]+' the belt key answer ends in punctuation: '+JSON.stringify(s));
         if(!/tactical belt/i.test(s)) bad.push('on the '+r[i][0]+' the belt key answer no longer names the tactical belt: '+JSON.stringify(s));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof PAD!=='undefined'&&PAD&&pOn!==null) PAD.on=pOn; }catch(_p){}
       P2.hotAssign=ha0;
       for(si=0;si<shut.length;si++){ var e2=document.getElementById(shut[si]); if(!e2) continue; if(was[shut[si]]) e2.classList.add('on'); else e2.classList.remove('on'); }
       if(hub){ if(hubWas) hub.classList.add('on'); else hub.classList.remove('on'); }
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
