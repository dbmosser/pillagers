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

if ($s.Contains("  {v:'30.51',what:")) { throw "check 30.51 is in the fixture already" }

SubRx @'
  {v:'30.50',what:
'@ @'
  {v:'30.51',what:'the demo hides credits, XP, stash and bag in the top right; career keeps them (his Q55, 10-18)',
   run:function(){
     if(typeof trDemo!=='function') return 'no trDemo: the corner readout is not hidden in the demo';
     var el=document.getElementById('topright'), on0=ARCADE.on, t1, t2;
     if(!el) return 'SKIP: no corner readout';
     try{
       ARCADE.on=0; _trLast=''; syncTopRight(); t1=el.textContent;
       ARCADE.on=1; syncTopRight(); t2=el.textContent;
       if(!/CREDITS/.test(t1)) return 'career shows no credits in the corner: '+t1;
       if(t2!=='') return 'the demo still shows the corner readout: '+t2;
       return null;
     } finally { ARCADE.on=on0; _trLast=''; try{ syncTopRight(); }catch(_e){} } }},
  {v:'30.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
