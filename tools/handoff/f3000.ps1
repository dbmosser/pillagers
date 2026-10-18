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

if ($s.Contains("  {v:'30.00',what:")) { throw "check 30.00 is in the fixture already" }

SubRx @'
  {v:'29.99',what:
'@ @'
  {v:'30.00',what:'the welcome pack is a centred card 960 wide at most, not a full-window slab (the critic: seven rows hugging the left, buttons 1600px apart)',
   run:function(){
     var el=null, w=0, wm=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       el=document.getElementById('welcomemodal'); if(!el) return 'SKIP: no welcome pack';
       openModal('welcomemodal');
       w=parseFloat(getComputedStyle(el,'::before').width)||0; wm=el.getBoundingClientRect().width;
       if(!(w>0&&w<=961)) return 'the welcome pack frame is '+Math.round(w)+'px wide in a '+Math.round(wm)+'px window; a card is 960 at most';
       return null;
     } finally {
       try{ if(el) el.classList.remove('on'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
