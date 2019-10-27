
PROJNAME = calcasm

ASSEMBLER = as
LINKER = ld

SOURCES = calcasm.s math.s write-output.s parse-input.s
OBJECTS = $(patsubst %.s, %.o, $(SOURCES))


all: $(PROJNAME)

$(PROJNAME): $(OBJECTS)
	$(LINKER) $(OBJECTS) -o $(PROJNAME)

%.o : %.s
	$(ASSEMBLER) $< -o $@

clean:
	$(RM) $(OBJECTS) $(PROJNAME)

info:
	@echo "SOURCES = ${SOURCES}"
	@echo "OBJECTS = ${OBJECTS}"
	@echo "EXECUTABLE = ${PROJNAME}"
