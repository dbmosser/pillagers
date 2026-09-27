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

if ($s.Contains("  {v:'16.42',what:")) { throw "check 16.42 is in the fixture already" }

SubRx @'
  {v:'16.41',what:
'@ @'
  {v:'16.42',what:'kill feed: a party kill becomes a NAME killed WHAT line on every window, its own as YOU',
   run:function(){
     if(typeof netFeedPush!=='function'||typeof netFeedTake!=='function'||typeof netFeedKill!=='function') return 'this build has no kill feed';
     var keep={role:NET.role,seat:NET.seat,roster:NET.roster,feed:NET.feed}, oB=netBroadcast, sent=[], bad=[], r;
     try{
       netBroadcast=function(m){ sent.push(m); return 1; };
       NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'}]; NET.feed=[];
       NET.role='host'; NET.seat=0;
       netFeedKill(1,{kind:'crawler',elite:1});
       if(!sent.length||sent[0].t!=='kf'||sent[0].s!==1||sent[0].w!=='ELITE CRAWLER') bad.push('the host sent '+JSON.stringify(sent[0]));
       if(!NET.feed.length||NET.feed[0].txt!=='MOSS killed ELITE CRAWLER') bad.push('the host feed reads '+JSON.stringify(NET.feed[0]));
       NET.role='join'; NET.seat=1; NET.feed=[];
       r=netFeedTake({state:'in'},{t:'kf',s:1,w:'RatioedInChat'});
       if(r!=='kf'||!NET.feed.length||NET.feed[0].txt!=='YOU killed RatioedInChat'||!NET.feed[0].me) bad.push('the teammate feed reads '+JSON.stringify(NET.feed[0])+' ('+r+')');
       for(var i=0;i<6;i++) netFeedPush(0,'SENTRY');
       if(NET.feed.length!==4) bad.push('the feed keeps '+NET.feed.length+' lines, not four');
     } finally { netBroadcast=oB; NET.role=keep.role; NET.seat=keep.seat; NET.roster=keep.roster; NET.feed=keep.feed; }
     return bad.length?bad.join('; '):null; }},
  {v:'16.41',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
