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

if ($s.Contains("  {v:'20.18',what:")) { throw "check 20.18 is in the fixture already" }

SubRx @'
  {v:'20.17',what:
'@ @'
  {v:'20.18',what:'a card window frame fits its content: the Last Pour frame is at most 170 menu pixels taller than what it holds, and still taller than it',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the bar';
     var bad=[], m, i, c, t=1e9, b=-1e9, fh, span;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('bar','KeyE');
       m=document.getElementById('barmodal'); if(!m||!m.classList.contains('on')) return 'SKIP: the bar did not open';
       for(i=0;i<m.children.length;i++){ c=m.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); b=Math.max(b,c.offsetTop+c.offsetHeight); } }
       span=b-t; fh=parseFloat(getComputedStyle(m,'::before').height);
       if(!(span>0&&fh>0)) return 'SKIP: nothing laid out';
       if(fh>span+170) bad.push('the frame is '+Math.round(fh)+' for '+Math.round(span)+' of content');
       if(fh<span) bad.push('the frame is shorter than its content');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
