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

if ($s.Contains("  {v:'29.14',what:")) { throw "check 29.14 is in the fixture already" }

SubRx @'
  {v:'29.13',what:
'@ @'
  {v:'29.14',what:'no all-caps text outside the menus either: the whole page is watched, tooltips and placeholders are fixed, the Taken stamp is not capitals (his hard rule 2026-10-18)',
   run:function(){
     if(typeof txDom!=='function'||typeof TXOBS==='undefined'||!TXOBS) return 'SKIP: no text watcher';
     var el, el2, rec, cs, b, v;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       el=document.createElement('div'); el.textContent='PRESS ANY KEY'; document.body.appendChild(el);
       rec=TXOBS.takeRecords();
       if(!rec.length){ document.body.removeChild(el); return 'text added outside #root is not watched'; }
       el.setAttribute('title','DRAG ONTO ANOTHER KEY'); el.setAttribute('placeholder','TYPE YOUR NOTE');
       rec=TXOBS.takeRecords();
       if(!rec.length){ document.body.removeChild(el); return 'a tooltip changed outside #root is not watched'; }
       txDom(document.body);
       v=el.textContent+'|'+el.getAttribute('title')+'|'+el.getAttribute('placeholder');
       document.body.removeChild(el);
       if(v!=='Press any key|Drag onto another key|Type your note') return 'outside #root the text, tooltip and placeholder read: '+v;
       el2=document.createElement('div'); el2.className='vcell took'; document.body.appendChild(el2);
       cs=getComputedStyle(el2,'::after').content; document.body.removeChild(el2);
       if(/[A-Z]{3}/.test(cs)) return 'the Taken stamp is in capitals: '+cs;
       if(typeof renderGamble==='function'){ try{ P.credits=0; renderGamble(); }catch(_g){} b=document.getElementById('gamblebtn');
         if(b&&b.getAttribute('data-need')&&/[A-Z]{3}/.test(b.getAttribute('data-need'))) return 'the gamble reason chip is in capitals: '+b.getAttribute('data-need'); }
       return null;
     } finally {
       __topClear();
     } }},
  {v:'29.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
