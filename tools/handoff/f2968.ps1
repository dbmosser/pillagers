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

if ($s.Contains("  {v:'29.68',what:")) { throw "check 29.68 is in the fixture already" }

SubRx @'
  {v:'29.67',what:
'@ @'
  {v:'29.68',what:'the detail pane of the shop, craft, hire and contracts windows is a dark pane (raised graphite, light title and text), not the cream paper card',
   run:function(){
     var bad=[], el=null;
     function lum(c){ var m=/rgba?\((\d+),\s*(\d+),\s*(\d+)/.exec(c||''); return m?(0.2126*m[1]+0.7152*m[2]+0.0722*m[3]):-1; }
     try{
       var rt=document.getElementById('root')||document.body;
       el=document.createElement('div'); el.className='vdet'; el.style.display='none';
       el.innerHTML='<h4>t</h4><div class="vdesc">d</div><div class="vprice">P<b>1</b></div>';
       rt.appendChild(el);
       var cs=getComputedStyle(el), bl=lum(cs.backgroundColor);
       if(bl<0||bl>90) bad.push('the detail pane fill is '+cs.backgroundColor+' (light)');
       var hl=lum(getComputedStyle(el.querySelector('h4')).color);
       if(hl<180) bad.push('the pane title is dark ('+getComputedStyle(el.querySelector('h4')).color+')');
       var dl=lum(getComputedStyle(el.querySelector('.vdesc')).color);
       if(dl<120) bad.push('the pane text is dark');
       var fs=parseFloat(getComputedStyle(el.querySelector('h4')).fontSize);
       if(fs<32||fs>33) bad.push('the pane title is '+fs+'px, not 32');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(el&&el.parentNode) el.parentNode.removeChild(el); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
