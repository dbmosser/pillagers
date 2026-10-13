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

if ($s.Contains("  {v:'24.87',what:")) { throw "check 24.87 is in the fixture already" }

SubRx @'
  {v:'24.86',what:
'@ @'
  {v:'24.87',what:'his #50 (UI redesign ui5q1w, from the visual QA of the Keys window): the Keys list is at most 1100px wide, its action names are drawn in caps at 17px or more, and each key is a keycap with a thicker lower edge',
   run:function(){
     if(typeof keysOpen!=='function') return 'SKIP: no Keys window here';
     var bad=[], l, b, k, s;
     try{
       keysOpen(); l=document.getElementById('keyslist');
       if(!l) return 'SKIP: the Keys window did not build';
       if(!(parseFloat(getComputedStyle(l).maxWidth)<=1100)) bad.push('the Keys list has no width cap ('+getComputedStyle(l).maxWidth+')');
       b=l.querySelector('.row b'); k=l.querySelector('.keybtn');
       if(b){ s=getComputedStyle(b); if(s.textTransform!=='uppercase'||!(parseFloat(s.fontSize)>=17)) bad.push('an action name is '+s.fontSize+' '+s.textTransform); }
       if(k){ s=getComputedStyle(k); if(!(parseFloat(s.borderBottomWidth)>parseFloat(s.borderTopWidth))) bad.push('a key is a flat box, not a keycap'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var m=document.getElementById('keysmodal'); if(m) m.classList.remove('on'); KEYS.waiting=null; }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
