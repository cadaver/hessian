all: d642prg.exe filejoin.exe gfxconv.exe gt2nt2.exe invert.exe lpack.exe ldepack.exe countobj.exe makedisk.exe pack2.exe pchunk2.exe pic2chr.exe prg2d64.exe mchunk.exe leveled.exe spred.exe symbols.exe ins2nt2.exe

clean:
	del *.exe
	del *.spr
	del editor.pal
	del editor.dat
	del editdata.c

editor.dat: bmeconv.exe datafile.exe editor.lbm editfont.lbm
	bmeconv -s -t255 -r254 -h253 editor.lbm editor.spr
	bmeconv -s -t255 -r254 -h253 editfont.lbm editfont.spr
	bmeconv -p editor.lbm editor.pal
	datafile editor.dat filelist.txt

editdata.c: dat2inc.exe editor.dat
	dat2inc editor.dat editdata.c

bmeconv.exe: bmeconv.c fileio.c
	gcc bmeconv.c fileio.c -obmeconv.exe

datafile.exe: datafile.c fileio.c
	gcc datafile.c fileio.c -odatafile.exe

gfxconv.exe: gfxconv.c fileio.c
	gcc gfxconv.c fileio.c -ogfxconv.exe

pic2chr.exe: pic2chr.c fileio.c
	gcc pic2chr.c fileio.c -opic2chr.exe

dat2inc.exe: dat2inc.c
	gcc dat2inc.c -odat2inc.exe

d642prg.exe: d642prg.c
	gcc d642prg.c -od642prg.exe

filejoin.exe: filejoin.c
	gcc filejoin.c -ofilejoin.exe

gt2nt2.exe: gt2nt2.c fileio.c
	gcc gt2nt2.c fileio.c -ogt2nt2.exe

invert.exe: invert.c
	gcc invert.c -oinvert.exe

lpack.exe: lpack.c
	gcc lpack.c -olpack.exe

ldepack.exe: ldepack.c
	gcc ldepack.c -oldepack.exe

countobj.exe: countobj.c fileio.c
	gcc countobj.c fileio.c -ocountobj.exe

makedisk.exe: makedisk.c
	gcc makedisk.c -omakedisk.exe

pchunk2.exe: pchunk2.c
	gcc pchunk2.c -opchunk2.exe

pack2.exe: pack2.c
	gcc pack2.c -opack2.exe

prg2d64.exe: prg2d64.c
	gcc prg2d64.c -oprg2d64.exe

mchunk.exe: mchunk.c
	gcc mchunk.c -omchunk.exe

leveled.exe: leveled.c editdata.c stb_image_write.c
	gcc leveled.c editdata.c stb_image_write.c libbme.a -oleveled.exe -lmingw32 -lSDLmain -lSDL

spred.exe: spred.c fileio.c editdata.c
	gcc spred.c editdata.c fileio.c libbme.a -ospred.exe -lmingw32 -lSDLmain -lSDL

symbols.exe: symbols.c
	gcc symbols.c -osymbols.exe

ins2nt2.exe: ins2nt2.c fileio.c
	gcc ins2nt2.c fileio.c -oins2nt2.exe