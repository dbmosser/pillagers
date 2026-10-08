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

if ($s.Contains("  {v:'19.69',what:")) { throw "check 19.69 is in the fixture already" }

SubRx @'
  {v:'19.68',what:
'@ @'
  {v:'19.69',what:'the controller focus is easy to see: a focused element has a 3px amber outline, a glow, and full strength even when faded',
   run:function(){
     var m=document.createElement('div'), el=document.createElement('div'), bad=[], s;
     try{
       m.className='modal on'; m.id='zqxpadring'; m.style.zIndex='-1';
       el.style.cssText='width:80px;height:40px;opacity:.4'; el.className='padfocus';
       m.appendChild(el); document.body.appendChild(m);
       s=getComputedStyle(el);
       if(!(parseFloat(s.outlineWidth)>=3)) bad.push('the focus outline is '+s.outlineWidth);
       if(!(/rgba\(255, 192, 74/.test(s.boxShadow)&&(s.boxShadow.match(/rgba/g)||[]).length>=2)) bad.push('the focus has no glow ('+s.boxShadow.slice(0,60)+')');
       if(parseFloat(s.opacity)<1) bad.push('a faded element stays faded when focused ('+s.opacity+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ document.body.removeChild(m); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'19.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
