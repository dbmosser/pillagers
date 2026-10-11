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

# OFFER AND RING LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){ it=ITEMS[gi.k]; s=(netSeatName(gi.from)||'Your teammate')+' offers you '+(it?it.name:gi.k)+'  \u00b7  ['+(padOn()?padB('Y'):keyLabel('KeyT','T'))+'] to take it  \u00b7  '+Math.ceil(t)+'s'; }
  else if(go&&(t=GIFT_T-((G.t||0)-go.t))>0){ it=ITEMS[go.k]; s='Offered '+(it?it.name:go.k)+' to '+(netSeatName(go.to)||'your teammate')+'  \u00b7  Waiting  \u00b7  '+Math.ceil(t)+'s'; }
'@ @'
  // v22.xx (tr8fixa), the review of raid text batch 8: THE OFFER LINE IS A CAPS CALLOUT. HIS ORDER (2026-10-09): a raid line is a short
  // caps headline, never a sentence. The offer read Kite offers you Bandage, [T] to take it, 12s, and his own offer Offered Bandage to
  // Kite, Waiting, 12s. It now reads KITE OFFERS BANDAGE, [T] TAKE, 12s and OFFER SENT, BANDAGE TO KITE, 12s. The one key (v22.64),
  // the seconds and the plate are as they were.
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){ it=ITEMS[gi.k]; s=String(netSeatName(gi.from)||'Your teammate').toUpperCase()+' OFFERS '+String(it?it.name:gi.k).toUpperCase()+'  \u00b7  ['+(padOn()?padB('Y'):keyLabel('KeyT','T'))+'] TAKE  \u00b7  '+Math.ceil(t)+'s'; }
  else if(go&&(t=GIFT_T-((G.t||0)-go.t))>0){ it=ITEMS[go.k]; s='OFFER SENT  \u00b7  '+String(it?it.name:go.k).toUpperCase()+' TO '+String(netSeatName(go.to)||'your teammate').toUpperCase()+'  \u00b7  '+Math.ceil(t)+'s'; }
'@

SubRx @'
        hudText(inbound+' converging on the ring',W/2,_exRow);
'@ @'
        hudText(inbound+(inbound===1?' HOSTILE':' HOSTILES')+' CLOSING IN',W/2,_exRow);   // v22.xx (tr8fixa): a caps callout under EXTRACT A INBOUND (INBOUND stays his word for the craft)
'@

SubRx @'
    hudText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'m',clamp(x,LH(70)*r,W-LH(70)*r),y-LH(18)*r); ctx.textAlign='left';
'@ @'
    hudText(String(nm).toUpperCase()+' WAYPOINT  '+((G&&G.player)?metres(dist(G.player,w)):0)+'m',clamp(x,LH(70)*r,W-LH(70)*r),y-LH(18)*r); ctx.textAlign='left';   // v22.xx (tr8fixa): his word is Waypoint (Marked Waypoint), never Marker
'@

SubRx @'
var VER='22.98';
'@ @'
var VER='22.99';
'@

$pat = "(?m)^  now:'v22\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.99: The offer line, the hostile count on a called ring and a teammate mark read as caps callouts, such as KITE OFFERS BANDAGE and 3 HOSTILES CLOSING IN. Check 22.99 fails on v22.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
