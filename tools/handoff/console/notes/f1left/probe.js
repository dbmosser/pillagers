(async function(){
  var out=[], sizes=[[1920,1080],[1280,720],[1366,768],[1600,900],[2560,1440],[3840,2160]];
  function r(b){ return b?[Math.round(b.x),Math.round(b.y),Math.round(b.w),Math.round(b.h)].join(','):'-'; }
  try{
    var oSay=say; say=function(){};
    __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
    __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
    var g=__state(); g.career=1; g.arcade=0; g.legendAutoDone=true;
    for(var s=0;s<sizes.length;s++){
      __forceSize(sizes[s][0],sizes[s][1]);
      for(var lo=0;lo<3;lo++){
        g.legendOn=lo; for(var i=0;i<12;i++) __frame(0.016);
        out.push(sizes[s].join('x')+' lo'+lo+' W'+W+'H'+H+' legend '+r(HUDBOX.legend)+' hint '+r(LEGHINT)+' feed '+r(FEEDBOX)+' medal '+r(MEDALBOX)+' raiders '+r(HUDBOX.raiders)+' body '+r(HUDBOX.body)+' vit '+r(VITBOX)+' hres '+hudRes().toFixed(2)+' LEGZ0 '+LEGZ0+' HUDZ '+(HUDZ.legend||0).toFixed(2));
      }
    }
    say=oSay;
  }catch(e){ out.push('threw '+e.message); }
  return out.join('\n');
})()
