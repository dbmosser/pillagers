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

if ($s.Contains("  {v:'37.57',what:")) { throw "check 37.57 is in the fixture already" }

SubRx @'
  {v:'37.56',what:
'@ @'
  {v:'37.57',what:'stash gun break down yields rarity parts only, respects locks and clears orphaned forge records',
   run:function(){
     var hub=document.getElementById('hub'), saved=P, was=hub&&hub.classList.contains('on'), oldSave=saveProfile, oldStore=storeSet, oldRefresh=refreshInv, saves=0, refreshes=0, smgR=ITEMS.gun_smg.r, rifleR=ITEMS.gun_rifle.r;
     function row(k,ctx){ return itemMenuRows(k,ctx||'stash',1).filter(function(r){ return r.label==='break down'; })[0]; }
     function cnt(k){ return P.stash.filter(function(x){ return x===k; }).length; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){ saves++; }; refreshInv=function(){ refreshes++; };
       hub.classList.add('on');
       // v28.xx (cw-cx-breakguns): the one-rarity upgrade runs at startup, making the live smg rare and rifle elite. Also stage the brief's uncommon and rare examples explicitly.
       var cases=[['gun_pistol',{comp:1,scrap:2}],['gun_smg',{servo:2,board:2,comp:1}],['gun_rifle',{servo:3,board:3,optic:1,comp:2}],['gun_lance',{servo:3,board:3,optic:1,comp:2}],['gun_smg',{servo:1,board:1,comp:1},'uncommon'],['gun_rifle',{servo:2,board:2,comp:1},'rare']], i,j,k,r,before,total,credits,xp,s0,f0,oldR;
       for(i=0;i<cases.length;i++){
         k=cases[i][0]; P.stash=[k,'servo','board','comp','optic','scrap']; P.kit=[]; P.keep={}; P.junk={}; P.hotAssign={}; P.weapons=[]; P.forged={}; P.freeKit=0;
         oldR=ITEMS[k].r; if(cases[i][2]) ITEMS[k].r=cases[i][2];
         P.forged[ITEMS[k].gk]={fk:1,el:''};
         before={}; P.stash.forEach(function(x){ before[x]=(before[x]||0)+1; });
         credits=P.credits; xp=P.xp; s0=saves; f0=refreshes;
         r=row(k); if(!r) return k+': no break down row';
         if(r.hint!==Object.keys(cases[i][1]).map(function(x){ return x+' '+cases[i][1][x]; }).join(', ')) return k+': wrong parts hint';
         r.act(); total=0;
         if(cnt(k)!==0) return k+': gun was not consumed';
         for(j in before) if(j!==k&&cnt(j)!==before[j]+(cases[i][1][j]||0)) return k+': wrong yield for '+j;
         for(j in cases[i][1]) total+=cases[i][1][j]*ival(j);
         if(!(total<ival(k))) return k+': parts worth at least the gun';
         if(P.credits!==credits||P.xp!==xp) return k+': awarded money or xp';
         if(P.forged[ITEMS[k].gk]) return k+': orphaned forge record';
         if(saves!==s0+1||refreshes!==f0+1) return k+': did not save and refresh once';
         r.act(); if(cnt('servo')!==1+(cases[i][1].servo||0)) return k+': stale row granted more parts';
         ITEMS[k].r=oldR;
       }
       P.stash=['gun_rifle','gun_rifle']; P.weapons=[]; P.forged={rifle:{fk:1,el:''}};
       row('gun_rifle').act(); if(cnt('gun_rifle')!==1||!P.forged.rifle) return 'one copy did not preserve the spare gun and forge record';
       r=row('gun_rifle'); P.keep.gun_rifle=1;
       if(row('gun_rifle')) return 'locked gun offers break down';
       r.act(); if(cnt('gun_rifle')!==1) return 'stale row broke a locked gun';
       P.keep={}; if(row('gun_rifle','kit')||row('gun_rifle','stage')||row('servo')) return 'break down offered outside stash guns';
       r=row('gun_rifle'); hub.classList.remove('on');
       if(row('gun_rifle')) return 'break down offered outside stash screen';
       r.act(); if(cnt('gun_rifle')!==1) return 'stale row broke gun outside stash screen';
       return null;
     } finally {
       ITEMS.gun_smg.r=smgR; ITEMS.gun_rifle.r=rifleR;
       saveProfile=oldSave; storeSet=oldStore; refreshInv=oldRefresh; P=saved;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); if(hub) hub.classList.toggle('on',!!was);
     }
   }},
  {v:'37.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
