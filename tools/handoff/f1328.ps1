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

# v13.28 CHECK, inserted before the v13.27 entry.
#
# IT STAGES THE SAVE THE LIST ACTUALLY READS. The tag comes from slotInfo, which
# reads the saved slot out of storage, not the live profile, so setting a run count
# in memory would change nothing. The check saves the count, redraws through
# titleRefresh, the refresh check 11.73 already uses, and reads the tag it drew.
#
# IT PUTS THE SAVE BACK. Every later check runs on this profile, so the run count is
# restored and saved again in finally.
SubRx @'
  {v:'13.27',what:'the title screen stops promising a new player a walkthrough that does not exist: it tells him to take the welcome pack only when the pack will be offered, and to walk to ENTER RAID either way',
'@ @'
  {v:'13.28',what:'the save you are on is tagged NEW until it has a raid and CONTINUING after, instead of telling a player on his first ever launch that he is continuing something',
   run:function(){
     if(typeof titleRefresh!=='function'||typeof saveProfile!=='function') return 'SKIP: this fixture cannot save and redraw the save list';
     var host=document.getElementById('slotlist'); if(!host) return 'SKIP: this build draws no save list';
     if(typeof SLOT==='undefined') return 'SKIP: this fixture cannot tell which save is current';
     var bad=[], keepRuns=P.runs;
     function tag(){
       try{ titleRefresh(); }catch(_t){}
       var row=host.querySelector('[data-slot="'+SLOT+'"]');
       if(!row) return null;
       var sp=row.querySelector('b span');
       return sp?String(sp.textContent||'').trim():'';
     }
     try{
       // ONE: the current save has never been raided.
       P.runs=0; saveProfile();
       var a=tag();
       if(a===null) return 'SKIP: the save list drew no row for the current save';
       if(a==='CONTINUING')
         bad.push('a save with no raids on it is tagged CONTINUING, right beside the line that says 0 raids, so a player on his first ever launch is told he is continuing something');
       else if(a!=='NEW')
         bad.push('a save with no raids is tagged ['+a+'] rather than NEW');

       // TWO: the current save has a raid.
       P.runs=1; saveProfile();
       var b=tag();
       if(b!=='CONTINUING')
         bad.push('a save that has been played is tagged ['+String(b)+'] rather than CONTINUING, so the fix took the tag away from the case it was right for');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P.runs=keepRuns; saveProfile(); titleRefresh(); }catch(_r){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.27',what:'the title screen stops promising a new player a walkthrough that does not exist: it tells him to take the welcome pack only when the pack will be offered, and to walk to ENTER RAID either way',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
