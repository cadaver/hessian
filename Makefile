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
	charset00.pak charset01.pak level00.pak level01.pak \
	common.pak item.pak weapon.pak playert.pak playerb.pak playerta.pak playerba.pak
	makedisk hessian.d64 hessian.seq HESSIAN___________HE_2A 12

hessian.d81: hessian.d64 hessiand81.seq
	c1541 < hessiand81.seq

loader.prg: kernal.s loader.s loadsym.txt ldepack.s macros.s memory.s
	dasm loader.s -oloader.bin -sloader.tbl -f3
	symbols loader.tbl loadsym.s loadsym.txt
	lpack loader.bin loader.pak
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

main.pak: intro.s actor.s actordata.s ai.s aidata.s aligneddata.s bullet.s cutscene.s file.s init.s input.s item.s itemdata.s level.s \
	leveldata.s levelactors.s macros.s main.s math.s memory.s panel.s paneldata.s physics.s player.s plot.s raster.s screen.s script.s \
	sound.s sounddata.s sprite.s text.s weapon.s weapondata.s loader.prg bg/scorescr.chr bg/world.s sfx/pistol.sfx sfx/shotgun.sfx \
	sfx/autorifle.sfx sfx/sniperrifle.sfx sfx/minigun.sfx sfx/explosion.sfx sfx/throw.sfx sfx/melee.sfx sfx/punch.sfx sfx/reload.sfx \
	sfx/cockfast.sfx sfx/cockshotgun.sfx sfx/powerup.sfx sfx/select.sfx sfx/pickup.sfx sfx/damage.sfx sfx/death.sfx \
	sfx/flamer.sfx sfx/reloadflamer.sfx sfx/launcher.sfx sfx/bazooka.sfx sfx/reloadbazooka.sfx sfx/heavymelee.sfx \
	sfx/emp.sfx sfx/laser.sfx sfx/plasma.sfx sfx/splash.sfx sfx/object.sfx sfx/footstep.sfx sfx/roll.sfx sfx/jump.sfx \
	pics/covert.iff  pics/loadpic.iff loadermusic.bin
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

charset00.pak: charset00.s memory.s bg/world00.blk bg/world00.bli bg/world00.chi bg/world00.chc bg/world00.chr
	dasm charset00.s -ocharset00_1.bin -f3
	pack2 charset00_1.bin charset00_1.pak
	pchunk2 bg/world00.blk charset00_2.pak
	filejoin charset00_1.pak+charset00_2.pak charset00.pak

charset01.pak: charset01.s memory.s bg/world01.blk bg/world01.bli bg/world01.chi bg/world01.chc bg/world01.chr
	dasm charset01.s -ocharset01_1.bin -f3
	pack2 charset01_1.bin charset01_1.pak
	pchunk2 bg/world01.blk charset01_2.pak
	filejoin charset01_1.pak+charset01_2.pak charset01.pak

level00.pak: level00.s memory.s bg/world00.map bg/world00.lvo bg/world00.lva
	dasm level00.s -olevel00_1.bin -f3
	pack2 level00_1.bin level00_1.pak
	pack2 bg/world00.lva level00_2.pak
	pchunk2 bg/world00.map level00_3.pak
	filejoin level00_1.pak+level00_2.pak+level00_3.pak level00.pak

level01.pak: level01.s memory.s bg/world01.map bg/world01.lvo bg/world01.lva
	dasm level01.s -olevel01_1.bin -f3
	pack2 level01_1.bin level01_1.pak
	pack2 bg/world01.lva level01_2.pak
	pchunk2 bg/world01.map level01_3.pak
	filejoin level01_1.pak+level01_2.pak+level01_3.pak level01.pak

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
