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

# v11.41 EXPOSURE HOOK: the contract board internals, so a check can drive the
# real top-up, claim and repair paths instead of a copy of them. Every name here
# exists in the source; the wrappers defer the call so a missing name would only
# fail when used, never kill the hooks after it.
SubRx @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
'@ @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
window.__contracts={
  srand:function(s){ return srand(s); },
  gen:function(){ return genContract(); },
  key:function(c){ return contractKey(c); },
  ensure:function(){ return ensureContracts(); },
  claimAt:function(i){ return claimContractAt(i); }
};
'@

# v11.41 CHECK, inserted before the v11.40 entry.
SubRx @'
  {v:'11.40',what:'a vented Pillbox holds its stun for the full lockout, the same span a vented sentry holds, not the half-length it drained to before',
'@ @'
  {v:'11.41',what:'claiming a finished contract refills the freed slot with a job that is NOT already on the board (the no-duplicate rule the board is topped up by), and the refill still happens with the board held at eight',
   run:function(){
     if(!(window.__contracts&&window.__P)) return 'SKIP: this fixture does not expose the contract board';
     var C=window.__contracts, P=window.__P();
     var trials=0, dups=0, refilled=0, shortBoard=0, ex=null;
     for(var seed=1; seed<=200; seed++){
       C.srand(seed);
       P.contracts=[];
       C.ensure();                        // top up to eight with the dedup rule
       if(P.contracts.length!==8) continue;
       var f=P.contracts[0]; if(!f||typeof f.reward!=='number') continue;
       f.prog=f.n;                         // finish slot 0 so it can be claimed
       var r=C.claimAt(0);
       if(!r) continue;
       trials++;
       if(P.contracts[0]&&typeof P.contracts[0].reward==='number') refilled++;
       if(P.contracts.length!==8) shortBoard++;
       var nk=C.key(P.contracts[0]);
       for(var j=1;j<P.contracts.length;j++){
         if(C.key(P.contracts[j])===nk){ dups++; if(!ex) ex={seed:seed,key:nk}; break; }
       }
     }
     if(trials<50) return 'SKIP: only '+trials+' claimable boards, too few to measure';
     var bad=[];
     // THE FIX: not one claimed slot is refilled with a job already on the board.
     if(dups>0) bad.push('claiming a contract left a duplicate job on the board in '+dups+' of '+trials+' claims (e.g. seed '+ex.seed+', two slots are both '+ex.key+')');
     // CONTROL: the refill must STILL happen - the dedup did not leave the slot
     // empty or shrink the board.
     if(refilled<trials) bad.push('control: '+(trials-refilled)+' of '+trials+' claims left the freed slot empty, so the no-duplicate rule disarmed the refill');
     if(shortBoard>0) bad.push('control: the board fell below eight contracts after '+shortBoard+' of '+trials+' claims');
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.40',what:'a vented Pillbox holds its stun for the full lockout, the same span a vented sentry holds, not the half-length it drained to before',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
