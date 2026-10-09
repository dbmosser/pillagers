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

if ($s.Contains("  {v:'21.09',what:")) { throw "check 21.09 is in the fixture already" }

SubRx @'
  {v:'21.08',what:
'@ @'
  {v:'21.09',what:'the run card feel tags use the card width: the tag block fills most of the room in the card, the tags take at most two rows more than they need, and the note box is as wide as the tags',
   run:function(){
     var oc=document.getElementById('outcome'), w=oc&&oc.querySelector('.ocwin'), tw=document.getElementById('tagwrap'), nb=document.getElementById('oc_note'), was=oc&&oc.classList.contains('on'), bad=[], cs, room, tags, tops={}, nrow=0, tot=0, i, k, need;
     if(!oc||!w||!tw||!nb||typeof buildTags!=='function') return 'SKIP: no run card here';
     try{
       if(!tw.querySelector('.tag')) buildTags();
       oc.classList.add('on');
       cs=getComputedStyle(w);
       room=Math.min(parseFloat(cs.maxWidth)||1e9,(w.parentNode&&w.parentNode.clientWidth)||1e9)-(parseFloat(cs.paddingLeft)||0)-(parseFloat(cs.paddingRight)||0)-(parseFloat(cs.borderLeftWidth)||0)-(parseFloat(cs.borderRightWidth)||0);
       if(!(room>300&&room<5000)) return 'SKIP: the card has no measurable room ('+room+')';
       tags=tw.querySelectorAll('.tag');
       if(tags.length<10) return 'SKIP: only '+tags.length+' feel tags here';
       for(i=0;i<tags.length;i++){ k='r'+tags[i].offsetTop; if(!Object.prototype.hasOwnProperty.call(tops,k)){ tops[k]=1; nrow++; } tot+=tags[i].offsetWidth+6; }
       if(!(tot>0)) return 'SKIP: the tags have no width (the card is not laid out)';
       need=Math.ceil(tot/room);
       if(tw.offsetWidth<room*0.85) bad.push('the tags are held to a '+tw.offsetWidth+' px column in a card with '+Math.round(room)+' px of room');
       if(nrow>need+2) bad.push('the '+tags.length+' tags stack '+nrow+' rows deep where '+need+' rows would hold them');
       if(nb.offsetWidth<tw.offsetWidth*0.9) bad.push('the note box is '+nb.offsetWidth+' px wide under a '+tw.offsetWidth+' px block of tags');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) oc.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
