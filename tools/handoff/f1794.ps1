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

if ($s.Contains("  {v:'17.94',what:")) { throw "check 17.94 is in the fixture already" }

SubRx @'
  {v:'17.93',what:
'@ @'
  {v:'17.94',what:'stage A of the styling pass: every menu button is rounded to one radius with one minimum height, the primary button is a gradient, modal headers are uppercase amber with a rule under them, inputs are dark with rounded corners',
   run:function(){
     var bad=[], m=document.getElementById('partymodal'), tmp=document.createElement('div'), b, d, h, i, s;
     if(!m) return 'SKIP: no modal to measure in';
     tmp.innerHTML='<button>x</button><button class="deploy">y</button><input type="text" value="z">';
     m.appendChild(tmp); b=tmp.children[0]; d=tmp.children[1]; i=tmp.children[2]; h=m.querySelector('h3');
     try{
       if(b){ s=getComputedStyle(b); if(parseFloat(s.borderTopLeftRadius)<5) bad.push('menu buttons are square ('+s.borderTopLeftRadius+')'); if(parseFloat(s.minHeight)<36) bad.push('menu buttons have no minimum height ('+s.minHeight+')'); } else bad.push('no menu button to measure');
       if(d){ s=getComputedStyle(d); if(!/gradient/.test(s.backgroundImage)) bad.push('the primary button is flat ('+s.backgroundImage.slice(0,40)+')'); }
       if(h){ s=getComputedStyle(h); if(s.textTransform!=='uppercase') bad.push('modal headers are not uppercase'); if(parseFloat(s.borderBottomWidth)<1) bad.push('modal headers have no rule under them'); }
       if(i){ s=getComputedStyle(i); if(parseFloat(s.borderTopLeftRadius)<5) bad.push('inputs are square ('+s.borderTopLeftRadius+')'); }
       m=document.getElementById('partymodal'); if(m){ s=getComputedStyle(m); if(!/gradient/.test(s.backgroundImage)) bad.push('modals have no light from the top'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ m.removeChild(tmp); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
