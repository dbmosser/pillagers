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

if ($s.Contains("  {v:'20.94',what:")) { throw "check 20.94 is in the fixture already" }

SubRx @'
  {v:'20.93',what:
'@ @'
  {v:'20.94',what:'the stash sell note lines up with the sell button: its words start on the left edge of the SELL button above it, not a step to the right',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], hub=document.getElementById('hub'), sb, sh, a, b, d;
     function words(el){ var r=document.createRange(); r.selectNodeContents(el); return r.getBoundingClientRect(); }
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       sb=document.getElementById('sellall'); sh=document.getElementById('sellhint');
       if(!sb||!sh||!sb.getBoundingClientRect().width) return 'SKIP: the stash did not open';
       a=words(sh); b=sb.getBoundingClientRect();
       if(!(a.width>0)) return 'SKIP: the sell note is empty here';
       if(Math.abs(a.left-b.left)>2) bad.push('the sell note starts '+Math.round(a.left-b.left)+' px off the left edge of the sell button');
       d=sh.getBoundingClientRect();
       if(d.right>b.right+2) bad.push('the sell note box runs '+Math.round(d.right-b.right)+' px past the sell button');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(hub) hub.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
