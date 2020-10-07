export SHELL:=/bin/bash
OCAMLC = ocamlc -thread -g
OCAMLYACC = ocamlyacc
OCAMLLEX = ocamllex

all: karel-as karel-disasm karel-run karel-cc karel-exec

clean:
	rm -rf $(CLEAN)


# karel-as building
AS_CMD=karel-as
AS_SOURCES = \
	common.ml \
	quad.ml \
	comp.ml \
	asparser.mly \
	aslexer.mll \
	as.ml
AS_OBJECTS = $(patsubst %.mll,%.cmo,$(patsubst %.mly,%.cmo,$(patsubst %.ml,%.cmo,$(AS_SOURCES))))
CLEAN += \
	$(AS_OBJECTS) \
	asparser.ml \
	asparser.mli \
	asparser.cmi \
	asparser.output \
	aslexer.ml \
	$(AS_CMD)
$(AS_CMD): $(AS_OBJECTS)
	$(OCAMLC) -o $@ unix.cma $(AS_OBJECTS) $(AS_OBJECT:.cmo=.cmi)


# karel-disasm building
DISASM_CMD=karel-disasm
DISASM_SOURCES = \
	common.ml \
	quad.ml \
	comp.ml \
	disasm.ml
DISASM_OBJECTS = $(patsubst %.mll,%.cmo,$(patsubst %.mly,%.cmo,$(patsubst %.ml,%.cmo,$(DISASM_SOURCES))))
CLEAN += $(DISASM_OBJECTS) $(DISASM_CMD)
$(DISASM_CMD): $(DISASM_OBJECTS)
	$(OCAMLC) -o $@ unix.cma $(DISASM_OBJECTS) $(DISASM_OBJECT:.cmo=.cmi)


# karel-run building
RUN_CMD=karel-run
RUN_SOURCES = \
	common.ml \
	quad.ml \
	vm.ml \
	karel.ml \
	wparser.mly \
	wlexer.mll \
	vector.ml \
	ui.ml \
	comp.ml \
	run.ml
RUN_OBJECTS = $(patsubst %.mll,%.cmo,$(patsubst %.mly,%.cmo,$(patsubst %.ml,%.cmo,$(RUN_SOURCES))))
CLEAN += $(RUN_OBJECTS) $(RUN_CMD)
$(RUN_CMD): $(RUN_OBJECTS)
	$(OCAMLC) -o $@ unix.cma  threads.cma graphics.cma $(RUN_OBJECTS) $(RUN_OBJECT:.cmo=.cmi)


# karel-exec building
EXEC_CMD=karel-exec
EXEC_SOURCES = \
	common.ml \
	quad.ml \
	vm.ml \
	karel.ml \
	wparser.mly \
	wlexer.mll \
	comp.ml \
	exec.ml
EXEC_OBJECTS = $(patsubst %.mll,%.cmo,$(patsubst %.mly,%.cmo,$(patsubst %.ml,%.cmo,$(EXEC_SOURCES))))
CLEAN += $(EXEC_OBJECTS) $(EXEC_CMD)
$(EXEC_CMD): $(EXEC_OBJECTS)
	$(OCAMLC) -o $@ unix.cma  $(EXEC_OBJECTS) $(EXEC_OBJECT:.cmo=.cmi)


# karel-cc building
CC_CMD=karel-cc
CC_SOURCES = \
	common.ml \
	quad.ml \
	vm.ml \
	karel.ml \
	comp.ml \
	parser.mly \
	lexer.mll \
	cc.ml
CC_OBJECTS = $(patsubst %.mll,%.cmo,$(patsubst %.mly,%.cmo,$(patsubst %.ml,%.cmo,$(CC_SOURCES))))
CLEAN += $(CC_OBJECTS) $(CC_CMD)
$(CC_CMD): $(CC_OBJECTS)
	$(OCAMLC) -o $@ unix.cma $(CC_OBJECTS) $(CC_OBJECT:.cmo=.cmi)


# other dependencies
parser.cmo: parser.cmi common.cmo vm.cmo karel.cmo
parser.cmi: comp.cmo common.cmo vm.cmo karel.cmo
lexer.cmo: 	parser.cmi common.cmo
wparser.cmo: wparser.cmi karel.cmo
wlexer.cmo:	 wparser.cmi common.cmo
game.cmo: 	lexer.cmo parser.cmo common.cmo comp.cmo quad.cmo ui.cmo vm.cmo wparser.cmo wlexer.cmo
comp.cmo:	common.cmo quad.cmo
ui.cmo:		quad.cmo vm.cmo
karel.cmo:	vm.cmo quad.cmo
console.cmo:	common.cmo vm.cmo
asparser.cmo: 	asparser.cmi
asparser.cmo:	quad.cmo common.cmo karel.cmo comp.cmo
aslexer.cmo: 	asparser.cmi common.cmo
as.cmo:			common.cmo asparser.cmo aslexer.cmo
disasm.cmo:		common.cmo quad.cmo comp.cmo
run.cmo:		common.cmo quad.cmo vm.cmo karel.cmo wparser.cmo wlexer.cmo vector.cmo ui.cmo comp.cmo
exec.cmo:		common.cmo quad.cmo vm.cmo karel.cmo wparser.cmo wlexer.cmo comp.cmo


# templates
%.cmo: %.ml
	$(OCAMLC) -c $< -o $@

%.cmi: %.mli
	$(OCAMLC) -c $< -o $@

%.ml %.mli: %.mly
	$(OCAMLYACC) -v --strict $<

%.ml: %.mll
	$(OCAMLLEX) $< -o $@


# distribution
DIST = \
	$(AS_SOURCES) \
	$(DISASM_SOURCES) \
	$(CC_SOURCES) \
	$(RUN_SOURCES) \
	$(EXEC_SOURCES) \
	Makefile \
	karel.txt
SAMPLES = \
	$(wildcard samples/*.karel) \
	$(wildcard samples/*.wld)
ASMS = $(wildcard asm/*.s)
ARC=karel

copy:
	-rm -rf $(ARC)
	mkdir $(ARC)
	cp $(sort $(DIST)) $(ARC)
	mkdir $(ARC)/samples
	cp $(SAMPLES) $(ARC)/samples
	mkdir $(ARC)/asm
	cp $(ASMS) $(ARC)/asm

dist: copy
	./clean.py < parser.mly > $(ARC)/parser.mly
	./clean.py < lexer.mll > $(ARC)/lexer.mll
	tar cvfz $(ARC).tgz $(ARC)
	cd karel; make

complete: copy
	./complete.py < parser.mly > $(ARC)/parser.mly
	./complete.py < lexer.mll > $(ARC)/lexer.mll
	tar cvfz $(ARC)-complete.tgz $(ARC)
	cd karel; make


# save and restore
SAVE=$(HOME)/.karel
TO_SAVE=lexer.mll parser.mly

save:
	@test -d $(SAVE) || mkdir $(SAVE)
	@cp $(TO_SAVE) $(SAVE)
	@touch "$(SAVE)/Do not modify this!"
	@echo "Save done!"

restore:
	@test -d $(SAVE) || (echo "No save found!"; exit 1)
	@cp $(patsubst %,$(SAVE)/%,$(TO_SAVE)) .
	@echo "Restore done!"
 

# deliver generation
DELIVER_NAME = deliver-$(shell date "+%Y.%m.%d")
DELIVER_FILES = $(sort $(DIST) $(SAMPLES) $(ASMS))
deliver:
	tar cvfz $(DELIVER_NAME).tgz $(DELIVER_FILES)

