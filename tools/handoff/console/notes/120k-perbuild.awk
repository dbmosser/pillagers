/ demo2 /&&/build=/&&!/gfx=none/{
  b="";w="";w2="";
  for(i=1;i<=NF;i++){ if($i~/^build=/)b=substr($i,7); if($i~/^work=/)w=substr($i,6); if($i~/^work2=/)w2=substr($i,7) }
  split(w,a,"/"); split(w2,c,"/");
  if(a[1]>2000){ n[b]++; s50[b]+=a[2]; s95[b]+=a[3]; s99[b]+=a[4]; if(c[1]>2000){ m[b]++; t50[b]+=c[2]; t95[b]+=c[3]; t99[b]+=c[4] } }
}
END{ for(b in n) printf "%s n=%d w1 %.2f/%.2f/%.2f n2=%d w2 %.2f/%.2f/%.2f\n", b,n[b],s50[b]/n[b],s95[b]/n[b],s99[b]/n[b],m[b],(m[b]?t50[b]/m[b]:0),(m[b]?t95[b]/m[b]:0),(m[b]?t99[b]/m[b]:0) }
