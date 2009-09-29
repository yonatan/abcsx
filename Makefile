all : test test1 test2

test :
	./test.ss

test1 : examples/textField.abc
	./dump.ss examples/textField.abc

test2 : 
	./runasm.sh examples/hello.sx
	./runasm.sh examples/parseInt.sx
	./runasm.sh examples/arithmetic.sx
	./runasm.sh examples/ifte.sx
	./runasm.sh examples/callLocal.sx
	./runasm.sh examples/call.sx

clean :
	rm -f *.abc examples/*.abc launcher/*.abc

%.abc : %.as
#	asc $<
	asc -import ~/src/tamarin-central/core/builtin.abc -import examples/flashglobal.as $<

%.sx : %.abc
	./dump.ss $< > $@ || rm $@
