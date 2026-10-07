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

if ($s.Contains("  {v:'18.52',what:")) { throw "check 18.52 is in the fixture already" }

SubRx @'
  {v:'18.51',what:
'@ @'
  {v:'18.52',what:'an unplugged controller pauses only the window that played it: with no pick, the other player pad coming out leaves this raid running, a keyboard window in a pair ignores it, and this window own pad still pauses',
   run:function(){
     if(typeof pollPad!=='function'||typeof netPadTick!=='function') return 'SKIP: no pad pairing here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keep={same:NET.same,padIx:NET.padIx}, oT=netPadTick, oPix=PAD.ix, fake={connected:true,index:0,id:'test pad',mapping:'standard',timestamp:0,axes:[0,0,0,0],buttons:[]}, i;
     function unplug(ix){ var ev=new Event('gamepaddisconnected'); Object.defineProperty(ev,'gamepad',{value:{index:ix}}); window.dispatchEvent(ev); }
     for(i=0;i<17;i++) fake.buttons.push({pressed:false,value:0});
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(pauseOpen) togglePauseBox(false);
       NET.same='host'; NET.padIx=-1; netPadTick=function(){ return fake; };
       pollPad();
       unplug(1);
       if(pauseOpen){ bad.push('the other player pad coming out paused this window (no pick)'); togglePauseBox(false); }
       delete PAD.ix; unplug(0);
       if(pauseOpen){ bad.push('a keyboard window in a pair paused for a pad it never played'); togglePauseBox(false); }
       pollPad(); unplug(0);
       if(!pauseOpen) bad.push('control: this window own pad coming out did not pause it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netPadTick=oT; NET.same=keep.same; NET.padIx=keep.padIx; if(oPix===undefined) delete PAD.ix; else PAD.ix=oPix; try{ padRelease(); PAD.on=false; }catch(_p){} try{ if(pauseOpen) togglePauseBox(false); }catch(_q){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
