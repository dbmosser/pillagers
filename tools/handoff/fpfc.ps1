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

if ($s.Contains("  {v:'30.67',what:")) { throw "check 30.67 is in the fixture already" }

SubRx @'
  {v:'30.66',what:
'@ @'
  {v:'30.67',what:'behind the title a pillager and a robot really fight: shots fly, hits land, the robot dies and the pillager goes down, drawn in the hub pass (his Q52/Q54)',
   run:function(){
     if(typeof tskInit!=='function'||typeof tskStep!=='function'||typeof tskDraw!=='function') return 'no title fight (no tskInit, tskStep, tskDraw)';
     if(String(drawHubWorld).indexOf('tskDraw')<0) return 'the hub pass never draws the title fight';
     var was=TSK, i, err=null;
     try{
       tskInit();
       for(i=0;i<1200;i++) tskStep(.05);
       var n=TSK.n;
       if(n.shots<40) return 'only '+n.shots+' shots in 60 s of fight';
       if(n.hits<15) return 'only '+n.hits+' hits in 60 s of fight';
       if(n.kills<1) return 'no robot died in 60 s of fight';
       if(TSK.fx.length>90||TSK.bolts.length>40) return 'the fight leaves too many bolts or sparks: '+TSK.fx.length+' '+TSK.bolts.length;
       if(wc){ wc.save(); try{ for(i=0;i<TSK.ents.length;i++) tskDraw(TSK.ents[i]); tskDraw({kind:'fx'}); }catch(e){ err=e; } finally{ wc.restore(); } if(err) return 'the fight does not draw: '+err; }
       return null;
     } finally { TSK=was; } }},
  {v:'30.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
