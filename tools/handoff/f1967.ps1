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

if ($s.Contains("  {v:'19.67',what:")) { throw "check 19.67 is in the fixture already" }

SubRx @'
  {v:'19.66',what:
'@ @'
  {v:'19.67',what:'the craft panel shows what an item does: choosing the Medkit recipe, the panel names its heal and that it heals up to 100',
   run:function(){
     if(!window.__station||!window.__hubEnter||typeof itemStatsHTML!=='function') return 'SKIP: no craft panel stats here';
     var bad=[], t, tab, tiles, i, mk=null, d, tx;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       tab=[].slice.call(document.querySelectorAll('#tradertabs .invtab')).filter(function(x){ return x.textContent==='CRAFT'; })[0];
       if(!tab) return 'SKIP: no CRAFT tab';
       tab.click();
       tiles=[].slice.call(document.querySelectorAll('#craftgrid .vcell'));
       for(i=0;i<tiles.length;i++) if(String(tiles[i].textContent||'').indexOf(ITEMS.medkit.name)>=0&&String(tiles[i].textContent||'').indexOf('Component')<0){ mk=tiles[i]; break; }
       if(!mk) return 'SKIP: no Medkit recipe tile';
       mk.click();
       d=document.getElementById('craftdetail');
       if(!d||String(d.textContent||'').indexOf(ITEMS.medkit.name)<0) return 'SKIP: the Medkit recipe did not open';
       tx=String(d.textContent||'');
       if(tx.indexOf('Heals up to')<0||tx.indexOf('100 health')<0) bad.push('the craft panel shows no numbers for the Medkit');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
