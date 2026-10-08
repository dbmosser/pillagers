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

if ($s.Contains("  {v:'19.92',what:")) { throw "check 19.92 is in the fixture already" }

SubRx @'
  {v:'19.91',what:
'@ @'
  {v:'19.92',what:'a dead control looks dead under the controller highlight: a disabled button with the highlight stays dimmed, and an empty slot with it is at full strength',
   run:function(){
     var m=document.createElement('div'), b=document.createElement('button'), c=document.createElement('div'), bad=[], ob, oc;
     try{
       m.className='modal on'; m.style.zIndex='-1';
       b.textContent='ZQ DEAD'; b.disabled=true; b.className='padfocus';
       c.style.cssText='width:40px;height:40px;opacity:.4'; c.className='padfocus';
       m.appendChild(b); m.appendChild(c); document.body.appendChild(m);
       ob=parseFloat(getComputedStyle(b).opacity); oc=parseFloat(getComputedStyle(c).opacity);
       if(!(ob<0.8)) bad.push('a disabled button under the highlight is at opacity '+ob);
       if(oc<1) bad.push('control: a faded slot under the highlight is at opacity '+oc);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ document.body.removeChild(m); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'19.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
