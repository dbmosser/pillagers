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

if ($s.Contains("  {v:'32.87',what:")) { throw "check 32.87 is in the fixture already" }

SubRx @'
  {v:'32.86',what:
'@ @'
  {v:'32.87',what:'the ui-shared block holds no raw pixel sizes or colours: the title tagline margin uses the spacing tokens (24px is sp-3, 16px is sp-2) and looks the same',
   run:function(){
     var st=document.getElementById('ui-shared'), txt, bodies, i, bad=[], el, cs;
     if(!st) return 'SKIP: no <style id=ui-shared> block';
     txt=st.textContent.replace(/\/\*[\s\S]*?\*\//g,'');
     bodies=(txt.match(/[^{}]*\{[^}]*\}/g)||[]).filter(function(r){ return /#title\b|#modecoop|#modearcade|#titlestart/.test(r.slice(0,r.indexOf('{'))); }).map(function(r){ return r.slice(r.indexOf('{')); });
     if(bodies.length<5) return 'ui-shared has no title rules';
     for(i=0;i<bodies.length;i++){
       if(/#[0-9a-fA-F]{3,8}\b/.test(bodies[i])||/rgba?\(/.test(bodies[i])||/font-size\s*:\s*[\d.]+(px|em|rem)/.test(bodies[i])||/font\s*:[^;]*[\d.]+px/.test(bodies[i])||/(^|[^\w.-])(?!1px\b|3px\b)\d+(\.\d+)?px/.test(bodies[i])) bad.push(bodies[i].slice(0,70));
     }
     if(bad.length) return bad.length+' ui-shared rules keep raw literals, first: '+bad[0];
     el=document.getElementById('titletag');
     if(el&&el.getClientRects().length){ cs=getComputedStyle(el); if(cs.marginTop!=='24px'||cs.marginBottom!=='16px') return 'the title tagline margin is '+cs.marginTop+' and '+cs.marginBottom+', not 24px and 16px'; }
     return null; }},
  {v:'32.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
