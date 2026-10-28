(function(){ var want=['34.54','34.78','33.15','27.26','9.93','9.83'], o={}, n=0;
  __REGRESS.forEach(function(t,i){ if(want.indexOf(String(t.v))<0) return; var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(x){ r='threw '+x; } n++; o[t.v]=r?String(r).slice(0,300):'PASS'; });
  o._ran=n; return JSON.stringify(o); })()
