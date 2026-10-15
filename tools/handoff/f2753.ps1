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

if ($s.Contains("  {v:'27.53',what:")) { throw "check 27.53 is in the fixture already" }

SubRx @'
  {v:'27.52',what:
'@ @'
  {v:'27.53',what:'his 2026-10-14 note (UI cleanup uic5): the pause box lists the keys of where you are: the Undercroft box has no raid keys (raid status, extraction, drop an item for a teammate), the DEMO box has no backpack, ENTER equip, Z drop or ping, and the raid box is unchanged',
   run:function(){
     if(typeof keysLegendHtml!=='function'||typeof arcadeCardRows!=='function') return 'SKIP: no pause legend or DEMO controls card in this build';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g=null, was=null, strip=function(h){ return String(h).replace(/<[^>]*>/g,' ').replace(/&nbsp;/g,' ').replace(/\s+/g,' ').toLowerCase(); };
     var RAIDWORD='raid sta'+'tus', DROPW='drop an item for a '+'teammate';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __showScreen('hub'); __hubEnter();
       var hub=strip(keysLegendHtml());
       if(hub.indexOf(RAIDWORD)>=0||hub.indexOf('extraction')>=0||hub.indexOf(DROPW)>=0) bad.push('the Undercroft pause box lists raid keys: '+hub.slice(0,160));
       if(hub.indexOf('walk')<0||hub.indexOf('backpack')<0) bad.push('the Undercroft pause box does not list walking and the backpack: '+hub.slice(0,160));
       __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       var raid=strip(keysLegendHtml());
       if(raid.indexOf(RAIDWORD)<0||raid.indexOf(DROPW)<0) bad.push('the raid pause box lost its raid keys: '+raid.slice(0,160));
       was=g.arcade; g.arcade=true;
       var arc=strip(keysLegendHtml());
       g.arcade=was;
       if(arc.indexOf('backpack')>=0||arc.indexOf(DROPW)>=0||arc.indexOf('equip from')>=0||arc.indexOf(RAIDWORD)>=0) bad.push('the DEMO pause box lists keys the DEMO does not have: '+arc.slice(0,160));
       if(arc.indexOf('reload')<0||arc.indexOf('switch gun')<0) bad.push('the DEMO pause box does not list its own controls: '+arc.slice(0,160));
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&was!==null) g.arcade=was; }catch(_a){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'27.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
