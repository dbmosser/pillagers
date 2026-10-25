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

if ($s.Contains("  {v:'34.63',what:")) { throw "check 34.63 is in the fixture already" }

SubRx @'
  {v:'34.62',what:
'@ @'
  {v:'34.63',what:'the party window is the 90 percent card (his Q43, style guide Window 90 x 90), not a fitted 960 card: five percent insets all round, no shift',
   run:function(){
     if(typeof openParty!=='function'||typeof openModal!=='function') return 'SKIP: no party window';
     var pm, cs, w, h, l, t, tw=window.innerWidth, th=window.innerHeight, r, q, res=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       openParty();
       pm=document.getElementById('partymodal'); cs=getComputedStyle(pm,'::before');
       w=parseFloat(cs.width); h=parseFloat(cs.height); l=parseFloat(cs.left); t=parseFloat(cs.top);
       if(!(Math.abs(w+2*l-pm.offsetWidth)<=4&&Math.abs(h+2*t-pm.offsetHeight)<=4&&Math.abs(l-tw*0.05)<=4&&Math.abs(t-th*0.05)<=4)) return 'the party frame is '+Math.round(w)+' x '+Math.round(h)+' at '+Math.round(l)+','+Math.round(t)+' in a window '+pm.offsetWidth+' x '+pm.offsetHeight+', not the 90 percent card';
       if(cs.transform&&cs.transform!=='none') return 'the party frame is shifted by '+cs.transform;
       return null;
     } finally {
       try{ __topClear(); }catch(_e){}
     } }},
  {v:'34.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
