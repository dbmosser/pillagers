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

if ($s.Contains("  {v:'34.44',what:")) { throw "check 34.44 is in the fixture already" }

SubRx @'
  {v:'34.43',what:
'@ @'
  {v:'34.44',what:'cw-downedcard3: the downed wash over the whole screen is at most 30 percent',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy and step';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillRect, bad=[], al=-1, g, p, i, md=mouse.down;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.hp=0; p.downed=true; p.downT=12.34; p.revived=0; p.iv=99; p.pendKiller=null; mouse.down=false;
       proto.fillRect=function(x,y,w,h){ if(this===ctx&&x===0&&y===0&&w>=W&&h>=H){ var m=/rgba\(\s*60,\s*8,\s*5,\s*([\d.]+)\)/.exec(String(this.fillStyle)); if(m) al=parseFloat(m[1]); } return o.apply(this,arguments); };
       for(i=0;i<3;i++) __loop(performance.now()+i*17);
       if(al<0) bad.push('no downed wash drawn');
       else if(al>0.301) bad.push('the downed wash is at '+al+', want 0.30 or less');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillRect=o; mouse.down=md; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
