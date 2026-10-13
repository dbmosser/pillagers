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

if ($s.Contains("  {v:'26.00',what:")) { throw "check 26.00 is in the fixture already" }

SubRx @'
  {v:'25.99',what:
'@ @'
  {v:'26.00',what:'his order (redo the bar at the bottom), the words: the controls list (F1) says 1-4 guns, 5-6 throwables, 7-8 medical, 9 armour and U switches which grenade G throws and H taps a heal and holds a plate, the compact list keeps an even number of entries with 1-4 guns beside B / I and 5-9 throw, heal, plate, the rules card says the four groups, and the pause screen key line says them and no longer says 1-9 tactical belt',
   run:function(){
     if(typeof LEGEND==='undefined'||typeof LEGEND_MINI==='undefined') return 'SKIP: no controls list here';
     var bad=[], gear=null, i, j, rows, want={'1-4':'guns','5-6':'throwables','7-8':'medical','9':'armour plate'}, k, found, ix=-1, kh=null, html='', page='', ru=[];
     for(i=0;i<LEGEND.length;i++) if(LEGEND[i][0]==='GEAR') gear=LEGEND[i][1];
     if(!gear) return 'SKIP: no GEAR section in the controls list';
     for(k in want){ found=false; for(j=0;j<gear.length;j++) if(gear[j][0]===k&&gear[j][1]===want[k]) found=true; if(!found) bad.push('the controls list has no row '+k+' '+want[k]); }
     for(j=0;j<gear.length;j++){ if(gear[j][0]==='1-9') bad.push('the controls list still has a 1-9 row ('+gear[j][1]+')'); if(gear[j][0]==='H') kh=gear[j][1]; }
     if(!kh||!/heal/.test(kh)||!/plate/.test(kh)) bad.push('the H row says '+JSON.stringify(kh)+', not a tap heal and a hold plate');
     if(!gear.some(function(r){ return r[0]==='U'&&/grenade|throw/i.test(r[1]); })) bad.push('the controls list has no U row about which grenade G throws');
     rows=LEGEND_MINI;
     for(i=0;i<rows.length;i++) if(rows[i][0]==='1-4') ix=i;
     if(ix<0) bad.push('the compact list has no 1-4 guns row');
     else{
       if(rows[ix][1]!=='guns') bad.push('the compact 1-4 row says '+rows[ix][1]);
       if(ix%2!==0) bad.push('1-4 sits in the right hand column (entry '+ix+')');
       if(!rows[ix+1]||rows[ix+1][0]!=='B / I') bad.push('B / I does not follow 1-4 on the same row');
     }
     if(!rows.some(function(r){ return r[0]==='5-9'&&/throw/.test(r[1])&&/heal/.test(r[1])&&/plate/.test(r[1]); })) bad.push('the compact list has no 5-9 throw, heal, plate row');
     if(rows.some(function(r){ return r[0]==='1-9'; })) bad.push('the compact list still has a 1-9 row');
     if(rows.length%2!==0) bad.push('the compact list has an odd number of entries ('+rows.length+')');
     if(typeof keysLegendHtml==='function'){ html=String(keysLegendHtml()); }
     if(html){
       if(!/guns/.test(html)||!/throwables/.test(html)||!/medical/.test(html)||!/armour/.test(html)) bad.push('the pause key line does not say the four groups');
       if(/1-9<\/b> tactical belt/.test(html)||/1-9 tactical belt/.test(html)) bad.push('the pause key line still says 1-9 tactical belt');
     }
     page=(document.getElementById('pausekeys')||{}).innerHTML||'';
     if(page&&/1-9 tactical belt/.test(page)&&!/guns/.test(page)) bad.push('the pause screen as written still says 1-9 tactical belt');
     return bad.length?bad.join('; '):null; }},
  {v:'25.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
