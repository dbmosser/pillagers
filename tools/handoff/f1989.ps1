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

if ($s.Contains("  {v:'19.89',what:")) { throw "check 19.89 is in the fixture already" }

SubRx @'
  {v:'19.88',what:
'@ @'
  {v:'19.89',what:'the corner credits stay in the corner over a card window: with only the PARTY card open the readout keeps its corner place, and with the shop open it moves to the heading row',
   run:function(){
     var tr=document.getElementById('topright'), pm=document.getElementById('partymodal'), tm=document.getElementById('tradermodal'), bad=[], z, a, pOn, tOn;
     if(!tr||!pm||!tm) return 'SKIP: no readout or windows here';
     pOn=pm.classList.contains('on'); tOn=tm.classList.contains('on');
     try{
       [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.add('zqwason'); x.classList.remove('on'); });
       z=parseFloat(tr.style.zoom)||1;
       pm.classList.add('on'); a=tr.getBoundingClientRect();
       if(Math.abs(a.top/z-6)>2) bad.push('with the PARTY card open the readout moved to '+Math.round(a.top/z)+' px');
       pm.classList.remove('on'); tm.classList.add('on'); a=tr.getBoundingClientRect();
       if(Math.abs(a.top/z-24)>2) bad.push('control: with the shop open the readout is at '+Math.round(a.top/z)+' px, not on the heading row');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ pm.classList.toggle('on',pOn); tm.classList.toggle('on',tOn); [].slice.call(document.querySelectorAll('.zqwason')).forEach(function(x){ x.classList.remove('zqwason'); x.classList.add('on'); }); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
