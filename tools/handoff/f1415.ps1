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
  {v:'14.14',what:
'@ @'
  {v:'14.15',what:'a second hire does not eat the first fee: with someone hired, clicking another row on the hire bench leaves the credits and the hire alone and says why, a row he cannot afford says so, and an unhired bench still hires and charges once (Undercroft audit finding 1)',
   run:function(){
     if(typeof renderMerc!=='function'||typeof mercCost!=='function'||typeof IDENTITIES==='undefined') return 'SKIP: no hire bench in this build';
     var bad=[], got=[], _s2=say2, prof;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); }catch(_h){}
       var ids=[]; for(var i=0;i<IDENTITIES.length&&ids.length<2;i++) if(mercCost(IDENTITIES[i].id)!==null) ids.push(IDENTITIES[i].id);
       if(ids.length<2) return 'SKIP: fewer than two identities will work for hire on a clean profile';
       var row=function(id){ renderMerc(); return document.querySelector('#merclist [data-merc="'+id+'"]'); };
       say2=function(t){ got.push(String(t)); };
       // ARM 1, the control: nobody hired and plenty of credits, so a click hires and charges its fee once.
       prof.merc=null; prof.credits=1000000;
       var cA=mercCost(ids[0]), r=row(ids[0]);
       if(!r) return 'SKIP: the hire bench drew no row for '+ids[0];
       r.onclick();
       if(prof.merc!==ids[0]) bad.push('control: with nobody hired and 1,000,000 credits, clicking a row did not hire (hire is '+prof.merc+')');
       if(prof.credits!==1000000-cA) bad.push('control: the hire charged '+(1000000-prof.credits)+', not its fee of '+cA);
       // ARM 2, THE FIX: a second row with someone hired changes nothing and says why.
       var before=prof.credits; got.length=0;
       r=row(ids[1]); if(r) r.onclick(); else bad.push('control: no row for '+ids[1]);
       if(prof.credits!==before) bad.push('with '+ids[0]+' hired, clicking '+ids[1]+' took '+(before-prof.credits)+' credits and the first fee was gone');
       if(prof.merc!==ids[0]) bad.push('with '+ids[0]+' hired, clicking '+ids[1]+' replaced the hire with '+prof.merc);
       if(!got.length) bad.push('clicking a second hire said nothing');
       // ARM 3: a row he cannot afford says so.
       if(mercCost(ids[1])>0){
         prof.merc=null; prof.credits=0; got.length=0;
         r=row(ids[1]); if(r) r.onclick();
         if(prof.merc) bad.push('with 0 credits a row hired '+prof.merc);
         if(!got.length) bad.push('with 0 credits, clicking a row he cannot afford said nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say2=_s2; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'14.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
