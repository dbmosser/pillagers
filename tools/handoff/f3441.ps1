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

if ($s.Contains("  {v:'34.41',what:")) { throw "check 34.41 is in the fixture already" }

SubRx @'
  {v:'34.40',what:
'@ @'
  {v:'34.41',what:'cw-downedcard2: on the downed card the word down is the title size (26 px or more) and the self-revive key is drawn in the accent colour',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy and step';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, bad=[], seen=[], g, p, i, md=mouse.down;
     function px(c){ var m=/([\d.]+)px/.exec(c.font); return m?parseFloat(m[1])*c.getTransform().a:0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.hp=0; p.downed=true; p.downT=12.34; p.revived=0; p.iv=99; p.pendKiller=null; mouse.down=false;
       proto.fillText=function(t,x,y){ if(this===ctx&&typeof t==='string'&&t.length&&/\S/.test(t)) seen.push({t:String(t),px:px(this),fs:String(this.fillStyle).toLowerCase()}); return o.apply(this,arguments); };
       for(i=0;i<3;i++) __loop(performance.now()+i*17);
       var dn=null, key=null;
       for(i=0;i<seen.length;i++){ if(/^down$/i.test(seen[i].t)) dn=seen[i]; if(/^\[.{1,6}\]$/.test(seen[i].t)) key=seen[i]; }
       if(!dn) bad.push('no down label drawn');
       else if(dn.px<24) bad.push('the down label is '+dn.px.toFixed(1)+' px, want 24 or more');
       if(!key) bad.push('no self-revive key drawn on its own');
       else if(key.fs!=='#e6ff3d') bad.push('the self-revive key is '+key.fs+', want the accent #e6ff3d');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; mouse.down=md; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
