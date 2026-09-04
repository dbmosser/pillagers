$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== A BASELINE HELD ACROSS THE WHOLE CHECK IS NOT A BASELINE. Two draws of the
# ==== same look are byte identical back to back, and standalone they stay
# ==== identical all run. Inside the check something between the shots moves 621
# ==== pixels, and 621 is larger than the tattoo signal I was asserting on, so the
# ==== tattoo would have passed on a build that draws no tattoo at all. I do not
# ==== know yet what drifts, so the measurement stops depending on it: every rack
# ==== is now measured against a baseline drawn IMMEDIATELY BEFORE IT, in the same
# ==== back-to-back pair, and the pair itself is checked for drift first.
SubRx @'
     shot(look());                      // one warm draw, then the baseline
     var A=shot(look());
     if(!A) return 'drawing one pillager threw';
     // CONTROL FIRST: the same look twice must be identical, or every number
     // below is noise dressed as a finding.
     if(diff(A,shot(look()))!==0) bad.push('control: the same pillager drawn twice is not identical, so this instrument cannot measure a rack');
'@ @'
     shot(look());                      // one warm draw
     // EVERY MEASUREMENT IS A PAIR, drawn back to back, so nothing that drifts
     // over the length of this check can leak into a number. The pair is checked
     // for drift first and the amount is carried into every message.
     function pair(over){
       var b0=shot(look()), b1=shot(look(over));
       return diff(b0,b1);
     }
     var noise=pair(null);
     if(!(noise>=0)) return 'drawing one pillager threw';
     if(noise>40) bad.push('control: two draws of the same pillager differ by '+noise+' pixels, so this instrument cannot measure a rack');
'@
SubRx @'
     var prof=__P(), i;
     for(i=0;i<RACKS.length;i++){
       var R=RACKS[i], o={}; o[R.k]=R.v;
       var d=diff(A,shot(look(o)));
       if(d<R.floor) bad.push(R.name+' changes a pillager by '+d+' pixels, so a rack he rolled is not drawn on him');
'@ @'
     var prof=__P(), i;
     for(i=0;i<RACKS.length;i++){
       var R=RACKS[i], o={}; o[R.k]=R.v;
       var d=pair(o);
       if(d<R.floor) bad.push(R.name+' changes a pillager by '+d+' pixels against a noise floor of '+noise+', so a rack he rolled is not drawn on him');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
