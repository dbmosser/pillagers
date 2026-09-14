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

SubRx @'
  {v:'13.57',what:
'@ @'
  {v:'13.58',what:'equipping a spare copy of the gun already in gun 2 from the stash puts it in gun 1 and empties gun 2, so one gun is never in both hands, while equipping a spare of a third gun leaves gun 2 as it was (Undercroft audit 2026-09-14, finding 3)',
   run:function(){
     if(!window.__P||typeof itemMenuRows!=='function') return 'SKIP: no stash item menu in this build';
     var guns=[], k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&it.gk!=='fists') guns.push(k); }
     if(guns.length<2) return 'SKIP: fewer than two gun items to stage';
     var P2=__P(), keep={w:(P2.weapons||[]).slice(),e:P2.equipped,e2:P2.equippedSec,st:(P2.stash||[]).slice()};
     var bad=[];
     function equipRow(key){
       var rows=itemMenuRows(key,'stash',1), r=null;
       for(var i=0;i<rows.length;i++) if(/as your gun/i.test(String(rows[i].label||''))) r=rows[i];
       return r;
     }
     try{
       __topClear(); __cleanProfile();
       var A=ITEMS[guns[0]].gk, B=ITEMS[guns[1]].gk;
       P2.weapons=[A,B]; P2.equipped=A; P2.equippedSec=B; P2.stash=[guns[1]];
       var row=equipRow(guns[1]);
       if(!row||typeof row.act!=='function') return 'SKIP: the stash menu for a spare gun has no Equip as your gun row';
       try{ row.act(); }catch(_a){}
       if(P2.equipped!==B) bad.push('staging: Equip as your gun did not put the spare gun in gun 1 (gun 1 is '+P2.equipped+')');
       else if(P2.equippedSec===B) bad.push('equipping a spare copy of the gun in gun 2 left gun 2 naming the same gun, so one gun is in both hands and the raid starts with no second gun');
       // CONTROL: a third gun owned but in neither hand leaves gun 2 alone.
       if(guns.length>=3){
         var C=ITEMS[guns[2]].gk;
         P2.weapons=[A,B,C]; P2.equipped=A; P2.equippedSec=B; P2.stash=[guns[2]];
         var row2=equipRow(guns[2]);
         if(row2&&typeof row2.act==='function'){
           try{ row2.act(); }catch(_b){}
           if(P2.equippedSec!==B) bad.push('control: equipping a spare of a third gun changed gun 2 from '+B+' to '+P2.equippedSec);
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.weapons=keep.w; P2.equipped=keep.e; P2.equippedSec=keep.e2; P2.stash=keep.st; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
