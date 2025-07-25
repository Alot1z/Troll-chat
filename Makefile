APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp opsætning
LLAMA_DIR := llama
LLAMA_LIB := $(LLAMA_DIR)/libllama.a
LLAMA_OBJ := llama.o

# Compile-flags: include llama/include, ggml/include og ggml/src
CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_DIR)/include \       # llama.h
          -I$(LLAMA_DIR)/ggml/include \  # ggml.h
          -I$(LLAMA_DIR)/ggml/src         # interne ggml-headers (implementation)

# Link-flags
LDFLAGS := -framework Foundation \
           -framework UIKit \
           -lobjc \
           -L$(LLAMA_DIR) -lllama

.PHONY: all clean

all: src/$(APP_NAME)

src/$(APP_NAME): $(OBJ) $(LLAMA_LIB)
	# Extract llama.o from libllama.a and link
	ar -x $(LLAMA_LIB) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $< $(LLAMA_OBJ) -o src/$(APP_NAME) $(LDFLAGS)

src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

# Build llama.cpp library via llama's own Makefile
$(LLAMA_LIB):
	cd $(LLAMA_DIR) && make -j$(shell sysctl -n hw.ncpu)

clean:
	rm -f src/*.o $(LLAMA_OBJ) src/$(APP_NAME)
	rm -rf $(LLAMA_DIR)/libllama.a
