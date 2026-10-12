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

if ($s.Contains("  {v:'23.89',what:")) { throw "check 23.89 is in the fixture already" }

SubRx @'
  {v:'23.88',what:
'@ @'
  {v:'23.89',what:'his order #50: the AAA fonts (Barlow Condensed, Barlow, IBM Plex Mono) are embedded and loaded',
   run:function(){
     var fams={}, i, j, r, sh, rules, bad=[];
     for(i=0;i<document.styleSheets.length;i++){
       sh=document.styleSheets[i]; try{ rules=sh.cssRules||[]; }catch(_x){ continue; }
       for(j=0;j<rules.length;j++){ r=rules[j];
         if(r.type===5){ var fam=String(r.style.getPropertyValue('font-family')).replace(/["']/g,'').trim(), src=String(r.style.getPropertyValue('src'));
           if(/^(Barlow|Barlow Condensed|IBM Plex Mono)$/.test(fam)&&src.indexOf('data:font/woff2')>=0) fams[fam+' '+r.style.getPropertyValue('font-weight')]=1; } } }
     ['Barlow Condensed 500','Barlow Condensed 600','Barlow Condensed 700','Barlow Condensed 800','Barlow 400','Barlow 500','Barlow 600','IBM Plex Mono 500'].forEach(function(k){ if(!fams[k]) bad.push('no embedded face '+k); });
     if(typeof UIFONTS!=='object') bad.push('no UIFONTS loader');
     else if(!UIFONTS.ready) bad.push('the embedded faces are not loaded yet');
     return bad.length?bad.join('; '):null; }},
  {v:'23.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
