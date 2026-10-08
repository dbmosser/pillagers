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

if ($s.Contains("  {v:'18.64',what:")) { throw "check 18.64 is in the fixture already" }

SubRx @'
  {v:'18.63',what:
'@ @'
  {v:'18.64',what:'the shop shows its items big: a shop tile icon is at least 88 across in a tile of 160 or more, and it and the name both stay inside the tile',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, cells, i, c, im, lb, R, I, Lr, n=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       cells=document.querySelectorAll('.modal.on .vcell');
       if(!cells.length) return 'SKIP: the shop drew no tiles';
       for(i=0;i<cells.length&&i<6;i++){
         c=cells[i]; im=c.querySelector('img.ic'); lb=c.querySelector('.vlbl'); if(!im||!lb) continue;
         R=c.getBoundingClientRect(); I=im.getBoundingClientRect(); Lr=lb.getBoundingClientRect();
         if(R.width<20) continue; n++;
         if(R.width>=160&&I.width<88) bad.push('tile '+i+': icon '+Math.round(I.width)+' across in a tile of '+Math.round(R.width));
         if(I.bottom>R.bottom+1||Lr.bottom>R.bottom+1) bad.push('tile '+i+': the icon or its name runs out of the tile');
       }
       if(!n) return 'SKIP: no tile was measurable';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'18.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
