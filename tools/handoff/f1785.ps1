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

if ($s.Contains("  {v:'17.85',what:")) { throw "check 17.85 is in the fixture already" }

SubRx @'
  {v:'17.84',what:
'@ @'
  {v:'17.85',what:'the Keys window is set in the game font like every other window and its list scrolls inside the window instead of running past the bottom',
   run:function(){
     if(typeof keysOpen!=='function') return 'SKIP: this build has no Keys window';
     var bad=[], m, ref=document.getElementById('partymodal'), list, fm, fr;
     try{
       keysOpen(); m=document.getElementById('keysmodal'); list=document.getElementById('keyslist');
       if(!m||!list) return 'SKIP: the Keys window did not open';
       fm=getComputedStyle(list).fontFamily; fr=ref?getComputedStyle(ref).fontFamily:'';
       if(ref&&fm!==fr) bad.push('the Keys list is set in '+fm+', the party window in '+fr);
       if(/times/i.test(fm)) bad.push('the Keys list is in Times');
       if(list.scrollHeight>list.clientHeight+2&&getComputedStyle(list).overflowY!=='auto'&&getComputedStyle(list).overflowY!=='scroll') bad.push('the Keys list runs past its box and cannot scroll');
       if(m.getBoundingClientRect().bottom>innerHeight+1) bad.push('the Keys window runs '+Math.round(m.getBoundingClientRect().bottom-innerHeight)+' px past the bottom');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var mm=document.getElementById('keysmodal'); if(mm) mm.classList.remove('on'); }catch(_m){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
