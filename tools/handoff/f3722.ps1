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

if ($s.Contains("  {v:'37.22',what:")) { throw "check 37.22 is in the fixture already" }

SubRx @'
  {v:'37.21',what:
'@ @'
  {v:'37.22',what:'cw-m1mkt2, the critic on v37.20 (P0): the wanted strip took height from the stash grid and cut its last row; it now sits in the stash header row beside the held count, so showing it costs the grid no height; three wanted items, one lower case label, prices in the warn colour',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot stage the stash';
     if(typeof mktWanted!=='function'||typeof renderHub!=='function') return 'SKIP: no market here';
     var bad=[], el, gr, h1, h2, ch, t, i, saved=P;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter(); __station('term','KeyE'); renderHub();
       el=document.getElementById('wanted'); gr=document.getElementById('stashgrid');
       if(!el||!gr) return 'no wanted strip or stash grid here';
       if(!(gr.getBoundingClientRect().height>0)) return 'SKIP: the stash did not open here';
       need(el.style.display!=='none'&&el.querySelectorAll('[data-want]').length===3,'the stash shows '+el.querySelectorAll('[data-want]').length+' wanted items');
       need(!!(el.closest&&el.closest('.lohead')),'the wanted strip is not in the stash header row');
       h1=gr.getBoundingClientRect().height; el.style.display='none'; h2=gr.getBoundingClientRect().height; renderHub();
       need(Math.abs(h1-h2)<=2,'showing the wanted strip takes '+Math.round(h2-h1)+'px from the stash grid ('+Math.round(h1)+' against '+Math.round(h2)+')');
       ch=el.querySelectorAll('[data-want] b');
       for(i=0;i<ch.length;i++) need(getComputedStyle(ch[i]).color===getComputedStyle(document.documentElement).getPropertyValue('--warn').trim()||/245, 183, 59/.test(getComputedStyle(ch[i]).color),'a wanted price is coloured '+getComputedStyle(ch[i]).color+', not the warn colour');
       t=String(el.textContent);
       need(t.indexOf('wanted +50%')===0&&t===t.toLowerCase(),'the strip reads '+JSON.stringify(t));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __topClear(); }catch(_t){}
       P=saved;
       try{ __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
