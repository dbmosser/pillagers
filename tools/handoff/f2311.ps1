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

if ($s.Contains("  {v:'23.11',what:")) { throw "check 23.11 is in the fixture already" }

SubRx @'
  {v:'23.10',what:
'@ @'
  {v:'23.11',what:'people lines fit the 34 letter headline and a grudge never reads as friendly: with a 16 letter seat name and a 20 letter pillager tag every people headline is at most 34, the grudge and the betrayal lines and the Peddler turning his back are not said in the teammate colour, and the hand-over, revive, Peddler and Bulwark lines carry no explaining sentence (read off the game source)',
   run:function(){
     var bad=[], src='', i, cut, ss, OLD, NEW, nm16='ABCDEFGHIJKLMNOP', nm20='FBI_SURVEILLANCE_VAN', H;
     try{ ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(_s){}
     cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the game source is not readable here';
     OLD=[' IS JOINING THE'+' RAID',' ABANDONED THE'+' RAID',' CARRIES NOTHING'+' ELSE',' WILL REMEMBER'+' THAT','That is what you'+' paid for','He heard what you did'+' to the last one','No trade while'+' he bleeds','THE BULWARK'+' BLOCKED IT',"('With '+"+"nm+'.')","TURNS HIS BACK','"+"ally'","TRUSTED YOU','"+"ally'","REMEMBER THAT','"+"ally'"];
     for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the build still says '+JSON.stringify(OLD[i]));
     NEW=[" IS"+" JOINING'"," ABANDONED'"+":' IS OUT'"," EMPTY'"+",'info'"," WANTS"+" REVENGE','info'","TRUSTED YOU'"+",'info'","'Cannot take it.'"+":String(nm)","'BULWARK"+" SHIELD'"];
     for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the build has no '+JSON.stringify(NEW[i]));
     H=[nm16+' IS JOINING',nm16+' ABANDONED','HAND-OVER FAILED',nm20+' EMPTY',nm20+' WANTS REVENGE',nm20+' TRUSTED YOU'];
     for(i=0;i<H.length;i++) if(H[i].length>34) bad.push(JSON.stringify(H[i])+' is over 34');
     return bad.length?bad.join('; '):null; }},
  {v:'23.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
