AFLAGS := -fsanitize=undefined -fno-omit-frame-pointer

ifeq ($(CC),clang)
	AFLAGS += -fsanitize=nullability
else
ifeq ($(CXX),clang++)
	AFLAGS += -fsanitize=nullability
else
endif
endif

ifeq ($(MEMORY),1)
	AFLAGS += -fsanitize=memory -fPIE -pie -fsanitize-memory-track-origins
else
ifeq ($(ASAN),1)
	AFLAGS += -fsanitize=address -fsanitize-address-use-after-scope
endif
endif

VGFLAGS := -s --leak-check=full --show-leak-kinds=all --track-origins=yes

BUILD_DIR := build

BUILD_MODE_PATH = $(BUILD_DIR)/$(BUILD_NAME)

ifeq ($(BUILD_MODE),RELEASE)
	CPPFLAGS   += -DNDEBUG
	CXXFLAGS   += -march=native -Ofast -s
	CFLAGS     += -march=native -Ofast -s
	BUILD_NAME := release
else
	BUILD_NAME := debug
	CXXFLAGS   += -g3 -ggdb -O0
	CFLAGS     += -g3 -ggdb -O0
	WFLAGS += -Wno-unused-parameter -Wno-unused-local-typedefs
ifeq ($(ASAN),1)
	export ASAN_OPTIONS := strict_string_checks=1:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1
	LDFLAGS  += $(AFLAGS)
	CXXFLAGS += $(AFLAGS)
	CFLAGS += $(AFLAGS)
	BUILD_NAME := $(BUILD_NAME)_asan
else
ifeq ($(MEMORY),1)
	LDFLAGS  += $(AFLAGS)
	CXXFLAGS += $(AFLAGS)
	CFLAGS += $(AFLAGS)
	BUILD_NAME := $(BUILD_NAME)_msan
endif
endif
endif

export CXXFLAGS
export CPPFLAGS
export CFLAGS
export LDFLAGS
export WFLAGS
export OBJ_DIR    := $(BUILD_MODE_PATH)/obj
export BUILD_PATH := $(BUILD_MODE_PATH)
export ROOT_PATH  := $(BUILD_DIR)

EXEC_FILE := $(BUILD_MODE_PATH)/$(EXEC_NAME)

EXEC_PID = $(shell pidof $(EXEC_FILE))

.PHONY: all info clean cleanall

all:
	$(MAKE) -f Makefile.gen all

lib:
	$(MAKE) -f Makefile.gen lib

run: all
ifeq ($(VALGRIND),1)
ifeq ($(ASAN),1)
	$(error "valgrind can't run with asan")
else
	valgrind $(VGFLAGS) $(EXEC_FILE)
endif
else
	$(EXEC_FILE)
endif

run_cgdb: all
ifeq ($(VALGRIND),1)
	valgrind $(VGFLAGS) --vgdb=yes --vgdb-error=0 $(EXEC_FILE)
else
	cgdb $(EXEC_FILE)
endif

info:
	$(info [INFO] CXXFLAGS  : $(CXXFLAGS))
	$(info [INFO] CFLAGS    : $(CFLAGS))
	$(info [INFO] LDFLAGS   : $(LDFLAGS))
	$(info [INFO] LDLIBS    : $(LDLIBS))
	$(info [INFO] CPPFLAGS  : $(CPPFLAGS))
	$(info [INFO] ASAN      : $(ASAN))
	$(info [INFO] AFLAGS    : $(AFLAGS))
	$(info [INFO] VALGRIND  : $(VALGRIND))
	$(info [INFO] VGFLAGS   : $(VGFLAGS))
	$(info [INFO] BUILD_NAME: $(BUILD_NAME))
	$(info )
	$(info =====SUB MAKE INFO=====)
	$(info )
	$(MAKE) -s -f Makefile.gen info

clean:
	$(MAKE) -f Makefile.gen clean

cleanall:
	$(MAKE) -f Makefile.gen cleanall
