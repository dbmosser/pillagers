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

# v13.27 CHECK, inserted before the v13.26 entry.
#
# THE SAME REFRESH CHECK 11.73 USES, titleRefresh, so the line under test is the
# line the game draws and not a string assembled here.
#
# TWO NEW PLAYERS, because the sentence now depends on whether the pack will be
# offered: one who qualifies for it, and one who has already been welcomed. The
# profile fields that decide it are saved first and put back in finally, because
# every later check runs on this profile.
SubRx @'
  {v:'13.26',what:'the map screen shows every player the sector line he rewrote: the test robot extract rate in that map, without first contact, containers or median haul, whether or not that player has raided there (his baked edits matched only his own run counts)',
'@ @'
  {v:'13.27',what:'the title screen stops promising a new player a walkthrough that does not exist: it tells him to take the welcome pack only when the pack will be offered, and to walk to ENTER RAID either way',
   run:function(){
     if(typeof titleRefresh!=='function') return 'SKIP: this fixture cannot redraw the title line';
     var sub=document.getElementById('titlesub'); if(!sub) return 'SKIP: this build draws no line under the title';
     var bad=[];
     var keep={runs:P.runs,welcomed:P.welcomed,stash:(P.stash||[]).slice(),weapons:(P.weapons||[]).slice()};
     function line(){ try{ titleRefresh(); }catch(_t){} return String(sub.textContent||''); }
     try{
       // ONE: a brand-new player the game will offer the pack to.
       P.runs=0; P.welcomed=0; P.stash=[]; P.weapons=['pistol'];
       var a=line();
       if(!a) return 'SKIP: the title line drew nothing for a player with no raids';
       if(/walk you through/i.test(a))
         bad.push('a brand-new player is promised that the Undercroft will walk him through it, and nothing in the game does: the first sentence he reads is a promise no screen keeps');
       if(a.indexOf('welcome pack')<0)
         bad.push('a new player who is about to be offered the welcome pack is not told to take it: ['+a+']');
       if(a.indexOf('ENTER RAID')<0)
         bad.push('a new player is not told where to go to start: ['+a+']');

       // TWO: a player with no raids who has already been welcomed.
       P.runs=0; P.welcomed=1; P.stash=[]; P.weapons=['pistol'];
       var b=line();
       if(b.indexOf('welcome pack')>=0)
         bad.push('a player who will never be offered the welcome pack is told to take it, so he goes looking for a pack that does not appear: ['+b+']');
       if(b.indexOf('ENTER RAID')<0)
         bad.push('a player with no raids who has already been welcomed is not told where to go: ['+b+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P.runs=keep.runs; P.welcomed=keep.welcomed; P.stash=keep.stash; P.weapons=keep.weapons; titleRefresh(); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.26',what:'the map screen shows every player the sector line he rewrote: the test robot extract rate in that map, without first contact, containers or median haul, whether or not that player has raided there (his baked edits matched only his own run counts)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
