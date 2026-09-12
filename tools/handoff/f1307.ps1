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

# CHECK 13.07, HARNESS ONLY, and it exists because of today rather than because of a
# defect. The game is about to be in front of strangers for the first time, and the
# first ten minutes of a brand-new profile is the one path the corpus never walks end
# to end. Everything it asserts is already true; the point is that it stays true while
# friends are playing, because from now on a regression there is found by them.
#
# THE ARM THAT MATTERS MOST IS THE ONE NOBODY TAKES. Declining the welcome pack is a
# real button and leaves a profile with no guns and an empty stash. If the deploy did
# not issue a starter to a man holding nothing, that friend's first raid would be bare
# hands and he would never say why he stopped playing.
#
# AND THE CONSENT QUESTION, which is load-bearing today: with no upload address, the
# game must not ask a stranger for permission to send something it cannot send.
SubRx @'
  {v:'13.06',what:'taking the freebie kit leaves the gun he owns
'@ @'
  {v:'13.07',what:'a brand-new player is not left stranded: the welcome pack puts a gun in his hands and not only in his armoury, declining it still deploys him with a working weapon, and with no upload address he is never asked for permission to send something the game cannot send (written the day it first went in front of strangers)',
   run:function(){
     if(!(window.__P&&window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof maybeWelcome!=='function') return 'SKIP: this build has no welcome pack';
     var bad=[], P2=__P();
     var F=['weapons','equipped','equippedSec','stash','kit','welcomed','shareAsked','shareRuns','runs','credits','xp'];
     var keep={}, fi;
     for(fi=0;fi<F.length;fi++) keep[F[fi]]=P2[F[fi]];
     var md=document.getElementById('welcomemodal');
     function fresh(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.runs=0; P2.credits=0; P2.xp=0; P2.stash=[]; P2.weapons=[]; P2.kit=[];
       P2.equipped='fists'; P2.equippedSec='none'; P2.shareRuns=false;
       try{ delete P2.welcomed; }catch(_d1){}
       try{ delete P2.shareAsked; }catch(_d2){}
       saveProfile();
       __showScreen('hub'); __hubEnter();
     }
     try{
       // TAKING THE PACK. v10.67 put the guns into his HANDS as well as the armoury,
       // because the deploy issues a starter to anyone holding nothing and his two new
       // guns would otherwise sit in the armoury while he went up with something else.
       fresh();
       maybeWelcome();
       if(!md||!md.classList.contains('on')){
         bad.push('a brand-new profile is never offered the welcome pack, so a friend arrives with no guns, an empty stash and nothing explaining why');
       } else {
         var take=document.getElementById('welcometake');
         if(!take||!take.onclick) bad.push('the welcome pack has no way to accept it');
         else {
           take.onclick();
           if(!(P2.weapons||[]).length)
             bad.push('taking the welcome pack put no gun in his armoury at all');
           if(!P2.equipped||P2.equipped==='fists')
             bad.push('taking the welcome pack left him holding nothing: the guns went to the armoury and his hands stayed empty, so his first raid issues him something else and the pack he just accepted sits at home');
           if(!(P2.stash||[]).length)
             bad.push('taking the welcome pack put nothing in his stash');
           if(!P2.welcomed)
             bad.push('taking the welcome pack did not mark it done, so he is offered it again every time he comes down');
         }
       }
       try{ if(md) md.classList.remove('on'); }catch(_c1){}
       // DECLINING IT. The arm nobody takes, and the one where a friend ends up with
       // nothing at all. He must still be able to go up and fight.
       fresh();
       maybeWelcome();
       var no=document.getElementById('welcomeno');
       if(md&&md.classList.contains('on')&&no&&no.onclick){
         no.onclick();
         if(!P2.welcomed)
           bad.push('declining the welcome pack did not mark it done, so he is asked again every time');
         if((P2.weapons||[]).length||(P2.stash||[]).length)
           bad.push('declining the welcome pack handed him the pack anyway, so the choice is not a choice');
         // The deploy is what rescues him, and this is the only place it is proved.
         if(window.__deploy&&window.__state){
           try{
             __deploy({kit:[],safe:null,mapIx:0,seed:4242});
             var g=__state(), pw=g&&g.player&&g.player.wep;
             if(!pw||pw.id==='fists')
               bad.push('a friend who declined the welcome pack goes up bare-handed: he owns no gun, and the deploy did not issue him one, so his first raid is unwinnable and he will never say why he stopped');
           }catch(_dp){ bad.push('deploying a player who declined the welcome pack threw: '+(_dp&&_dp.message||_dp)); }
           try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
           try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
         }
       }
       try{ if(md) md.classList.remove('on'); }catch(_c2){}
       // THE CONSENT QUESTION. With no address to send to there is nothing to consent
       // to, and a stranger must not be asked for permission the game cannot use.
       if(typeof maybeShareAsk==='function'&&typeof PUBLIC_DROP!=='undefined'){
         fresh();
         var sm=document.getElementById('sharemodal');
         maybeShareAsk();
         var asked=!!(sm&&sm.classList.contains('on'));
         if(!PUBLIC_DROP&&asked)
           bad.push('with no upload address the game still asks a stranger whether his run reports may be sent, and answering yes sends nothing anywhere, which is a promise it cannot keep');
         if(PUBLIC_DROP&&!asked)
           bad.push('there IS an upload address and the question is never put, so either nothing is ever sent or it is sent without anyone being asked');
         if(!PUBLIC_DROP&&P2.shareRuns===true)
           bad.push('sharing is switched ON for a brand-new profile, and it must be off until a person says otherwise');
         try{ if(sm) sm.classList.remove('on'); }catch(_c3){}
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(md) md.classList.remove('on'); }catch(_c4){}
       try{ var sm2=document.getElementById('sharemodal'); if(sm2) sm2.classList.remove('on'); }catch(_c5){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q2){}
       try{ for(var fj=0;fj<F.length;fj++) P2[F[fj]]=keep[F[fj]]; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c6){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.06',what:'taking the freebie kit leaves the gun he owns
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
