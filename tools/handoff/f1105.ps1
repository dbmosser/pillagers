$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ==== v11.00 ASSERTED THAT BLACKOUT IS ALWAYS HARD, and his question showed it
# ==== is not: in daylight at 8am and noon the lamps it kills are already off.
# ==== The assertion is split by what the weather actually does, which is what it
# ==== should have been in the first place.
SubRx @'
         var HARD=['rain','fog','blackout','storm'], EASY=['clear','partly'];
         for(i=0;i<HARD.length;i++) if(!wxHardId(HARD[i])) bad.push(HARD[i]+' does not count as hard going and it cuts your sight or your lamps');
         for(i=0;i<EASY.length;i++) if(wxHardId(EASY[i])) bad.push('control: '+EASY[i]+' counts as hard going, so every weather pays and the bonus means nothing');
'@ @'
         // CUTTING SIGHT is the weather itself and is true whatever the hour.
         var HARD=['rain','fog','storm'], EASY=['clear','partly'];
         for(i=0;i<HARD.length;i++) if(!wxHardId(HARD[i])) bad.push(HARD[i]+' does not count as hard going and it cuts your sight');
         for(i=0;i<EASY.length;i++) if(wxHardId(EASY[i])) bad.push('control: '+EASY[i]+' counts as hard going, so every weather pays and the bonus means nothing');
         // v11.05, HIS QUESTION: KILLING THE LAMPS only counts when the lamps
         // were on. At night they are the light; at 8am and noon the time of day
         // already has them at zero and a blackout multiplies nothing.
         if(typeof lampBase!=='function') bad.push('nothing asks how much lamp light there was before the weather, so a blackout pays whatever the hour');
         else {
           var NIGHT=false, DAYNOON={lights:0}, DAYDUSK={lights:1};
           if(!wxHardId('blackout',NIGHT)) bad.push('a blackout at night does not count as hard going, and at night the lamps are the light');
           if(wxHardId('blackout',true,DAYNOON)) bad.push('a blackout at noon counts as hard going, and at noon the lamps are already off, which is his question');
           if(!wxHardId('blackout',true,DAYDUSK)) bad.push('a blackout at dusk does not count as hard going, and at dusk the lamps are at full');
           // CONTROL: the times of day this rests on have to be what I think they
           // are, asked of the table rather than remembered.
           if(typeof TODS!=='undefined'){
             var noonL=null, duskL=null, q;
             for(q=0;q<TODS.length;q++){ if(TODS[q].id==='noon') noonL=TODS[q].lights; if(TODS[q].id==='dusk') duskL=TODS[q].lights; }
             if(noonL!==0) bad.push('control: noon carries '+noonL+' lamp light and this rule assumes zero');
             if(!(duskL>=0.9)) bad.push('control: dusk carries '+duskL+' lamp light and this rule assumes full');
           }
         }
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
