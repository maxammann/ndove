ARGBASH=argbash
RST2MAN=rst2man2

ndove: ndove.m4 
	$(ARGBASH) -o ndove.sh ndove.m4
	$(ARGBASH) --type manpage --strip all -o ndove.rst ndove.m4
	$(RST2MAN) ndove.rst > ndove.1