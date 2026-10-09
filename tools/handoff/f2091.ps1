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

if ($s.Contains("  {v:'20.91',what:")) { throw "check 20.91 is in the fixture already" }

SubRx @'
  {v:'20.90',what:
'@ @'
  {v:'20.91',what:'the shop tabs hold still: switching from BUY to CRAFT to HIRE moves no tab sideways and changes no tab width',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof openTrader!=='function') return 'SKIP: no shop here';
     var bad=[], t, tabs=['buy','craft','hire'], i, k, pos=[], m, worst=0, at='';
     function grab(){ var o={}, a=document.querySelectorAll('#tradertabs .invtab'), j, r; for(j=0;j<a.length;j++){ r=a[j].getBoundingClientRect(); o[String(a[j].textContent||'').trim()]={l:r.left,w:r.width}; } return o; }
     function shut(){ var a=document.querySelectorAll('.modal.on'), q; for(q=0;q<a.length;q++) a[q].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       for(i=0;i<tabs.length;i++){ openTrader(tabs[i]); pos.push(grab()); }
       if(!Object.keys(pos[0]).length) return 'SKIP: the shop drew no tabs';
       for(k in pos[0]){
         if(!(pos[0][k].w>0)) continue;
         for(i=1;i<pos.length;i++){
           if(!pos[i][k]) continue;
           m=Math.max(Math.abs(pos[i][k].l-pos[0][k].l),Math.abs(pos[i][k].w-pos[0][k].w));
           if(m>worst){ worst=m; at=k+' tab (on '+tabs[i].toUpperCase()+')'; }
         }
       }
       if(worst>0.75) bad.push('the '+at+' moves or changes width by '+worst.toFixed(1)+' px when the tab changes');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ shut(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
