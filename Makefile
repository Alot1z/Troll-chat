APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp settings
LLAMA_DIR := llama
LLAMA_LIB := $(LLAMA_DIR)/build/libllama.a
LLAMA_OBJ := llama.o

# Compile flags — include llama root and ggml/src for ggml.h
CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_DIR) \
          -I$(LLAMA_DIR)/ggml/src

# Link flags — frameworks + static lib
LDFLAGS := -framework Foundation \
           -framework UIKit \
           -lobjc \
           -L$(LLAMA_DIR)/build -lllama

.PHONY: all clean

all: src/$(APP_NAME)

# Build final binary
src/$(APP_NAME): $(OBJ) $(LLAMA_LIB)
	# extract just llama.o from the static library
	ar -x $(LLAMA_LIB) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $< $(LLAMA_OBJ) -o src/$(APP_NAME) $(LDFLAGS)

# Compile your main.m
src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

# Build llama.lib via CMake
$(LLAMA_LIB):
	mkdir -p $(LLAMA_DIR)/build
	cd $(LLAMA_DIR)/build && \
	  cmake -DCMAKE_BUILD_TYPE=Release .. && \
	  make -j$(sysctl -n hw.ncpu)

clean:
	rm -f src/*.o $(LLAMA_OBJ) src/$(APP_NAME)
	rm -rf $(LLAMA_DIR)/build
