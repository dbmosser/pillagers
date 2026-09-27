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

if ($s.Contains("  {v:'16.34',what:")) { throw "check 16.34 is in the fixture already" }

SubRx @'
  {v:'16.33',what:
'@ @'
  {v:'16.34',what:'player 2 CURRENT PILLAGERS board: the host sends its rows with the world word and a linked window keeps them, with names, values and who is out',
   run:function(){
     if(typeof netBoardTake!=='function'||typeof netBoardRows!=='function') return 'this build has no shared board';
     var keep=G, rows, n;
     try{
       G={t:5,timeLeft:100,raidLen:540,roster:[],ents:[]};
       n=netBoardTake([['Kite',420,'LOOTING',1,0,0,0,0],['Van',90,'EXTRACTED',0,1,1,0,0],['Moss',0,'DEAD',2,0,0,1,0]]);
       rows=G.netBoard;
     } finally { G=keep; }
     if(n!==3||!rows||rows.length!==3) return 'three host rows became '+n;
     if(rows[0].name!=='Kite'||rows[0].val!==420||rows[0].st!=='LOOTING') return 'the first row reads '+JSON.stringify(rows[0]);
     if(!rows[1].out||rows[1].outAt===undefined||rows[1].name.indexOf('Van')<0) return 'the extracted row lost its stamp or name: '+JSON.stringify(rows[1]);
     if(rows[2].deadAt===undefined||!rows[2].el) return 'the dead row lost its stamp or elite mark: '+JSON.stringify(rows[2]);
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf('m.bd=netBoardRows();')<0) return 'the host does not send its board with the world word';
     if(src.indexOf('if(_nb) R=[];')<0) return 'the board does not draw the host rows on a linked window';
     return null; }},
  {v:'16.33',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
