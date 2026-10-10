$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# EXTRACTION MOMENTS IN THE ALERT LANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
lg.push({m:m,k:k,t:G.t||0});
'@ @'
lg.push({m:m,k:k,t:G.t||0,sub:(o&&o.sub)||''});
'@

SubRx @'
say('Knocked down. Extraction progress bar reset. Hold E to try again.');
'@ @'
say('Knocked down. Extraction progress bar reset. Hold E to try again.','ext',{c:'warn',key:'xcall'});
'@

SubRx @'
      var _why=(_g>=0.66)?' Heavy backpack: they heard that.'
              :((_g>=0.33)?' Your backpack is heavy. Expect company.'
                          :' Light backpack. Fewer will come.');
'@ @'
      var _wh=(_g>=0.66)?'HEAVY BACKPACK':((_g>=0.33)?'LOADED BACKPACK':'LIGHT BACKPACK'),
          _wd=(_g>=0.66)?'They heard that.':((_g>=0.33)?'Expect company.':'Fewer will come.');
'@

SubRx @'
      say('Pulled. Inbound '+fmtMS(CFG.extractWait)+
          ((raidClockOn()&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':', then hold E to extract.')+   // v12.24: not with the clock OFF
          ' THE SIEGE: about '+_sc+' machines are coming to this ring.'+_why);
'@ @'
      // v22.38, the raid text rewrite (R13): EXTRACTION MOMENTS IN THE ALERT LANE. His order of 2026-10-09 is a shooter HUD; the call
      // was one line of about 130 characters (Pulled, the wait, how to extract, THE SIEGE and its size, and the backpack), so most of
      // it ran past the plate or was pushed down. It is now EXTRACTION CALLED (the wait as m:ss, then the key that extracts, or that
      // the raid clock runs out first), then THE SIEGE with how many are coming, then a feed row for the backpack. The band under the
      // clock owns every live countdown, so only the one inbound figure is in a detail. The count is the same _sc as before.
      var _xw=Math.round(CFG.extractWait), _xs=(_xw>=60)?(Math.floor(_xw/60)+':'+((_xw%60)<10?'0':'')+(_xw%60)):(_xw+'s'), _xk='['+keyLabel('KeyE','E')+']';
      say('EXTRACTION CALLED','ext',{key:'xcall',sub:'Inbound '+_xs+((raidClockOn()&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':('. Then hold '+_xk+' to extract.'))});   // v12.24: not with the clock OFF
      say('THE SIEGE','warn',{key:'siege',sub:'About '+_sc+(_sc===1?' machine is':' machines are')+' coming to this ring.'});
      say(_wh,'info',{sub:_wd});
'@

SubRx @'
say('EXTRACTION IS OPEN. Hold E to extract, '+Math.round(z.hold)+'s.'); }
'@ @'
say('EXTRACT IN PROGRESS!','ext',{key:'xcall',sub:'Hold ['+keyLabel('KeyE','E')+'] to extract.'}); }   // v22.38 (R13): his phrase; the band shows the seconds
'@

SubRx @'
        say('Extraction left without you.'+((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?' Another call cannot beat the raid clock.':(' Hold E to call for another, '+fmtMS(CFG.extractWait)+' out.')))); }
'@ @'
        say('EXTRACTION LEFT WITHOUT YOU','ext',{c:'warn',key:'xcall',sub:((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?'Another call cannot beat the raid clock.':('Hold ['+keyLabel('KeyE','E')+'] in a ring to call for extraction.')))}); }   // v22.38 (R13)
'@

SubRx @'
sayWhenFree('Extraction '+extLetter(cz)+' closes in two minutes.','ext');
'@ @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSING','ext',{c:'warn',sub:'It closes in two minutes.'});   // v22.38 (R13)
'@

SubRx @'
sayWhenFree('Extraction '+extLetter(cz)+' is closed.','ext');
'@ @'
sayWhenFree('EXTRACTION '+extLetter(cz)+' CLOSED','ext',{c:'warn'});   // v22.38 (R13)
'@

SubRx @'
say((netSeatName(peer.seat)||'Your teammate')+' called extraction. Inbound in '+Math.ceil(Z.beaconT)+'s.');
'@ @'
say('EXTRACTION CALLED','ext',{key:'xcall',sub:(netSeatName(peer.seat)||'Your teammate')+' called for extraction at '+extLetter(Z)+'.'});   // v22.38 (R13)
'@

SubRx @'
var VER='22.37';
'@ @'
var VER='22.38';
'@

$pat = "(?m)^  now:'v22\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.38: Calling for extraction shows EXTRACTION CALLED, then THE SIEGE with its size, then a short backpack row, instead of one 130 character line. Check 22.38 fails on v22.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
