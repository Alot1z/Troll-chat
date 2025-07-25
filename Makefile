APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp directory and build
LLAMA_DIR := llama
LLAMA_LIB := $(LLAMA_DIR)/build/libllama.a
LLAMA_OBJ := llama.o

# Compilation flags with precise include dirs
CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_DIR)/include \
          -I$(LLAMA_DIR)/ggml/src

# Link flags
LDFLAGS := -framework Foundation \
           -framework UIKit \
           -lobjc \
           -L$(LLAMA_DIR)/build -lllama

.PHONY: all clean

all: src/$(APP_NAME)

src/$(APP_NAME): $(OBJ) $(LLAMA_LIB)
	# extract llama.o and then link
	ar -x $(LLAMA_LIB) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $< $(LLAMA_OBJ) -o src/$(APP_NAME) $(LDFLAGS)

src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

# Build llama.cpp using CMake
$(LLAMA_LIB):
	mkdir -p $(LLAMA_DIR)/build
	cd $(LLAMA_DIR)/build && \
	  cmake -DCMAKE_BUILD_TYPE=Release .. && \
	  make -j$(sysctl -n hw.ncpu)

clean:
	rm -f src/*.o $(LLAMA_OBJ) src/$(APP_NAME)
	rm -rf $(LLAMA_DIR)/build
