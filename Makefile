all: hessian.d64 hessian.d81 hessian.sid

clean:
	-rm *.bin
	-rm music/*.bin
	-rm sfx/*.sfx
	-rm *.pak
	-rm *.prg
	-rm *.tbl
	-rm *.d64
	-rm *.d81
	-rm hessian
	-rm 0?
	-rm 1?
	-rm 2?
	-rm 3?
	-rm 4?
	-rm 5?
	-rm 6?
	-rm 7?
	-rm 8?
	-rm 9?
	-rm a?
	-rm b?
	-rm c?
	-rm d?
	-rm e?
	-rm f?

hessian.d64: loader.prg main.pak options.bin emptysave.bin savelist.bin logo.pak \
	music00.pak music01.pak music02.pak music03.pak music04.pak music05.pak music06.pak music07.pak \
	music08.pak music09.pak music10.pak music11.pak music12.pak script00.pak \
	charset00.pak charset01.pak charset02.pak charset03.pak charset04.pak charset05.pak charset06.pak charset07.pak \
	charset08.pak charset09.pak charset10.pak charset11.pak charset12.pak charset13.pak charset14.pak \
	level00.pak level01.pak level02.pak level03.pak level04.pak level05.pak level06.pak level07.pak level08.pak \
	level09.pak level10.pak level11.pak level12.pak level13.pak level14.pak \
	common.pak item.pak weapon.pak playert.pak playerb.pak playerta.pak playerba.pak flyer.pak groundbased.pak \
	fire.pak animal.pak
	c1541 < hessian.seq

hessian.d81: hessian.d64 hessiand81.seq
	c1541 < hessiand81.seq

loader.prg: kernal.s loader.s loadsym.txt ldepack.s macros.s memory.s
	dasm loader.s -oloader.bin -sloader.tbl -f3
	symbols loader.tbl loadsym.s loadsym.txt
	pack2 loader.bin loader.pak
	dasm ldepack.s -oloader.prg

sfx/pistol.sfx: sfx/pistol.ins
	ins2nt2 sfx/pistol.ins sfx/pistol.sfx

sfx/shotgun.sfx: sfx/shotgun.ins
	ins2nt2 sfx/shotgun.ins sfx/shotgun.sfx

sfx/autorifle.sfx: sfx/autorifle.ins
	ins2nt2 sfx/autorifle.ins sfx/autorifle.sfx

sfx/sniperrifle.sfx: sfx/sniperrifle.ins
	ins2nt2 sfx/sniperrifle.ins sfx/sniperrifle.sfx

sfx/minigun.sfx: sfx/minigun.ins
	ins2nt2 sfx/minigun.ins sfx/minigun.sfx

sfx/explosion.sfx: sfx/explosion.ins
	ins2nt2 sfx/explosion.ins sfx/explosion.sfx

sfx/throw.sfx: sfx/throw.ins
	ins2nt2 sfx/throw.ins sfx/throw.sfx

sfx/melee.sfx: sfx/melee.ins
	ins2nt2 sfx/melee.ins sfx/melee.sfx

sfx/punch.sfx: sfx/punch.ins
	ins2nt2 sfx/punch.ins sfx/punch.sfx

sfx/reload.sfx: sfx/reload.ins
	ins2nt2 sfx/reload.ins sfx/reload.sfx

sfx/cockfast.sfx: sfx/cockfast.ins
	ins2nt2 sfx/cockfast.ins sfx/cockfast.sfx

sfx/cockshotgun.sfx: sfx/cockshotgun.ins
	ins2nt2 sfx/cockshotgun.ins sfx/cockshotgun.sfx

sfx/powerup.sfx: sfx/powerup.ins
	ins2nt2 sfx/powerup.ins sfx/powerup.sfx

sfx/select.sfx: sfx/select.ins
	ins2nt2 sfx/select.ins sfx/select.sfx

sfx/pickup.sfx: sfx/pickup.ins
	ins2nt2 sfx/pickup.ins sfx/pickup.sfx

sfx/damage.sfx: sfx/damage.ins
	ins2nt2 sfx/damage.ins sfx/damage.sfx

sfx/death.sfx: sfx/death.ins
	ins2nt2 sfx/death.ins sfx/death.sfx

sfx/flamer.sfx: sfx/flamer.ins
	ins2nt2 sfx/flamer.ins sfx/flamer.sfx

sfx/reloadflamer.sfx: sfx/reloadflamer.ins
	ins2nt2 sfx/reloadflamer.ins sfx/reloadflamer.sfx

sfx/launcher.sfx: sfx/launcher.ins
	ins2nt2 sfx/launcher.ins sfx/launcher.sfx

sfx/bazooka.sfx: sfx/bazooka.ins
	ins2nt2 sfx/bazooka.ins sfx/bazooka.sfx

sfx/reloadbazooka.sfx: sfx/reloadbazooka.ins
	ins2nt2 sfx/reloadbazooka.ins sfx/reloadbazooka.sfx

sfx/heavymelee.sfx: sfx/heavymelee.ins
	ins2nt2 sfx/heavymelee.ins sfx/heavymelee.sfx

sfx/emp.sfx: sfx/emp.ins
	ins2nt2 sfx/emp.ins sfx/emp.sfx

sfx/laser.sfx: sfx/laser.ins
	ins2nt2 sfx/laser.ins sfx/laser.sfx

sfx/plasma.sfx: sfx/plasma.ins
	ins2nt2 sfx/plasma.ins sfx/plasma.sfx

sfx/splash.sfx: sfx/splash.ins
	ins2nt2 sfx/splash.ins sfx/splash.sfx

sfx/object.sfx: sfx/object.ins
	ins2nt2 sfx/object.ins sfx/object.sfx

sfx/footstep.sfx: sfx/footstep.ins
	ins2nt2 sfx/footstep.ins sfx/footstep.sfx

sfx/roll.sfx: sfx/roll.ins
	ins2nt2 sfx/roll.ins sfx/roll.sfx

sfx/jump.sfx: sfx/jump.ins
	ins2nt2 sfx/jump.ins sfx/jump.sfx

sfx/animaldeath.sfx: sfx/animaldeath.ins
	ins2nt2 sfx/animaldeath.ins sfx/animaldeath.sfx

main.pak: intro.s actor.s actordata.s ai.s aidata.s aligneddata.s bullet.s enemy.s file.s init.s input.s item.s itemdata.s level.s \
	leveldata.s macros.s main.s math.s memory.s panel.s paneldata.s physics.s player.s raster.s screen.s script.s \
	sound.s sounddata.s sprite.s text.s weapon.s weapondata.s loader.prg bg/scorescr.chr bg/world.s sfx/pistol.sfx sfx/shotgun.sfx \
	sfx/autorifle.sfx sfx/sniperrifle.sfx sfx/minigun.sfx sfx/explosion.sfx sfx/throw.sfx sfx/melee.sfx sfx/punch.sfx sfx/reload.sfx \
	sfx/cockfast.sfx sfx/cockshotgun.sfx sfx/powerup.sfx sfx/select.sfx sfx/pickup.sfx sfx/damage.sfx sfx/death.sfx \
	sfx/flamer.sfx sfx/reloadflamer.sfx sfx/launcher.sfx sfx/bazooka.sfx sfx/reloadbazooka.sfx sfx/heavymelee.sfx \
	sfx/emp.sfx sfx/laser.sfx sfx/plasma.sfx sfx/splash.sfx sfx/object.sfx sfx/footstep.sfx sfx/roll.sfx sfx/jump.sfx \
	sfx/animaldeath.sfx pics/covert.iff pics/loadpic.iff loadermusic.bin
	pic2chr pics/covert.iff covert.chr -b11 -m12 -n13 -c -s -x30 -y4
	pic2chr pics/covert.iff covertscr.dat -b11 -m12 -n13 -x30 -y4 -t -c
	gfxconv pics/loadpic.iff loadpic.dat -r -b0 -o -nc -ns
	gfxconv pics/loadpic.iff loadpicscr.dat -r -b0 -o -nc -nb
	gfxconv pics/loadpic.iff loadpiccol.dat -r -b0 -o -nb -ns
	dasm main.s -omain.bin -smain.tbl -f3
	symbols main.tbl mainsym.s
	symbols main.tbl >pagecross.txt
	dasm intro.s -ointro.bin -f3
	pack2 intro.bin main_1.pak
	pack2 loadpic.dat main_2.pak
	pack2 loadpicscr.dat main_3.pak
	pack2 loadpiccol.dat main_4.pak
	pack2 main.bin main_5.pak
	filejoin main_1.pak+main_2.pak+main_3.pak+main_4.pak+main_5.pak main.pak

emptysave.bin: emptysave.s mainsym.s
	dasm emptysave.s -oemptysave.bin -f3

options.bin: options.s mainsym.s
	dasm options.s -ooptions.bin -f3

savelist.bin: savelist.s mainsym.s
	dasm savelist.s -osavelist.bin -f3

logo.pak: pics/logo.iff logo.s
	pic2chr pics/logo.iff logo.chr -m14 -n15 -x24 -y7 -c -s
	pic2chr pics/logo.iff logoscr.dat -m14 -n15 -x24 -y7 -t
	dasm logo.s -ologo.bin -f3
	pack2 logo.bin logo.pak

script00.pak: script00.s memory.s mainsym.s
	dasm script00.s -oscript00.bin -f3
	pack2 script00.bin script00.pak

loadermusic.bin: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 loader.bin loadermusic.bin -h

loadermusic2.bin: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 loader2.bin loadermusic2.bin -h

music00.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 gameover.bin music00.bin -h
	pack2 music00.bin music00.pak

music01.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 title.bin music01.bin -h
	pack2 music01.bin music01.pak

music02.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 destruction.bin music02.bin -h
	pack2 music02.bin music02.pak

music03.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 victory.bin music03.bin -h
	pack2 music03.bin music03.pak

music04.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 mystery.bin music04.bin -h
	pack2 music04.bin music04.pak

music05.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 outside.bin music05.bin -h
	pack2 music05.bin music05.pak

music06.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 offices.bin music06.bin -h
	pack2 music06.bin music06.pak

music07.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 maintenance.bin music07.bin -h
	pack2 music07.bin music07.pak

music08.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 caves.bin music08.bin -h
	pack2 music08.bin music08.pak

music09.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 throne.bin music09.bin -h
	pack2 music09.bin music09.pak

music10.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 hideout.bin music10.bin -h
	pack2 music10.bin music10.pak

music11.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 nether.bin music11.bin -h
	pack2 music11.bin music11.pak

music12.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 assault.bin music12.bin -h
	pack2 music12.bin music12.pak

hessian.sid: hessiansid.s music00.bin music01.bin music02.bin music03.bin music04.bin music05.bin music06.bin music07.bin \
	music08.bin music09.bin music10.bin music11.bin music12.bin loadermusic2.bin
	dasm hessiansid.s -ohessian.sid -f3

charset00.pak: charset00.s memory.s bg/world00.blk bg/world00.chi bg/world00.chc bg/world00.chr
	dasm charset00.s -ocharset00_1.bin -f3
	pack2 charset00_1.bin charset00_1.pak
	pchunk2 bg/world00.blk charset00_2.pak
	filejoin charset00_1.pak+charset00_2.pak charset00.pak

charset01.pak: charset01.s memory.s bg/world01.blk bg/world01.chi bg/world01.chc bg/world01.chr
	dasm charset01.s -ocharset01_1.bin -f3
	pack2 charset01_1.bin charset01_1.pak
	pchunk2 bg/world01.blk charset01_2.pak
	filejoin charset01_1.pak+charset01_2.pak charset01.pak

charset02.pak: charset02.s memory.s bg/world02.blk bg/world02.chi bg/world02.chc bg/world02.chr
	dasm charset02.s -ocharset02_1.bin -f3
	pack2 charset02_1.bin charset02_1.pak
	pchunk2 bg/world02.blk charset02_2.pak
	filejoin charset02_1.pak+charset02_2.pak charset02.pak

charset03.pak: charset03.s memory.s bg/world03.blk bg/world03.chi bg/world03.chc bg/world03.chr
	dasm charset03.s -ocharset03_1.bin -f3
	pack2 charset03_1.bin charset03_1.pak
	pchunk2 bg/world03.blk charset03_2.pak
	filejoin charset03_1.pak+charset03_2.pak charset03.pak

charset04.pak: charset04.s memory.s bg/world04.blk bg/world04.chi bg/world04.chc bg/world04.chr
	dasm charset04.s -ocharset04_1.bin -f3
	pack2 charset04_1.bin charset04_1.pak
	pchunk2 bg/world04.blk charset04_2.pak
	filejoin charset04_1.pak+charset04_2.pak charset04.pak

charset05.pak: charset05.s memory.s bg/world05.blk bg/world05.chi bg/world05.chc bg/world05.chr
	dasm charset05.s -ocharset05_1.bin -f3
	pack2 charset05_1.bin charset05_1.pak
	pchunk2 bg/world05.blk charset05_2.pak
	filejoin charset05_1.pak+charset05_2.pak charset05.pak

charset06.pak: charset06.s memory.s bg/world06.blk  bg/world06.chi bg/world06.chc bg/world06.chr
	dasm charset06.s -ocharset06_1.bin -f3
	pack2 charset06_1.bin charset06_1.pak
	pchunk2 bg/world06.blk charset06_2.pak
	filejoin charset06_1.pak+charset06_2.pak charset06.pak

charset07.pak: charset07.s memory.s bg/world07.blk bg/world07.chi bg/world07.chc bg/world07.chr
	dasm charset07.s -ocharset07_1.bin -f3
	pack2 charset07_1.bin charset07_1.pak
	pchunk2 bg/world07.blk charset07_2.pak
	filejoin charset07_1.pak+charset07_2.pak charset07.pak

charset08.pak: charset08.s memory.s bg/world08.blk bg/world08.chi bg/world08.chc bg/world08.chr
	dasm charset08.s -ocharset08_1.bin -f3
	pack2 charset08_1.bin charset08_1.pak
	pchunk2 bg/world08.blk charset08_2.pak
	filejoin charset08_1.pak+charset08_2.pak charset08.pak

charset09.pak: charset09.s memory.s bg/world09.blk bg/world09.chi bg/world09.chc bg/world09.chr
	dasm charset09.s -ocharset09_1.bin -f3
	pack2 charset09_1.bin charset09_1.pak
	pchunk2 bg/world09.blk charset09_2.pak
	filejoin charset09_1.pak+charset09_2.pak charset09.pak

charset10.pak: charset10.s memory.s bg/world10.blk bg/world10.chi bg/world10.chc bg/world10.chr
	dasm charset10.s -ocharset10_1.bin -f3
	pack2 charset10_1.bin charset10_1.pak
	pchunk2 bg/world10.blk charset10_2.pak
	filejoin charset10_1.pak+charset10_2.pak charset10.pak

charset11.pak: charset11.s memory.s bg/world11.blk bg/world11.chi bg/world11.chc bg/world11.chr
	dasm charset11.s -ocharset11_1.bin -f3
	pack2 charset11_1.bin charset11_1.pak
	pchunk2 bg/world11.blk charset11_2.pak
	filejoin charset11_1.pak+charset11_2.pak charset11.pak

charset12.pak: charset12.s memory.s bg/world12.blk bg/world12.chi bg/world12.chc bg/world12.chr
	dasm charset12.s -ocharset12_1.bin -f3
	pack2 charset12_1.bin charset12_1.pak
	pchunk2 bg/world12.blk charset12_2.pak
	filejoin charset12_1.pak+charset12_2.pak charset12.pak

charset13.pak: charset13.s memory.s bg/world13.blk bg/world13.chi bg/world13.chc bg/world13.chr
	dasm charset13.s -ocharset13_1.bin -f3
	pack2 charset13_1.bin charset13_1.pak
	pchunk2 bg/world13.blk charset13_2.pak
	filejoin charset13_1.pak+charset13_2.pak charset13.pak

charset14.pak: charset14.s memory.s bg/world14.blk bg/world14.chi bg/world14.chc bg/world14.chr
	dasm charset14.s -ocharset14_1.bin -f3
	pack2 charset14_1.bin charset14_1.pak
	pchunk2 bg/world14.blk charset14_2.pak
	filejoin charset14_1.pak+charset14_2.pak charset14.pak

level00.pak: bg/world00.map bg/world00.lvo bg/world00.lva
	pack2 bg/world00.lvo level00_1.pak
	pack2 bg/world00.lva level00_2.pak
	pchunk2 bg/world00.map level00_3.pak
	filejoin level00_1.pak+level00_2.pak+level00_3.pak level00.pak

level01.pak: bg/world01.map bg/world01.lvo bg/world01.lva
	pack2 bg/world01.lvo level01_1.pak
	pack2 bg/world01.lva level01_2.pak
	pchunk2 bg/world01.map level01_3.pak
	filejoin level01_1.pak+level01_2.pak+level01_3.pak level01.pak

level02.pak: bg/world02.map bg/world02.lvo bg/world02.lva
	pack2 bg/world02.lvo level02_1.pak
	pack2 bg/world02.lva level02_2.pak
	pchunk2 bg/world02.map level02_3.pak
	filejoin level02_1.pak+level02_2.pak+level02_3.pak level02.pak

level03.pak: bg/world03.map bg/world03.lvo bg/world03.lva
	pack2 bg/world03.lvo level03_1.pak
	pack2 bg/world03.lva level03_2.pak
	pchunk2 bg/world03.map level03_3.pak
	filejoin level03_1.pak+level03_2.pak+level03_3.pak level03.pak

level04.pak: bg/world04.map bg/world04.lvo bg/world04.lva
	pack2 bg/world04.lvo level04_1.pak
	pack2 bg/world04.lva level04_2.pak
	pchunk2 bg/world04.map level04_3.pak
	filejoin level04_1.pak+level04_2.pak+level04_3.pak level04.pak

level05.pak: bg/world05.map bg/world05.lvo bg/world05.lva
	pack2 bg/world05.lvo level05_1.pak
	pack2 bg/world05.lva level05_2.pak
	pchunk2 bg/world05.map level05_3.pak
	filejoin level05_1.pak+level05_2.pak+level05_3.pak level05.pak

level06.pak: bg/world06.map bg/world06.lvo bg/world06.lva
	pack2 bg/world06.lvo level06_1.pak
	pack2 bg/world06.lva level06_2.pak
	pchunk2 bg/world06.map level06_3.pak
	filejoin level06_1.pak+level06_2.pak+level06_3.pak level06.pak

level07.pak: bg/world07.map bg/world07.lvo bg/world07.lva
	pack2 bg/world07.lvo level07_1.pak
	pack2 bg/world07.lva level07_2.pak
	pchunk2 bg/world07.map level07_3.pak
	filejoin level07_1.pak+level07_2.pak+level07_3.pak level07.pak

level08.pak: bg/world08.map bg/world08.lvo bg/world08.lva
	pack2 bg/world08.lvo level08_1.pak
	pack2 bg/world08.lva level08_2.pak
	pchunk2 bg/world08.map level08_3.pak
	filejoin level08_1.pak+level08_2.pak+level08_3.pak level08.pak

level09.pak: bg/world09.map bg/world09.lvo bg/world09.lva
	pack2 bg/world09.lvo level09_1.pak
	pack2 bg/world09.lva level09_2.pak
	pchunk2 bg/world09.map level09_3.pak
	filejoin level09_1.pak+level09_2.pak+level09_3.pak level09.pak

level10.pak: bg/world10.map bg/world10.lvo bg/world10.lva
	pack2 bg/world10.lvo level10_1.pak
	pack2 bg/world10.lva level10_2.pak
	pchunk2 bg/world10.map level10_3.pak
	filejoin level10_1.pak+level10_2.pak+level10_3.pak level10.pak

level11.pak: bg/world11.map bg/world11.lvo bg/world11.lva
	pack2 bg/world11.lvo level11_1.pak
	pack2 bg/world11.lva level11_2.pak
	pchunk2 bg/world11.map level11_3.pak
	filejoin level11_1.pak+level11_2.pak+level11_3.pak level11.pak

level12.pak: bg/world12.map bg/world12.lvo bg/world12.lva
	pack2 bg/world12.lvo level12_1.pak
	pack2 bg/world12.lva level12_2.pak
	pchunk2 bg/world12.map level12_3.pak
	filejoin level12_1.pak+level12_2.pak+level12_3.pak level12.pak

level13.pak: bg/world13.map bg/world13.lvo bg/world13.lva
	pack2 bg/world13.lvo level13_1.pak
	pack2 bg/world13.lva level13_2.pak
	pchunk2 bg/world13.map level13_3.pak
	filejoin level13_1.pak+level13_2.pak+level13_3.pak level13.pak

level14.pak: bg/world14.map bg/world14.lvo bg/world14.lva
	pack2 bg/world14.lvo level14_1.pak
	pack2 bg/world14.lva level14_2.pak
	pchunk2 bg/world14.map level14_3.pak
	filejoin level14_1.pak+level14_2.pak+level14_3.pak level14.pak

common.pak: spr/common.spr
	pchunk2 spr/common.spr common.pak

item.pak: spr/item.spr
	pchunk2 spr/item.spr item.pak

weapon.pak: spr/weapon.spr
	pchunk2 spr/weapon.spr weapon.pak

playert.pak: spr/playert.spr
	pchunk2 spr/playert.spr playert.pak

playerb.pak: spr/playerb.spr
	pchunk2 spr/playerb.spr playerb.pak

playerta.pak: spr/playerta.spr
	pchunk2 spr/playerta.spr playerta.pak

playerba.pak: spr/playerba.spr
	pchunk2 spr/playerba.spr playerba.pak

flyer.pak: spr/flyer.spr
	pchunk2 spr/flyer.spr flyer.pak

groundbased.pak: spr/groundbased.spr
	pchunk2 spr/groundbased.spr groundbased.pak
	
fire.pak: spr/fire.spr
	pchunk2 spr/fire.spr fire.pak
	
animal.pak: spr/animal.spr
	pchunk2 spr/animal.spr animal.pak