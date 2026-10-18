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

# End cards: lost items as tiles, a loss figure, contract chips (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocach{ padding:8px 16px; font-size:16px; line-height:1.2; color:var(--tx-1); background:var(--ui-raised); border:1px solid var(--ui-line); border-left:3px solid var(--acc); border-radius:4px; }
'@ @'
  #root .ocach{ padding:8px 16px; font-size:16px; line-height:1.2; color:var(--tx-1); background:var(--ui-raised); border:1px solid var(--ui-line); border-left:3px solid var(--acc); border-radius:4px; }
  /* v28.xx (cw-endcard-lost), the critic on the Killed in action card (2 of 5): "no hero line", "five centred rows each repeat a red Lost and the name is coloured by rarity; the guide says rarity is a 3px bar", "two identical Bandage rows are not stacked", "the contract lines are long green sentences". A tile row (64px tiles, 3px rarity bar, x2 count), one 56px loss figure with a 16px label, and the contract lines as one chip each. */
  #root .ocloss{ margin:16px 0 24px; text-align:center; }
  #root .ocloss b{ display:block; font-family:var(--f-cond); font-size:56px; font-weight:700; line-height:1.05; letter-spacing:0; color:var(--tx-1); }
  #root .ocloss span{ display:block; margin-top:4px; font-size:16px; line-height:1.2; letter-spacing:.04em; color:var(--tx-2); }
  #root .octiles{ display:flex; flex-wrap:wrap; gap:8px; justify-content:center; margin:16px 0 8px; }
  #root .octile{ position:relative; display:flex; align-items:center; justify-content:center; width:64px; height:64px; box-sizing:border-box; background:var(--ui-raised); border:1px solid var(--ui-line); border-bottom:3px solid var(--ui-line-hi); border-radius:4px; }
  #root .octile img{ width:44px !important; height:44px !important; }
  #root .octile i{ position:absolute; right:2px; top:2px; padding:0 6px; font-style:normal; font-size:16px; line-height:20px; color:var(--tx-1); background:var(--ui-bg); border-radius:4px; }
  #root .ocach.ocok{ border-left-color:var(--ok); }
'@

SubRx @'
    if(ln.indexOf('>ACHIEVEMENT: ')>=0){
'@ @'
    if(lost.length&&!/LOST<\/span>$/.test(ln)) flushLost();
    if(/LOST<\/span>$/.test(ln)&&(m=/^(<img[^>]*>)? ?<span style="color:([^"]*)">([^<]*)<\/span><span style="color:var\(--rust\)">\s*LOST<\/span>$/.exec(ln))){
      for(k=0;k<lost.length;k++) if(lost[k].name===m[3]){ lost[k].n++; break; }
      if(k===lost.length) lost.push({img:m[1]||'',col:m[2],name:m[3],n:1});
      lostTxt+=ln; continue;
    }
    if(/^\d+ items? secured for \$[\d,]+$/.test(ln)){ out.push('<span class="ocsr">'+ln+'</span>'); continue; }
    if((m=/^(.* lost), \$([\d,]+) gone$/.exec(ln))){ out.push('<div class="ocloss"><b>\x24'+m[2]+'</b><span>'+m[1].charAt(0).toUpperCase()+m[1].slice(1)+'</span></div><span class="ocsr">'+ln+'</span>'); continue; }
    if((m=/^<span style="color:#7fc4a0">CONTRACT COMPLETE: (.*)\. Complete contract at mainframe\.<\/span>$/.exec(ln))){
      out.push('<div class="ocachs"><span class="ocach ocok">'+m[1].charAt(0).toUpperCase()+m[1].slice(1).toLowerCase()+'</span></div><span class="ocsr">'+ln+'</span>'); continue;
    }
    if(ln.indexOf('>ACHIEVEMENT: ')>=0){
'@

SubRx @'
  var out=[], i, k, ln, m, names=[], cells, h, chips;
'@ @'
  var out=[], i, k, ln, m, names=[], cells, h, chips, lost=[], lostTxt='';
  function flushLost(){
    var t='<div class="octiles">', q;
    for(q=0;q<lost.length;q++) t+='<span class="octile" title="'+lost[q].name+'" style="border-bottom-color:'+lost[q].col+'">'+lost[q].img+(lost[q].n>1?'<i>x'+lost[q].n+'</i>':'')+'</span>';
    out.push(t+'</div><span class="ocsr">'+lostTxt+'</span>'); lost=[]; lostTxt='';
  }
'@

SubRx @'
var VER='29.82';
'@ @'
var VER='29.83';
'@

$pat = "(?m)^  now:'v29\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.83: The death card shows lost items as tiles with one big loss figure. Check 29.83 fails on v29.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
