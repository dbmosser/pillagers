# A card refresh stamped with the build it ships as (reads VER and the old stamp at run time): the elites, kit and stash news.
$g=[IO.File]::ReadAllText('C:\claudecode\dark raiders\dark_raiders.html')
$inv=[Globalization.CultureInfo]::InvariantCulture
function L([string]$rx){ $m=[regex]::Matches($g,$rx); if($m.Count -ne 1){ throw "anchor $rx matched $($m.Count)" }; return $m[0].Value.Replace("`r",'') }
$ver=[regex]::Match($g,"var VER='([0-9.]+)'").Groups[1].Value
$old=[regex]::Match($g,"var WHATSNEW_VER='([0-9.]+)';").Groups[1].Value
if(-not $ver -or -not $old){ throw 'no VER or WHATSNEW_VER' }
$next=([double]::Parse($ver,$inv)+0.01).ToString('0.00',$inv)
$Line='MORE POLISH. Cleaner screens and sharper feedback across the raid, from the gun bar to the end cards.'
$rest=$Line.Substring($Line.IndexOf('. ')+2); if($rest.Length -gt 150){ throw "the card line rest is $($rest.Length) long, over 150" }
$aV=L ("var WHATSNEW_VER='"+[regex]::Escape($old)+"';")
$aAlpha=L "(?m)^  'THIS IS AN ALPHA\.[^\r\n]*"
$chk=@'
  {v:'VER',what:'the what is new card is stamped within 0.15 of the build and leads with the new news shown whole',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof wnShort!=='function') return 'SKIP: this build has no what is new card';
     if(parseFloat(WHATSNEW_VER)>STAMP+0.001) return 'SKIP: the card has moved on, a later card check covers it';
     var bad=[], d=parseFloat(VER)-parseFloat(WHATSNEW_VER);
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(String(WHATSNEW[1]).indexOf('MORE'+' POLISH.')!==0) bad.push('the card does not lead with the new news');
     else if(wnShort(WHATSNEW[1]).slice(-3)==='...') bad.push('the new line is cut on the card');
     if(String(WHATSNEW[0]).indexOf('THIS IS AN'+' ALPHA')!==0) bad.push('the card no longer opens with the alpha line');
     return bad.length?bad.join('; '):null; }},
'@.Replace("`r",'').Replace('STAMP',$next)
$d=[ordered]@{
  title='THE WHAT IS NEW CARD NAMES THE POLISH PASS'
  why=("The card was stamped v"+$old+" and the stamp may not trail the build by more than 0.15. Its new line names the polish builds since.")
  now='The what is new card names the polish pass.'
  edits=@(
    [ordered]@{ anchor=$aV; replacement=("var WHATSNEW_VER='"+$next+"';") },
    [ordered]@{ anchor=$aAlpha; replacement=($aAlpha+"`n  '"+$Line+"',") }
  )
  check=$chk
}
[IO.File]::WriteAllText('C:\claudecode\dark raiders\tools\handoff\drafts\draft-card-autoA3.json',($d | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding $false))
'written '+$next+' (rest '+$rest.Length+')'
