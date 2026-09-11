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

# v12.83 CHECK, inserted before the v12.82 entry.
#
# A GENERAL SWEEP WAS TRIED FIRST AND THROWN AWAY, and why is written into the
# design entry. Swept over the whole page it kept finding quotations of his own
# notes and the keys of the text-replacement maps, which are lookups rather than
# lines anybody reads, and rewording those would falsify a record. Skipping
# object keys and apostrophes inside words removed most of the noise and not all.
#
# So this asserts the seven surfaces that were actually wrong, by name, and the
# control on every one of them is that the line still says the thing it is for,
# so a line cannot pass this by being deleted. Every needle is assembled, so this
# row can never find itself.
SubRx @'
  {v:'12.82',what:'committing the kit twice does not wipe what was kept aside: the items, the tactical belt plan and the gun slot all survive a second commit, so taking the freebie kit at the stash and then going up no longer destroys the death restore, while a commit with nothing kept aside still takes what is in the kit (his v6.88 spec, found again 2026-09-09)',
'@ @'
  {v:'12.83',what:'the seven lines he reads that used a retired word use his word instead: the shop line says Credits, the two seal lines say stage, and the three pack lines and the Peddler blurb say backpack, while every one of those lines still says the thing it is for (found by tools/lint.ps1, 2026-09-09)',
   run:function(){
     var bad=[];
     try{
       var SRC='', sc=document.getElementsByTagName('script'), i;
       for(i=0;i<sc.length;i++) SRC+=(sc[i].textContent||'');
       if(!SRC) return 'SKIP: this fixture has no script text to read';
       var CASH='c'+'ash', TIER='ti'+'er', BAG='b'+'ag';
       // Each row: the wording that must be gone, and a fragment of the same
       // line that must still be there, so nothing passes by being deleted.
       var rows=[
         ['pays '+CASH+' only',             'pays Credits only'],
         ['seconds of cutting done ('+TIER, 'seconds of cutting done (stage'],
         ['reseals harder: '+TIER,          'reseals harder: stage'],
         ['heavy '+BAG+' to be standing',   'heavy backpack to be standing'],
         ['light '+BAG+' brings the',       'light backpack brings the'],
         ['weight of the '+BAG+'.',         'weight of the backpack.'],
         ['sell your '+BAG+' mid raid',     'sell your backpack mid raid']
       ];
       for(i=0;i<rows.length;i++){
         if(SRC.indexOf(rows[i][0])>=0)
           bad.push('a line he reads still says ['+rows[i][0]+'], which uses a word this game retired');
         if(SRC.indexOf(rows[i][1])<0)
           bad.push('control: the line that should read ['+rows[i][1]+'] is not there at all, so it was deleted rather than reworded');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.82',what:'committing the kit twice does not wipe what was kept aside: the items, the tactical belt plan and the gun slot all survive a second commit, so taking the freebie kit at the stash and then going up no longer destroys the death restore, while a commit with nothing kept aside still takes what is in the kit (his v6.88 spec, found again 2026-09-09)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
