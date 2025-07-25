# App settings
APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
BIN      := src/$(APP_NAME)

# Compiler settings
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp settings
LLAMA_DIR := llama
LLAMA_BUILD := $(LLAMA_DIR)/build
LLAMA_BIN := $(LLAMA_BUILD)/bin/llama

# CMake build rule
$(LLAMA_BIN):
	mkdir -p $(LLAMA_BUILD)
	cd $(LLAMA_BUILD) && cmake .. && cmake --build . --target llama -j$$(sysctl -n hw.ncpu)

# Flags
CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_DIR)/ \
          -I$(LLAMA_DIR)/ggml/include \
          -I$(LLAMA_DIR)/ggml/src \
          -I$(LLAMA_DIR)/common

LDFLAGS := -framework Foundation \
           -framework UIKit \
           -lobjc

# Build rules
.PHONY: all clean

all: $(BIN)

$(BIN): $(OBJ) $(LLAMA_BIN)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f src/*.o $(BIN)
	rm -rf $(LLAMA_BUILD)
