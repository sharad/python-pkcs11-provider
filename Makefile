


PREFIX = /usr/local

CYTHON = cython

CFLAGS = \
	-fPIC \
	-Wall \
	-Wextra \
	$(shell pkg-config --cflags python3-embed) \
	-D "CK_PTR=*" \
	-D "CK_DEFINE_FUNCTION(returnType, name)=returnType name" \
	-D "CK_DECLARE_FUNCTION(returnType, name)=returnType name" \
	-D "CK_DECLARE_FUNCTION_POINTER(returnType, name)=returnType (* name)" \
	-D "CK_CALLBACK_FUNCTION(returnType, name)=returnType (* name)" \
	$(NULL)

LDFLAGS = \
	-shared \
	$(shell pkg-config --libs python3-embed) \
	$(NULL)

SRC = \
	src/pkcs11.pyx

TARGET = python-pkcs11-provider.so

%.c: %.pyx
	$(CYTHON) -3 -o $@ $<

%.h: %.c
	echo Nothing

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

OBJS = $(SRC:.pyx=.o)
OBJS += src/entrypoint.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

all: $(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)


src/entrypoint.o: src/entrypoint.c src/pkcs11.h
	$(CC) $(CFLAGS) -o $@ -c $<

install: $(TARGET)
	mkdir -p $(PREFIX)/lib/
	install $(TARGET) $(PREFIX)/lib/

.PHONY: all clean
