
PROJNAME = calcasm

ASSEMBLER = as
LINKER = ld

SOURCES = calcasm.s math.s write-output.s parse-input.s
OBJECTS = $(patsubst %.s, %.o, $(SOURCES))


all: $(PROJNAME)

$(PROJNAME): $(OBJECTS)
	$(LINKER) $(OBJECTS) -o $(PROJNAME)

clean:
	$(RM) $(OBJECTS) $(PROJNAME)

test:
	@echo "SOURCES = ${SOURCES}"
	@echo "OBJECTS = ${OBJECTS}"
	@echo "EXECUTABLE = ${PROJNAME}"
