# 10-21 (coordinator): a What's New STAMP refresh for the three-short-notes card (v33.49). The old genP.sh card adds a "POLISH PASS N."
# line, which check 33.49 bans and his short lower case text rule forbids, so this one moves only WHATSNEW_VER to the build it ships as
# and keeps the three real notes exactly as they are. Reads VER and the old stamp at run time, so it can be shipped again later.
$g=[IO.File]::ReadAllText('C:\claudecode\dark raiders\dark_raiders.html')
$inv=[Globalization.CultureInfo]::InvariantCulture
function L([string]$rx){ $m=[regex]::Matches($g,$rx); if($m.Count -ne 1){ throw "anchor $rx matched $($m.Count)" }; return $m[0].Value.Replace("`r",'') }
$ver=[regex]::Match($g,"var VER='([0-9.]+)'").Groups[1].Value
$old=[regex]::Match($g,"var WHATSNEW_VER='([0-9.]+)';").Groups[1].Value
if(-not $ver -or -not $old){ throw 'no VER or WHATSNEW_VER' }
$next=([double]::Parse($ver,$inv)+0.01).ToString('0.00',$inv)
# 10-21 04:40: a fresh stamp ships nothing (v33.63 was a needless stamp move: a lane's card had just made it current at v33.62).
if(([double]::Parse($ver,$inv)-[double]::Parse($old,$inv)) -le 0.10){ throw "the stamp is fresh (v$old for v$ver): nothing to ship" }
$aV=L ("var WHATSNEW_VER='"+[regex]::Escape($old)+"';")
$chk=@'
  {v:'VER',what:'the what is new card is stamped with this build or later and still shows the three short lowercase real notes',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof wnList!=='function') return 'SKIP: this build has no what is new card';
     if(parseFloat(WHATSNEW_VER)>STAMP+0.001) return 'SKIP: the card has moved on, a later card check covers it';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER), lines=wnList(), i;
     if(!(parseFloat(WHATSNEW_VER)>=STAMP-0.001)) bad.push('the card is stamped v'+WHATSNEW_VER+', before vSTAMP');
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(lines.length!==3) bad.push('the card shows '+lines.length+' notes, not three');
     for(i=0;i<lines.length;i++){ if(String(lines[i])!==String(lines[i]).toLowerCase()||String(lines[i]).length>48) bad.push('note '+i+' is not short lowercase text'); }
     if(/\balpha\b|polish pass/i.test(WHATSNEW.join('|'))) bad.push('the news has filler copy');
     return bad.length?bad.join('; '):null; }},
'@.Replace("`r",'').Replace('STAMP',$next)
$d=[ordered]@{
  title='THE WHAT IS NEW STAMP KEEPS UP'
  why=("The card was stamped v"+$old+" and the stamp may not trail the build by more than 0.15, so every ship stopped on check 33.46. Only the stamp moves; the three short notes stay.")
  now='The what is new stamp keeps up with the build; the three notes are unchanged.'
  edits=@(
    [ordered]@{ anchor=$aV; replacement=("var WHATSNEW_VER='"+$next+"';") }
  )
  check=$chk
}
[IO.File]::WriteAllText('C:\claudecode\dark raiders\tools\handoff\drafts\draft-cw-cardstamp.json',($d | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding $false))
'written '+$next
