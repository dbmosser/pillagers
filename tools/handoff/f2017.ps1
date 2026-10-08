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

if ($s.Contains("  {v:'20.17',what:")) { throw "check 20.17 is in the fixture already" }

SubRx @'
  {v:'20.16',what:
'@ @'
  {v:'20.17',what:'stack counts in the stash sit in a pill: a count on a stash tile has a dark background, padding and space from the corner',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     var bad=[], P2=__P(), s0=(P2.stash||[]).slice(), c=null, cs, cell, a;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       P2.stash=['bandage','bandage','bandage','frag','frag'];
       __hubEnter(); __station('term','KeyE');
       a=[].slice.call(document.querySelectorAll('#stashgrid .cell .cnt')).filter(function(x){ return !/0d1435/.test(x.getAttribute('style')||'')&&x.offsetWidth>0; });
       if(!a.length) return 'SKIP: no stack count showing';
       c=a[0]; cs=getComputedStyle(c); cell=c.parentElement;
       if(!(cs.backgroundColor&&cs.backgroundColor!=='rgba(0, 0, 0, 0)'&&cs.backgroundColor!=='transparent')) bad.push('the count has no background');
       if(!(parseFloat(cs.paddingLeft)>=4)) bad.push('the count has '+cs.paddingLeft+' of padding');
       if(!(cell.clientWidth-(c.offsetLeft+c.offsetWidth)>=4)) bad.push('the count sits in the corner');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P2.stash=s0; try{ renderHub(); }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
