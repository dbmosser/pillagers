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

if ($s.Contains("  {v:'19.98',what:")) { throw "check 19.98 is in the fixture already" }

SubRx @'
  {v:'19.97',what:
'@ @'
  {v:'19.98',what:'the stash is medium density on the default layout: a wide stash grid shows 6 tiles across at any window size',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], gEl, cols, hub=document.getElementById('hub'), l0=P.stashLayout;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       P.stashLayout=6;
       __hubEnter(); __station('term','KeyE');
       if(hub&&hub.getAttribute('data-slayout')!=='6') return 'SKIP: the stash is not on the default layout';
       gEl=document.getElementById('stashgrid'); if(!gEl||!gEl.getBoundingClientRect().width) return 'SKIP: the stash grid is not showing';
       cols=String(getComputedStyle(gEl).gridTemplateColumns||'').trim().split(/\s+/).filter(function(s){ return /px$/.test(s); }).length;
       if(gEl.clientWidth>=700&&cols!==6) bad.push('the stash grid shows '+cols+' tiles across in '+gEl.clientWidth+' px (wanted 6)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.stashLayout=l0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
