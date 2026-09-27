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

if ($s.Contains("  {v:'16.54',what:")) { throw "check 16.54 is in the fixture already" }

# Old card checks step aside once a later card replaced theirs; the newest card check carries the fifteen build rule.
$oldCard = "if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';"
$cnt = ([regex]::Matches($s, [regex]::Escape($oldCard))).Count
if ($cnt -lt 5) { throw "expected the old card checks, found $cnt" }
$s = $s.Replace($oldCard, $oldCard + "`n     if(this&&this.v&&vCard>parseFloat(this.v)+0.001) return 'SKIP: the card has moved on to v'+wn.ver+', a later card check covers it';")
$script:s = $s

SubRx @'
  {v:'16.53',what:
'@ @'
  {v:'16.54',what:'the what is new card is current again: within fifteen builds of the build, the co-op line still second, then the party features since v16.33 and the stability pass',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[];
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0;
     var vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';
     if(vCard>16.54+0.001) return 'SKIP: the card has moved on to v'+wn.ver+', a later card check covers it';
     if(vNow-vCard>0.15) bad.push('the card is at v'+wn.ver+' against a build at v'+wn.build+', more than fifteen builds behind');
     var a=String(L[2]||'').toUpperCase(), b=String(L[3]||'').toUpperCase();
     ['KIT AT THE LIFT','PING','MARKER','KILL FEED','KID MODE'].forEach(function(w){ if(a.indexOf(w)<0) bad.push('the party line does not say '+w.toLowerCase()); });
     ['SEARCH KEEPS RUNNING','PAUSE BOX SHUTS','SHUTS THE MAP','GREYED OUT'].forEach(function(w){ if(b.indexOf(w)<0) bad.push('the stability line does not say '+w.toLowerCase()); });
     if(String(L[1]||'').toUpperCase().indexOf('YOUR PARTY GOES UP TOGETHER')<0) bad.push('the co-op line is no longer second');
     if(L[0]&&String(L[0]).toUpperCase().indexOf('ALPHA')<0) bad.push('the card no longer opens with what an alpha is');
     return bad.length?bad.join('; '):null; }},
  {v:'16.53',what:
'@

# v16.48 made the kit wait send the party up only from the Undercroft floor; the kit check now stages the floor.
SubRx @'
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status}, oSend=netSend, oRef=netRefresh, sent=[], went=0, r, bad=[], mod=document.getElementById('askmodal');
'@ @'
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status}, oSend=netSend, oRef=netRefresh, sent=[], went=0, r, bad=[], mod=document.getElementById('askmodal'), kS16=state;
'@
SubRx @'
       NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}];
       r=netKitGate(function(){ went++; });
'@ @'
       NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}]; state='hub';
       r=netKitGate(function(){ went++; });
'@
SubRx @'
       netSend=oSend; netRefresh=oRef; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.kitWait=null;
'@ @'
       netSend=oSend; netRefresh=oRef; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.kitWait=null; state=kS16;
'@

# v16.46 moved the controller ping to a D-UP tap.
SubRx @'
     if(src.indexOf("if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();")<0) bad.push('a controller cannot ping');
'@ @'
     if(src.indexOf("else if(NET.on&&NET.upSeed) netPingMake();")<0) bad.push('a controller cannot ping');   // v16.46 moved it to a D-UP tap
'@

# v16.16 (plain game language) reworded the loaner line.
$oldNeedle = "var needle=['Equip','as','your','gun'].join(' ');"
$nn = ([regex]::Matches($script:s, [regex]::Escape($oldNeedle))).Count
if ($nn -lt 1) { throw "the loaner needle is gone" }
$script:s = $script:s.Replace($oldNeedle, "var needle=['Equip','your','own','gun'].join(' ');")

# The notoriety banner says Hires, his word, since the plain language pass.
SubRx @'
     if(b2.indexOf('Hiring')<0) bad.push
'@ @'
     if(!(/Hir(ing|es) cost/).test(b2)) bad.push
'@
SubRx @'
     if(b1.indexOf('Hiring')<0) bad.push
'@ @'
     if(!(/Hir(ing|es) cost/).test(b1)) bad.push
'@

# v16.45 put Settings in every pause box; his two choices are still the two others.
SubRx @'
       var floor=shownBtns();
'@ @'
       var floor=shownBtns();
       floor=floor.filter(function(b){ return !(/^settings$/i).test(b.txt); });   // v16.45 put Settings in every pause box
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus $cnt old card checks"
