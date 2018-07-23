CC=gcc
CXX=g++
CFLAGS=-O2 -Wall -fPIC
LDFLAGS=-L/opt/vc/lib -lbrcmEGL -lbrcmGLESv2 -ljpeg
INCLUDE=-I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include
FONT2OPENVG_INCLUDE=-I/usr/include/freetype2
FONT2OPENVG_LDFLAGS=-lfreetype

SRCDIR=./src
OBJDIR=./build
FONTSRCDIR=./lib

PREFIX=/usr
DEST=$(DESTDIR)$(PREFIX)
BINDIR=$(DEST)/bin
LIBDIR=$(DEST)/lib
INCDIR=$(DEST)/include

SRC=$(wildcard $(SRCDIR)/*.c)
OBJ=$(subst $(SRCDIR), $(OBJDIR), $(SRC:.c=.o))
LIB=$(OBJDIR)/libshapes.so
FONTS=$(FONTSRCDIR)/DejaVuSans.inc


all: $(LIB)

clean:
	rm -rf $(OBJDIR)
	rm -f $(wildcard $(FONTSRCDIR)/*.inc)

install: $(LIB)
	install -m755 -p $(OBJDIR)/font2openvg $(BINDIR)
	install -m755 -p $(OBJDIR)/libshapes.so $(LIBDIR)/libshapes.so.1.0.0
	ln -sf $(LIBDIR)/libshapes.so.1.0.0 $(LIBDIR)/libshapes.so
	ln -sf $(LIBDIR)/libshapes.so.1.0.0 $(LIBDIR)/libshapes.so.1
	ln -sf $(LIBDIR)/libshapes.so.1.0.0 $(LIBDIR)/libshapes.so.1.0
	install -m644 -p $(SRCDIR)/libshapes.h $(INCDIR)
	install -m644 -p $(SRCDIR)/fontinfo.h $(INCDIR)

uninstall:
	rm -f $(BINDIR)/font2openvg
	rm -f $(BINDIR)/libshapes.so.1.0.0
	rm -f $(BINDIR)/libshapes.so.1.0
	rm -f $(BINDIR)/libshapes.so.1
	rm -f $(INCDIR)/libshapes.h
	rm -f $(INCDIR)/fontinfo.h


$(LIB): $(OBJ)
	$(CC) $(LDFLAGS) -shared -o $@ $(OBJ)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(FONTS)
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) $(INCLUDE) -c -o $@ $<

$(OBJDIR)/font2openvg: ./lib/font2openvg.cpp
	@mkdir -p $(OBJDIR)
	$(CXX) $(CFLAGS) $(FONT2OPENVG_INCLUDE) $(FONT2OPENVG_LDFLAGS) -o $@ $<

$(FONTSRCDIR)/DejaVuSans.inc: $(OBJDIR)/font2openvg /usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf
	$< $(word 2,$^) $@ DejaVuSans


.PHONY: all clean install uninstall
