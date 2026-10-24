# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-24 13:20, since d1987b9fd)

LINE 46013: RSTAT.lines=[]; - This line clears the lines array, which might not be intended if other parts of the code rely on its contents.
LINE 46025: if(raidClockOn()){ t=Math.ceil(Math.max(0,+G.timeLeft||0)); T.push({l:'RAID CLOCK',v:fmtClock(t),c:(t<=CLOCK_RED)?'#ff5a4a':'#e8eef2',s:'ELAPSED '+fmtClock(elapsed()),big:1,rail:(t<=CLOCK_RED)?'#e5482f':'#4a5257'}); } - The use of +G.timeLeft||0 could potentially lead to NaN if G.timeLeft is not a number or undefined.
LINE 46031: try{ goalsTiles(T); }catch(_gtl){} - This try/catch block swallows any exceptions thrown by the goalsTiles function, which might hide bugs and make debugging difficult.
LINE 46109: ctx.strokeStyle='rgba(255,90,74,'+pulse+')'; ctx.lineWidth=2*_cr; - The pulse variable is used directly in a string without checking if it's NaN or undefined.
LINE 46138: } else { - This line has no code after the conditional return statement on LINE 46139,
