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

if ($s.Contains("  {v:'20.04',what:")) { throw "check 20.04 is in the fixture already" }

SubRx @'
  {v:'20.03',what:
'@ @'
  {v:'20.04',what:'the BUILD tiles in FASHION show you in each build: each of the three tiles has a painted picture, and the three pictures differ',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open FASHION';
     var bad=[], tiles, srcs={}, i, im, n=0;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('mirror','KeyE');
       tiles=[].slice.call(document.querySelectorAll('.modal.on .costile[data-kind="build"]'));
       if(tiles.length<3) return 'SKIP: the BUILD row is not showing';
       for(i=0;i<tiles.length;i++){ im=tiles[i].querySelector('img'); if(!im){ bad.push('the '+tiles[i].getAttribute('data-id')+' tile has no picture'); continue; } srcs[im.getAttribute('src')]=1; n++; }
       if(n===tiles.length&&Object.keys(srcs).length<tiles.length) bad.push('the build pictures are not all different');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(m){ m.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
