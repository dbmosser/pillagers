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

if ($s.Contains("  {v:'16.39',what:")) { throw "check 16.39 is in the fixture already" }

SubRx @'
  {v:'16.38',what:
'@ @'
  {v:'16.39',what:'one hit of Blotter draws at half strength, and Liquor and Blotter reach the open menu panels',
   run:function(){
     if(typeof buzzMenuFx!=='function') return 'the menu screens never feel Liquor or Blotter';
     var m=document.createElement('div'), c=document.createElement('div'), bad=[];
     m.className='modal on'; m.appendChild(c); document.body.appendChild(m);
     try{
       BUZZMENU=''; buzzMenuFx(2,0);
       if(c.style.filter.indexOf('blur')<0||!c.style.transform) bad.push('Liquor does not blur and sway an open panel ('+c.style.filter+' / '+c.style.transform+')');
       buzzMenuFx(0,2);
       if(c.style.filter.indexOf('hue-rotate')<0) bad.push('Blotter does not shift the colour of an open panel ('+c.style.filter+')');
       buzzMenuFx(0,0);
       if(c.style.filter||c.style.transform) bad.push('the panel keeps the effect after the buzz is gone');
     } finally { document.body.removeChild(m); BUZZMENU=''; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("*Math.min(1,0.5*_lsd+0.5*Math.max(0,_lsd-1))")<0) bad.push('one hit of Blotter is as strong as before');
     return bad.length?bad.join('; '):null; }},
  {v:'16.38',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
