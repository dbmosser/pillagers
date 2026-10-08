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

if ($s.Contains("  {v:'20.25',what:")) { throw "check 20.25 is in the fixture already" }

SubRx @'
  {v:'20.24',what:
'@ @'
  {v:'20.25',what:'the craft resource rows are readable: on a recipe card the resource names are 16px or more with 30px pictures',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the shop';
     var bad=[], tab, c, row, nm, im;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('trader','KeyE');
       tab=[].slice.call(document.querySelectorAll('#tradertabs .invtab')).filter(function(x){ return x.textContent.trim()==='CRAFT'; })[0];
       if(!tab) return 'SKIP: no CRAFT tab'; tab.click();
       c=document.querySelector('#craftgrid .vcell'); if(!c) return 'SKIP: no recipe'; c.click();
       row=document.querySelector('#craftdetail .cres'); if(!row) return 'SKIP: no resource rows';
       nm=row.querySelector('.crn'); im=row.querySelector('img');
       if(!(parseFloat(getComputedStyle(nm).fontSize)>=15.9)) bad.push('the resource name is '+getComputedStyle(nm).fontSize);
       if(im&&!(im.getBoundingClientRect().width>=im.ownerDocument.documentElement.clientWidth*0+0&&parseFloat(getComputedStyle(im).width)>=29)) bad.push('the resource picture is '+getComputedStyle(im).width);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
