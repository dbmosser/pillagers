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

if ($s.Contains("  {v:'21.19',what:")) { throw "check 21.19 is in the fixture already" }

SubRx @'
  {v:'21.18',what:
'@ @'
  {v:'21.19',what:'the Undercroft floor belt is not drawn under an open station window, and is drawn again on the bare floor',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof drawHubBelt!=='function'||typeof hubWinOn!=='function') return 'SKIP: no Undercroft here';
     var bad=[], r, n0, n1;
     try{
       __topClear(); __hubEnter(); __wnseen(1);
       if(CFG.hubBelt===0) return 'SKIP: the floor belt is off in this fixture';
       HUBBELT.cells=[]; drawHubBelt(); n0=HUBBELT.cells.length;
       if(!n0) return 'SKIP: staging: the bare floor drew no belt';
       r=__station('trader');
       if(!hubWinOn()) return 'SKIP: staging: the shop window did not open ('+JSON.stringify(r)+')';
       HUBBELT.cells=[]; drawHubBelt(); n1=HUBBELT.cells.length;
       if(n1) bad.push('with the shop window open the floor belt was drawn under it ('+n1+' cells)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __hubEnter(); }catch(_h){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
