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

if ($s.Contains("  {v:'16.15',what:")) { throw "check 16.15 is in the fixture already" }

SubRx @'
  {v:'16.14',what:
'@ @'
  {v:'16.15',what:'plain game language for co-op: the lines added for co-op, the storm and voice read the way a game says them, and none of the old rulebook sentences is left in the build',
   run:function(){
     var src='', bad=[], i, OLD, NEW;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     // the game's own code only: the fixture hooks start at window.__frame, and comment lines are history, not text on screen
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     src=src.split('\n').filter(function(l){ return !(/^\s*\/\//).test(l); }).map(function(l){ var k=l.indexOf('   // '); return k>=0?l.slice(0,k):l; }).join('\n');
     OLD=['The raid runs on until','still up top. The','back down. The raid','takes the party up. Stay','Keep holding','pulls you up.'+String.fromCharCode(39)+');','LEFT THE SURFACE. THE RUN','THE WHOLE PARTY.'+String.fromCharCode(39),'every flash shows you the map and','Wear a headset','The browser asks first','Emotes still work'];
     NEW=['Host has left the raid','Waiting for them to finish','Only the host can start the raid','Reviving ','Revived by ','CONNECTION TO HOST LOST','every flash makes you visible','Headset recommended'];
     for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the rulebook line with "'+OLD[i]+'" is still in the build');
     for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the line "'+NEW[i]+'" is missing');
     return bad.length?bad.join('; '):null; }},
  {v:'16.14',what:
'@


SubRx @'
         else if(!said.some(function(t){ return (/Your host takes the party up/).test(t); })) bad.push('linked to a host, '+st[i][0]+' left him on the floor and said nothing ("'+said.join(' / ')+'")');
'@ @'
         else if(!said.some(function(t){ return (/Only the host can start the raid/).test(t); })) bad.push('linked to a host, '+st[i][0]+' left him on the floor and said nothing ("'+said.join(' / ')+'")');
'@

SubRx @'
     ['GOES UP TOGETHER','WHOEVER SEARCHED','PULL THEM UP','IF THE HOST LEAVES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the second card line does not say '+w.toLowerCase()); });
'@ @'
     ['GOES UP TOGETHER','WHOEVER SEARCHED','REVIVE THEM','IF THE HOST LEAVES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the second card line does not say '+w.toLowerCase()); });
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
