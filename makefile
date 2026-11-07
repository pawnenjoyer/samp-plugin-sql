# Copyright (c) 2013-2014, Dan
# ELF64 / MariaDB Connector/C overlay for open.mp (Republic Online).
# Original 32-bit makefile: makefile.m32
#
#   make                 # linux x86_64 sql.so, MySQL via libmariadb
#   make ARCH=m32        # original i686 + bundled libmysql (not used on omp x64)
#
# Output: bin/sql.so

ifndef CC
	CC = gcc
endif

ifndef GXX
	GXX = g++
endif

ARCH ?= x64
OUTDIR = bin
OUTFILE = $(OUTDIR)/sql.so

ifeq ($(ARCH),m32)
	include makefile.m32
else

MARIADB_CONFIG ?= $(shell command -v mariadb_config 2>/dev/null)
ifneq ($(MARIADB_CONFIG),)
	MARIADB_CFLAGS := $(shell $(MARIADB_CONFIG) --include)
	MARIADB_LIBS := $(shell $(MARIADB_CONFIG) --libs)
else
	MARIADB_CFLAGS := $(shell pkg-config --cflags libmariadb 2>/dev/null || pkg-config --cflags mariadb 2>/dev/null)
	MARIADB_LIBS := $(shell pkg-config --libs libmariadb 2>/dev/null || pkg-config --libs mariadb 2>/dev/null)
	ifeq ($(MARIADB_LIBS),)
		MARIADB_LIBS := -lmariadb
	endif
endif

COMPILE_FLAGS = -c -fPIC -O2 -Wall -pthread -std=gnu++11 \
	-Iinclude/ -Isrc/ -Isrc/sdk/ -Isrc/sdk/amx/ \
	$(MARIADB_CFLAGS) \
	-DLINUX -DHAVE_STDINT_H -DPLUGIN_SUPPORTS_MYSQL=1 \
	-DHAVE_DLOPEN=1

LIBRARIES = -lpthread -lrt -ldl -latomic $(MARIADB_LIBS)

SOURCES = \
	src/sdk/amxplugin.cpp \
	src/sdk/amxplugin2.cpp \
	src/sql/SQL_Connection.cpp \
	src/sql/SQL_Pools.cpp \
	src/sql/SQL_ResultSet.cpp \
	src/sql/SQL_Statement.cpp \
	src/sql/mysql/MySQL_Connection.cpp \
	src/sql/mysql/MySQL_ResultSet.cpp \
	src/sql/mysql/MySQL_Statement.cpp \
	src/Logger.cpp \
	src/Mutex.cpp \
	src/Natives.cpp \
	src/main.cpp

OBJECTS = $(notdir $(SOURCES:.cpp=.o))

all: $(OUTFILE)

$(OUTFILE): $(SOURCES)
	mkdir -p $(OUTDIR)
	$(GXX) $(COMPILE_FLAGS) $(SOURCES)
	$(GXX) -shared -fPIC -pthread -Wl,-rpath,'$$ORIGIN' -o $(OUTFILE) $(OBJECTS) $(LIBRARIES)
	rm -f $(OBJECTS)
	@echo "built $(OUTFILE)"

clean:
	rm -f *.o $(OUTFILE)

endif
