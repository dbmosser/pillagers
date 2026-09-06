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

# v11.81 CHECK, inserted before the v11.80 entry. Two raids: one death with a
# cut in hand, whose card must not mention the loss; one extraction with the
# same cut, whose card must still bank it, so the seal path is proven live.
SubRx @'
  {v:'11.80',what:'when the extraction hold ends the raid from inside the player update, the rest of that frame drives the ambient bed to silence instead of back up to its floor, so nothing hums on the Undercroft floor afterwards (his note of 2026-09-06)',
'@ @'
  {v:'11.81',what:'the KILLED IN ACTION card no longer says how many seconds of cutting were lost with you, and an extraction still banks the cut (his order of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot end a raid and read the card';
     if(typeof sealHere!=='function') return 'SKIP: no seal in this build';
     var bad=[], lost='seconds of '+'cutting, lost', banked='Seal '+'cut ';
     function card(){ try{ return ((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(e){ return ''; } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.seal={gained:40,done:0}; g.bag=[];
       __endRaid('dead');
       var t1=card();
       if(t1.indexOf('KILLED')<0) bad.push('control: the death card did not come up (card says: '+t1.slice(0,60)+')');
       if(t1.indexOf(lost)>=0) bad.push('the death card still says the cutting was '+lost.slice(-4)+' with you');
       __topClear(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.seal={gained:40,done:0}; g.bag=[];
       __endRaid('extract');
       var t2=card();
       if(t2.indexOf(banked)<0) bad.push('control: an extraction with 40 seconds of cutting did not print the banked line, so the seal path was not live in this staging (card says: '+t2.slice(0,80)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.80',what:'when the extraction hold ends the raid from inside the player update, the rest of that frame drives the ambient bed to silence instead of back up to its floor, so nothing hums on the Undercroft floor afterwards (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
