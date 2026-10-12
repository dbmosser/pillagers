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

if ($s.Contains("  {v:'23.71',what:")) { throw "check 23.71 is in the fixture already" }

SubRx @'
  {v:'23.70',what:
'@ @'
  {v:'23.71',what:'his answer (2026-10-12): the version players see restarts at v0.0001, counted one per build from the build that made the change, on the title and the corner label, while the run report carries both numbers and the internal VER is unchanged',
   run:function(){
     if(typeof verShown!=='function'||typeof PVER_RESET!=='string') return 'no player version in this build: the title still shows the build number';
     var bad=[], a=PVER_RESET.split('.'), r=parseInt(a[0],10)*100+parseInt(a[1],10), b=String(VER).split('.'), v=parseInt(b[0],10)*100+parseInt(b[1],10), n=v-r+1, want, s, t, el, rep='';
     function num(k){ return Math.floor(k/100)+'.'+(k%100<10?'0':'')+(k%100); }
     if(verShown(PVER_RESET)!=='v0.0001') bad.push('the reset build shows '+verShown(PVER_RESET)+', not v0.0001');
     if(verShown(num(r+1))!=='v0.0002') bad.push('the build after the reset shows '+verShown(num(r+1))+', not v0.0002');
     if(verShown(num(r+12))!=='v0.0013') bad.push('twelve builds on shows '+verShown(num(r+12))+', not v0.0013');
     if(verShown(num(r-5))!=='v'+num(r-5)) bad.push('a copy from before the reset is shown as '+verShown(num(r-5)));
     if(verShown(num(r-5),1)!=='v0.0001') bad.push('the floored form of an older number is '+verShown(num(r-5),1));
     if(!(n>=1)) bad.push('this build '+VER+' is older than its own reset '+PVER_RESET);
     s=String(n); while(s.length<4) s='0'+s; want='v0.'+s;
     if(verShown(VER)!==want) bad.push('this build shows '+verShown(VER)+', not '+want);
     if(!/^\d+\.\d\d$/.test(String(VER))) bad.push('the internal VER is no longer a build number: '+VER);
     el=document.getElementById('titlever'); t=el?String(el.textContent||''):'';
     if(el&&t!==want) bad.push('the title shows '+t+', not '+want);
     el=document.getElementById('verlabel'); t=el?String(el.textContent||''):'';
     if(el&&t!==''&&t!==want) bad.push('the corner label shows '+t+', not '+want);
     try{ rep=String(buildExport()); }catch(x){ bad.push('the run report threw: '+(x&&x.message||x)); }
     if(rep&&(rep.indexOf(want)<0||rep.indexOf('build '+VER)<0)) bad.push('the run report header does not carry both '+want+' and build '+VER+': '+rep.split('\n')[0]);
     return bad.length?bad.join('; '):null; }},
  {v:'23.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
