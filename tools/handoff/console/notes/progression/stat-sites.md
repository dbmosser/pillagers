# Where each player stat lives (mapped 11-01 on v37.13, for m0 gear stats and m4 picks)

Line numbers drift; grep the quoted text. G.sim is the bot batch runner (runSim -> simStep -> updateBot): it never calls updatePlayer, but its p is still G.player, so any shared helper needs a !G.sim guard. AI pillagers and machines never touch these lines. Co-op: every window runs its own G.player; on the host a party member is a proxy (p.net), so gear on a party body must come over the network (like p.cr).

1. Move speed: updatePlayer, `var spd=CFG.pSpeed*armorById(p.rig).spd;` (then stim, wade, ADS, SPEED_FLOOR). Player only; the bot uses botSpd.
2. Stamina: updatePlayer, `else if(sprint) p.stam=Math.max(0,p.stam-26*dt); else p.stam=Math.min(100,p.stam+7.5*dt);`. Max 100 is hard coded in several places (stim, close call, stamFade, HUD); scale drain/regen, not the max. Roll cost ROLLSTAM.
3. Reload: updatePlayer `p.reloading=p.wep.reload*buzzSlow();` (R key and held trigger) and `p.reloading=p.wep.reload;` (auto reload, no buzzSlow). Countdown in tickReload. The gun's own reload is baked by rarity/Forge: wrong place for gear.
4. Spread: fireWeapon `var spx=wep.spread*(...)*(fromPlayer?bloomMul(G.player):1)+(fromPlayer?bloomCone(G.player,wep):0);` shared with the bot (fromPlayer true there too): gate fromPlayer&&!G.sim.
5. Noise: ping(), `if(src==='player'&&G.player&&!pre) s*=armorById(G.player.rig).noise;` is the single choke point (steps, shots, search). Add &&!G.sim (the bot pings as 'player'). A teammate's ping arrives with pre set, already scaled.
6. Detection: updateEnts, `var _fSee=_far0*(e.alert>0?1.35:1)*pcon*wkSight, _aSee=_amb0*pcon*wkSight;` per enemy per frame (hot). Gate on p===G.player&&!G.sim; a party proxy needs the value sent.
7. Bandage/medkit time: startPrep `max:(kind==='armor'?...CFG.armorPrep...:...CFG.healPrep...)`, shared with the bot and with bandaging a teammate. Heal amount healAmt, rate in applyHeal.
8. Downed time: damagePlayer `p.downT=CFG.downTime;`, shared with the sim; the HUD divides by CFG.downTime, so it must use the same multiplied value.
9. Revive: netRevHold, `if(G.netRevT<NET_REV_T) return true;` in the reviver's window (the reviver's gear). Co-op only.
10. Search: updatePlayer `near.prog=(near.prog||0)+dt/buzzSlow()*...`; joiner prediction has the same expression; the host searching for a party member uses r.slow from the 'srch' message (fold gear into that slow value and it travels free).
Armor: damagePlayer, after `amt*=CFG.eDmg*easyDmgMul();` is where a gear damage cut fits (gate !G.sim). Rig table ARMORS {cap,spd,noise,bulk,absorb} via armorById(p.rig) is the existing gear-shaped hook.
Hot code: updatePlayer, tickPlayerSteps, updateEnts sight block, canSee, ping, bloomTick, tickHeal, tickReload, all of updateBot. Cache gear per raid on the body (p.gm), never recompute in these.
Existing hooks: buzzSlow() (reload, search; sim-safe), STIM_SPD, pwrMul party power-ups, CFG dials (global, used by the bot too: not for per-player gear).
