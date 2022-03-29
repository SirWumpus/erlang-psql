A = .a
O = .o
B = .beam
E =
.SUFFIXES : .h .c .i $O $E .hrl .erl .beam .sh

PROJ		:= epsql

BIN		:= _build/default/bin
ELIB		:= _build/default/lib
EBIN		:= ${ELIB}/${PROJ}/ebin
ERLC_FLAGS	:= -o${EBIN}

$E$B:
	erlc ${ERLC_FLAGS} $@

all: build

build:
	rebar3 escriptize

clean:
	-rm -rf src/*$B *dump

distclean: clean
	-rm -rf _build _checkouts ebin

tar:
	git archive --format tar.gz --prefix ${PROJ}/ -o ${PROJ}.tar.gz HEAD

tests:
	rebar3 as test dialyzer
	rebar3 as test ct
