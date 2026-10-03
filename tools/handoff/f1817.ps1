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

if ($s.Contains("  {v:'18.17',what:")) { throw "check 18.17 is in the fixture already" }

SubRx @'
  {v:'18.16',what:
'@ @'
  {v:'18.17',what:'trading is on the legends, his note of 2026-10-03: the full key list and the full pad list have a TEAM section with the trade key, the compact legend gains a trade row while a party is on and grows for it, the stash key bar has an offer line, and the Party window explains trading',
   run:function(){
     var bad=[], i, j, tRow=null, yRow=null, kb=document.getElementById('kb_trade'), pt=document.getElementById('partytrade'), g, on0, h0=0, h1=0, lines=[], src='';
     if(typeof LEGEND==='undefined'||typeof LEGEND_PAD==='undefined') return 'SKIP: no key tables';
     for(i=0;i<LEGEND.length;i++) if(LEGEND[i][0]==='TEAM') for(j=0;j<LEGEND[i][1].length;j++) if(LEGEND[i][1][j][0]==='T') tRow=LEGEND[i][1][j];
     for(i=0;i<LEGEND_PAD.length;i++) if(LEGEND_PAD[i][0]==='TEAM') for(j=0;j<LEGEND_PAD[i][1].length;j++) if(LEGEND_PAD[i][1][j][0]==='Y') yRow=LEGEND_PAD[i][1][j];
     if(!tRow||!/trad|offer/.test(String(tRow[1]))) return 'the key list has no TEAM section with a T row for trading';
     if(!yRow||!/trad|offer/.test(String(yRow[1]))) bad.push('the pad list has no TEAM section with a Y row for trading');
     if(!kb) bad.push('the stash key bar has no offer line');
     if(!pt||!/Offer/.test(pt.textContent)) bad.push('the Party window does not explain trading');
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__textTrace)) return bad.length?bad.join('; '):null;
     on0=NET.on;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.legendOn=1;
       NET.on=false; __frame(0.016); h0=HUDBOX.legend?HUDBOX.legend.h:0;
       NET.on=true; lines=__textTrace(function(){ __frame(0.016); }); h1=HUDBOX.legend?HUDBOX.legend.h:0;
       NET.on=on0;
       if(!lines.some(function(l){ return /trade/.test(String(l.t||l)); })) bad.push('with a party on the compact legend draws no trade row');
       if(!(h1>h0+4)) bad.push('the compact legend did not grow for the trade row ('+Math.round(h0)+' to '+Math.round(h1)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NET.on=on0; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
