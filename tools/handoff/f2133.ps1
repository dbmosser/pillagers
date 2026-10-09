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

if ($s.Contains("  {v:'21.33',what:")) { throw "check 21.33 is in the fixture already" }

SubRx @'
  {v:'21.32',what:
'@ @'
  {v:'21.33',what:'on the lift page the DAY button and the SURPRISE ME button under it start in one column',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function') return 'SKIP: no stations here';
     var bad=[], t, a, b, ra, rb;
     function shut(){ var q=document.querySelectorAll('.modal.on'), i; for(i=0;i<q.length;i++) q[i].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('lift','KeyE');
       a=document.getElementById('condday'); b=document.querySelector('#sectorwx .wxb');
       if(!a||!b) return 'SKIP: no surface or weather row here';
       ra=a.getBoundingClientRect(); rb=b.getBoundingClientRect();
       if(!(ra.width>0&&rb.width>0)) return 'SKIP: the lift page did not open';
       if(!(rb.top>ra.top)) return 'SKIP: the weather row is not under the surface row here';
       if(Math.abs(ra.left-rb.left)>0.75) bad.push('DAY starts '+(rb.left-ra.left).toFixed(1)+' px left of SURPRISE ME under it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ shut(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
