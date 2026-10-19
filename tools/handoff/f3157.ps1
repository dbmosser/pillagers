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

if ($s.Contains("  {v:'31.57',what:")) { throw "check 31.57 is in the fixture already" }

SubRx @'
  {v:'31.56',what:
'@ @'
  {v:'31.57',what:'racks page is one centred 672px column, codex grid is four centred columns, the stash swap note is gone',
   run:function(){
     var bad=[], el, cs, mf, i;
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       mf=document.getElementById('opane_mf');
       if(!mf) bad.push('no racks pane');
       else {
         for(i=0;i<mf.children.length;i++){
           el=mf.children[i]; if(el.classList.contains('msub')) continue;
           cs=getComputedStyle(el);
           if(cs.maxWidth!=='672px') bad.push('racks child '+i+' max-width is '+cs.maxWidth+', not 672px');
         }
         el=document.getElementById('mfhint'); cs=el?getComputedStyle(el):null;
         if(!cs||cs.fontSize!=='16px') bad.push('mfhint font-size is '+(cs&&cs.fontSize));
         el=mf.querySelector('.msub'); if(el&&getComputedStyle(el).display!=='none') bad.push('racks msub still shows');
       }
       el=document.getElementById('codexgrid'); cs=el?getComputedStyle(el):null;
       if(!cs) bad.push('no codex grid');
       else {
         if(cs.maxWidth!=='1344px') bad.push('codex grid max-width is '+cs.maxWidth);
         if(!/repeat\(4|^\S+ \S+ \S+ \S+$/.test(cs.gridTemplateColumns)) bad.push('codex columns: '+cs.gridTemplateColumns);
       }
       el=document.querySelector('#kitsetup .ksnote'); if(el&&getComputedStyle(el).display!=='none') bad.push('stash swap note still shows');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
