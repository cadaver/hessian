all: hessian.d64 hessian.d81

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

hessian.d64: boot.prg loader.pak main.pak music00.pak script00.pak level00.pak level01.pak common.pak item.pak weapon.pak player.pak
	makedisk hessian.d64 hessian.seq HESSIAN___________HE_2A 12

hessian.d81: hessian.d64 hessiand81.seq
	c1541 < hessiand81.seq

boot.prg: boot.s kernal.s memory.s loader.pak
	dasm boot.s -oboot.prg

loader.pak: kernal.s loader.s ldepack.s macros.s memory.s
	dasm loader.s -oloader.bin -sloader.tbl -f3
	symbols loader.tbl loadsym.s loadsym.txt
	lpack loader.bin ldata.pak
	dasm ldepack.s -oldepack.bin -f3
	invert ldepack.bin ldepack.bin
	filejoin ldepack.bin+ldata.pak loader.pak

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

sfx/sonicwave.sfx: sfx/sonicwave.ins
	ins2nt2 sfx/sonicwave.ins sfx/sonicwave.sfx

sfx/heavymelee.sfx: sfx/heavymelee.ins
	ins2nt2 sfx/heavymelee.ins sfx/heavymelee.sfx

sfx/emp.sfx: sfx/emp.ins
	ins2nt2 sfx/emp.ins sfx/emp.sfx

sfx/laser.sfx: sfx/laser.ins
	ins2nt2 sfx/laser.ins sfx/laser.sfx

sfx/plasma.sfx: sfx/plasma.ins
	ins2nt2 sfx/plasma.ins sfx/plasma.sfx

sfx/drone.sfx: sfx/drone.ins
	ins2nt2 sfx/drone.ins sfx/drone.sfx

main.pak: actor.s actordata.s ai.s aidata.s bullet.s data.s file.s init.s item.s itemdata.s level.s macros.s \
	main.s math.s memory.s panel.s paneldata.s physics.s player.s raster.s screen.s script.s sound.s sounddata.s \
	sprite.s text.s weapon.s weapondata.s loader.pak bg/scorescr.chr sfx/pistol.sfx sfx/shotgun.sfx sfx/autorifle.sfx \
	sfx/sniperrifle.sfx sfx/minigun.sfx sfx/explosion.sfx sfx/throw.sfx sfx/melee.sfx sfx/punch.sfx sfx/reload.sfx \
	sfx/cockfast.sfx sfx/cockshotgun.sfx sfx/powerup.sfx sfx/select.sfx sfx/pickup.sfx sfx/damage.sfx sfx/death.sfx \
	sfx/flamer.sfx sfx/reloadflamer.sfx sfx/launcher.sfx sfx/bazooka.sfx sfx/reloadbazooka.sfx sfx/sonicwave.sfx \
	sfx/heavymelee.sfx sfx/emp.sfx sfx/laser.sfx sfx/plasma.sfx sfx/drone.sfx
	dasm main.s -omain.bin -smain.tbl -f3
	symbols main.tbl mainsym.s
	pack2 main.bin main.pak

script00.pak: script00.s memory.s mainsym.s bg/logo.chr bg/logoscr.bin bg/logocol.bin
	dasm script00.s -oscript00.bin -f3
	pack2 script00.bin script00.pak

music00.pak: music/ninjatr2.d64
	d642prg music/ninjatr2.d64 testmusic.bin music00.bin -h
	pack2 music00.bin music00.pak

level00.pak: level00.s memory.s bg/level00.map bg/level00.blk bg/level00.chi bg/level00.chc bg/level00.chr bg/level00.lva
	dasm level00.s -olevel00_1.bin -f3
	pack2 level00_1.bin level00_1.pak
	pchunk2 bg/level00.map level00_2.pak
	pchunk2 bg/level00.blk level00_3.pak
	filejoin level00_1.pak+level00_2.pak+level00_3.pak level00.pak

level01.pak: level01.s memory.s bg/level01.map bg/level01.blk bg/level01.chi bg/level01.chc bg/level01.chr bg/level01.lva
	dasm level01.s -olevel01_1.bin -f3
	pack2 level01_1.bin level01_1.pak
	pchunk2 bg/level01.map level01_2.pak
	pchunk2 bg/level01.blk level01_3.pak
	filejoin level01_1.pak+level01_2.pak+level01_3.pak level01.pak

common.pak: spr/common.spr
	pchunk2 spr/common.spr common.pak

item.pak: spr/item.spr
	pchunk2 spr/item.spr item.pak

weapon.pak: spr/weapon.spr
	pchunk2 spr/weapon.spr weapon.pak

player.pak: spr/player.spr
	pchunk2 spr/player.spr player.pak
