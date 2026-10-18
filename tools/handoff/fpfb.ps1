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

if ($s.Contains("  {v:'29.33',what:")) { throw "check 29.33 is in the fixture already" }

SubRx @'
  {v:'29.32',what:
'@ @'
  {v:'29.33',what:'the run info panel is drawn at the label size (16 px class), not the 13 px micro size',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, hit=null, g, want;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       want=parseFloat((/([\d.]+)px/).exec(String(FS(TYPE.label)))[1]);
       proto.fillText=function(t,x,y){ if(/^run info$/i.test(String(t))){ var fm=(/([\d.]+)px/).exec(String(this.font)); hit=fm?parseFloat(fm[1]):0; } return o.apply(this,arguments); };
       __frame(0.001);
       if(hit===null) bad.push('the run info heading was not drawn');
       else if(Math.abs(hit-want)>0.6) bad.push('run info text is '+hit+' px, not the label size '+want);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
