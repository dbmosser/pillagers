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

if ($s.Contains("  {v:'32.31',what:")) { throw "check 32.31 is in the fixture already" }

SubRx @'
  {v:'32.30',what:
'@ @'
  {v:'32.31',what:'an easy run is cut 30 percent on the board and tagged easy (his 2.47 c)',
   run:function(){
     if(typeof arcadeBoardCut!=='function') return 'no arcadeBoardCut';
     if(arcadeBoardCut(1000,1)!==700||arcadeBoardCut(1000,0)!==1000) return 'cut is not 30 percent';
     if(arcadeBoardTag({e:1}).toLowerCase().indexOf('easy')<0||arcadeBoardTag({e:0})!=='') return 'tag wrong';
     if(String(arcadeBoardPut).indexOf('arcadeBoardCut')<0) return 'the board row is not cut';
     if(String(arcadeAttBoard).indexOf('arcadeBoardTag')<0) return 'the board does not show the tag';
     var d=arcadeBoardDedupe([{run:'q',s:5,x:0,k:0,t:1,e:1}]);
     if(!d[0]||d[0].e!==1) return 'dedupe drops the tag';
     var k0=localStorage.getItem(ARCADE_BOARD_KEY), l;
     try{
       localStorage.setItem(ARCADE_BOARD_KEY,JSON.stringify({v:1,rows:[{run:'zq',i:'AAA',s:70,x:1,k:1,t:Date.now(),m:2,e:1,u:'cr'}]}));
       l=arcadeBoardLoad();
       if(!l[0]||l[0].e!==1) return 'load drops the tag';
       return null;
     } finally { if(k0==null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,k0); } }},
  {v:'32.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
