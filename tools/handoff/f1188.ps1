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

# v11.88 CHECK, inserted before the v11.87 entry. The profile is given the
# two contracts he complained about plus a no-heals one as the control, a raid
# is deployed and a frame drawn with the canvas text call recorded.
SubRx @'
  {v:'11.87',what:'a helped survivor walks to the nearest open extraction on his own instead of following you, and leaves when he reaches the ring (his note of 2026-09-06)',
'@ @'
  {v:'11.88',what:'the raid conditions panel no longer prints the kill-nothing and three-minute contract verdicts, and still prints the no-heals one (his order of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], P2=__P(), keepC=P2.contracts, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __forceSize(1920,1080);
       P2.contracts=[
         {type:'conduct',ck:'quiet',n:1,prog:0,reward:1300,desc:'Extract without killing anything',tier:0},
         {type:'conduct',ck:'swift',n:1,prog:0,reward:1000,desc:'Extract within 3 minutes of landing',tier:0},
         {type:'conduct',ck:'clean',n:1,prog:0,reward:900,desc:'Extract without using a single heal',tier:0}];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __frame(0.016);
       proto.fillText=function(t,x,y){ rec.push(String(t)); return o.apply(this,arguments); };
       __frame(0.016);
       proto.fillText=o;
       var all=rec.join(' | ');
       if(all.indexOf('CONDITIONS')<0) return 'SKIP: the conditions panel is not drawn here';
       if(all.indexOf('no heals yet')<0) bad.push('control: the no-heals contract verdict is not on the panel');
       if(all.indexOf('killed yet')>=0||all.indexOf('killed')>=0&&all.indexOf('BROKEN, ')>=0&&/BROKEN, \d+ killed/.test(all)) bad.push('the panel still prints the kill-nothing verdict');
       if(all.indexOf('left to be gone')>=0||all.indexOf('past three minutes')>=0) bad.push('the panel still prints the three-minute verdict');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       proto.fillText=o; P2.contracts=keepC; try{ saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.87',what:'a helped survivor walks to the nearest open extraction on his own instead of following you, and leaves when he reaches the ring (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
