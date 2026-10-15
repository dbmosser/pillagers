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

if ($s.Contains("  {v:'27.96',what:")) { throw "check 27.96 is in the fixture already" }

SubRx @'
  {v:'27.95',what:
'@ @'
  {v:'27.96',what:'his 2026-10-14 note (UI cleanup uic2): a run card comes up with the feedback tags shut behind the HOW DID THAT RUN FEEL bar (the 29 tags took more than half of the card), the bar opens them (all 29 still there, the note too), and the next card is shut again',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var oc=document.getElementById('outcome'), tw=document.getElementById('tagwrap'), card=oc&&oc.querySelector('.ocwin');
     if(!oc||!tw||!card) return 'SKIP: no run card in this build';
     var bad=[], g=null;
     function card1(how){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return false;
       __endRaid(how);
       return oc.classList.contains('on');
     }
     try{
       if(!card1('dead')) return 'SKIP: the run card did not come up here';
       var hd=document.getElementById('fbhead'), note=document.getElementById('oc_note');
       if(!hd) return 'the run card has no bar over the feedback tags, so all of them are always out';
       if(tw.getClientRects().length||note.getClientRects().length) bad.push('the tags or the note are showing on a fresh card');
       var h0=card.getBoundingClientRect().height;
       hd.click();
       if(!tw.getClientRects().length||!note.getClientRects().length) bad.push('the bar did not open the tags and the note');
       var nt=tw.querySelectorAll('.tag').length; if(nt<20) bad.push('only '+nt+' tags are in the card');
       var h1=card.getBoundingClientRect().height; if(!(h1>h0+60)) bad.push('opening the tags added '+Math.round(h1-h0)+' px to the card, it was shut at '+Math.round(h0));
       var t0=tw.querySelector('.tag'); if(t0){ t0.click(); if(!t0.classList.contains('sel')) bad.push('a tag does not take a click when it is open'); }
       if(!card1('dead')) return 'SKIP: the second run card did not come up here';
       if(tw.getClientRects().length) bad.push('the next card came up with the tags still open');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ oc.classList.remove('on'); }catch(_o){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'27.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
