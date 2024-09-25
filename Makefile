DOSBOX   := dosbox
DOSCONF  := ./dosbox.conf
DOSFILES := ./MS-DOS
DOSMAKE  := $(DOSFILES)/MAKE.BAT

DEST := ./release/

JSDOSFILES  := ./js-dos
JSDOSBUNDLE := $(JSDOSFILES)/snake86.jsdos

default: all

all: msdos jsdos
	mkdir -p $(DEST)
	mv $(DOSFILES)/*.EXE $(DEST)
	cp $(DOSFILES)/*.TXT $(DEST)
	mv $(JSDOSBUNDLE) $(DEST)

msdos: $(DOSFILES)/*.ASM
	$(DOSBOX) -conf $(DOSCONF) $(DOSMAKE) -exit >/dev/null 2>&1

jsdos: msdos
	zip -qj $(JSDOSBUNDLE) $(JSDOSFILES)/dosbox.conf $(JSDOSFILES)/jsdos.json $(DOSFILES)/*.EXE
	printf "@ dosbox.conf\n@=.jsdos/dosbox.conf\n" | zipnote -w $(JSDOSBUNDLE)
	printf "@ jsdos.json\n@=.jsdos/jsdos.json\n" | zipnote -w $(JSDOSBUNDLE)

clean:
	rm -f $(DOSFILES)/*.OBJ $(DOSFILES)/*.EXE
	rm -rf $(DEST)
