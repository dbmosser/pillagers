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

# v12.72 CHECK, inserted before the v12.71 entry. The fixture replaces the whole
# download function, so no check could ever see the name it wrote; that is why
# the build moves the name into a function of its own, and this asks that
# function rather than reading the page. Both needles are still assembled, not
# because this check could find itself, but because the retired name would then
# be written into the corpus and a later sweep for it would keep finding a copy
# that is only there to look for it.
SubRx @'
  {v:'12.71',what:'holding the sprint key while aiming, or while wading, lays no scent behind a man who is not sprinting, so nothing hunts him along a trail he never made; a plain sprint on dry land still lays one (2026-09-07 audit)',
'@ @'
  {v:'12.72',what:'the run report the game saves to his Downloads is named after the game he is playing and not after the retired project, and the run number still rides in the name so one report does not overwrite the last (2026-09-08 first-hour audit)',
   run:function(){
     if(typeof reportFileName!=='function') return 'SKIP: this build writes the report name where it is used, and the fixture replaces the whole download, so the name cannot be read here';
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     var bad=[], P2=__P(), keep=P2.runs;
     try{
       var GONE='dark'+'_rai'+'ders', HERE='pill'+'agers';
       P2.runs=7;
       var nm=String(reportFileName()||'').toLowerCase();
       if(!nm) return 'SKIP: the naming function returned nothing';
       if(nm.indexOf(GONE)>=0)
         bad.push('the file the game drops into his Downloads is called ['+nm+'], which carries the retired project name: it is the one place the rename was missed and the only one that leaves the browser, so a friend opening the alpha finds a file named for a game he has never heard of, and it is the same file he is asked to send back');
       if(nm.indexOf(HERE)<0)
         bad.push('the report file name ['+nm+'] does not carry the name of this game at all');
       // CONTROL: the run number has to stay in the name, or every report
       // written would land on top of the one before it.
       if(nm.indexOf('7')<0)
         bad.push('control: the run number is not in the name ['+nm+'], so each report would overwrite the last one in his Downloads');
       P2.runs=8;
       if(String(reportFileName()||'').indexOf('8')<0)
         bad.push('control: the name does not follow the run count, so it is a fixed string rather than a name per run');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.runs=keep; saveProfile(); }catch(_p){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.71',what:'holding the sprint key while aiming, or while wading, lays no scent behind a man who is not sprinting, so nothing hunts him along a trail he never made; a plain sprint on dry land still lays one (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
