$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Small in-place repairs to drafted f files from the 2026-09-06 read-only
# review (workflow wf_27344e1d-0ec). Literal here-strings, so no escaping.
# Idempotent: a step whose new text is already present is skipped.
$enc = New-Object Text.UTF8Encoding $false
function Rep([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($file + ': already repaired'); return }
  $c = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = $s.Replace($old, $new)
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}

# f1181: the raid bag is G.bag, not G.player.bag (two places).
Rep 'f1181.ps1' 'g.seal={gained:40,done:0}; g.player.bag=[];' 'g.seal={gained:40,done:0}; g.bag=[];' 2

# f1184: one Lance round is 96; a second hit must fail, so the bound is 150.
Rep 'f1184.ps1' "if(l1>200||l2>200) bad.push('a crawler was hit more than once by one round" "if(l1>150||l2>150) bad.push('a crawler was hit more than once by one round" 1

# f1185: the floors are the role sizes the fixture already exposes, so the
# countdown half can fail on the old build at the pane's real scale (micro
# renders 15.6 at 1080p, above my hard 15).
Rep 'f1185.ps1' @'
       var smallN=names.filter(function(r){ return px(r.font)<18; }), smallS=subs.filter(function(r){ return px(r.font)<15; });
'@ @'
       var _hp=(window.__type&&__type.px('head'))||18, _lp=(window.__type&&__type.px('label'))||15;
       var smallN=names.filter(function(r){ return px(r.font)<_hp-0.5; }), smallS=subs.filter(function(r){ return px(r.font)<_lp-0.5; });
'@ 1
Rep 'f1185.ps1' @'
if(smallN.length) bad.push(smallN.length+' extraction name(s) drawn at '+px(smallN[0].font)+'px, under 18');
'@ @'
if(smallN.length) bad.push(smallN.length+' extraction name(s) drawn at '+px(smallN[0].font)+'px, under the callout face at '+_hp+'px');
'@ 1
Rep 'f1185.ps1' @'
if(smallS.length) bad.push(smallS.length+' countdown line(s) drawn at '+px(smallS[0].font)+'px, under 15 ("'+smallS[0].t+'")');
'@ @'
if(smallS.length) bad.push(smallS.length+' countdown line(s) drawn at '+px(smallS[0].font)+'px, under the label face at '+_lp+'px ("'+smallS[0].t+'")');
'@ 1
# The what-line: once in f1185, twice in f1186 (its anchor and its trailing copy).
$oldWhat = "what:'the map names each extraction at 18px or more and counts down to its close at 15px or more, one row each above the ring, instead of both in the smallest face the game has (his note of 2026-09-06)'"
$newWhat = "what:'the map names each extraction in the callout face and counts down to its close in the label face, one row each above the ring, instead of both in the smallest face the game has (his note of 2026-09-06)'"
Rep 'f1185.ps1' $oldWhat $newWhat 1
Rep 'f1186.ps1' $oldWhat $newWhat 2

# f1192: the loader replaces the profile; snapshot and restore, as 11.77 does.
Rep 'f1192.ps1' @'
     var bad=[];
     try{
       __topClear(); __cleanProfile();
       var P=__P(); P.safe=null;
'@ @'
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.stringify(__P());   // the loader below replaces the profile; it is put back at the end
       var P=__P(); P.safe=null;
'@ 1
Rep 'f1192.ps1' @'
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.91'
'@ @'
     finally{ try{ if(snap) __applyLoaded(JSON.parse(snap)); }catch(_rs){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.91'
'@ 1
