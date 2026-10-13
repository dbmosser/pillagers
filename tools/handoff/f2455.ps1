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

if ($s.Contains("  {v:'24.55',what:")) { throw "check 24.55 is in the fixture already" }

SubRx @'
  {v:'24.54',what:
'@ @'
  {v:'24.55',what:'his #50 (UI redesign ui5q1i, from the lint of the craft shot): on the craft tab a tile you cannot make yet keeps its name at full strength (no fade on the name or the tile) and still dims its picture',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], el, lb, pic, o;
     function opac(e){ var v=1; for(var p=e;p&&p.nodeType===1;p=p.parentElement){ v*=parseFloat(getComputedStyle(p).opacity); } return v; }
     try{
       __topClear(); __hubEnter(); __station('trader','KeyR');
       el=document.querySelector('#craftgrid .vcell.locked');
       if(!el) return 'SKIP: no recipe on the craft tab is out of reach here';
       lb=el.querySelector('.vlbl');
       if(!lb) bad.push('control: a locked craft tile has no name');
       else { o=opac(lb); if(o<0.99) bad.push('a locked craft tile fades its name to '+o.toFixed(2)); }
       pic=[].filter.call(el.children,function(c){ return !c.classList.contains('vlbl'); })[0];
       if(pic&&opac(pic)>0.9) bad.push('a locked craft tile no longer dims its picture');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
