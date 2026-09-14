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

SubRx @'
  {v:'14.64',what:
'@ @'
  {v:'14.65',what:'the loadout question counts what MY LOADOUT will take up: with the freebie kit taken over three packed items, the question names the three items packed, as it names one packed item without the freebie kit (ascent audit finding 1)',
   run:function(){
     if(typeof askKit!=='function') return 'SKIP: no loadout question in this build';
     var ss=document.getElementById('asksub');
     if(!ss) return 'SKIP: no question text element in this document';
     var bad=[], prof;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       // CONTROL: no freebie kit, one Medkit packed from the stash.
       prof.freeKit=0; prof.kitSaved=null; prof.stash=['medkit','medkit','frag']; prof.kit=['medkit']; prof.hotAssign={};
       askKit();
       if(String(ss.textContent).indexOf('1 item you packed')<0) return 'SKIP: with one item packed the question did not name it ("'+String(ss.textContent).slice(0,80)+'")';
       __topClear();
       // THE FIX: the freebie kit was taken at the stash, and the three packed items were set aside.
       prof.freeKit=1; prof.kitSaved={kit:['medkit','medkit','frag'],hot:{}}; prof.kit=[];
       askKit();
       if(String(ss.textContent).indexOf('3 items you packed')<0) bad.push('with the freebie kit taken over three packed items, the question said "'+String(ss.textContent).slice(0,90)+'", while MY LOADOUT restores and takes all three');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof){ prof.freeKit=0; prof.kitSaved=null; prof.kit=[]; } }catch(_p){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
