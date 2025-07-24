# ─────────────────────────────────────────────────────────────────────────────
APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp
LLAMA_DIR := llama
LLAMA_SRC := $(LLAMA_DIR)/llama.cpp
LLAMA_OBJ := $(LLAMA_DIR)/llama.o
LLAMA_HDR := $(LLAMA_DIR)

# compile only flags (no frameworks or link flags here)
CFLAGS   := -target arm64-apple-ios11.0 \
             -isysroot $(IOS_SDK) \
             -fobjc-arc \
             -I$(LLAMA_HDR)

# link only flags (frameworks, etc.)
LDFLAGS  := -framework Foundation \
             -framework UIKit \
             -lobjc

# ─────────────────────────────────────────────────────────────────────────────
.PHONY: all clean

all: src/$(APP_NAME)

# final binary
src/$(APP_NAME): $(OBJ) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# compile main.m
src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

# compile llama.cpp
$(LLAMA_OBJ): $(LLAMA_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f src/*.o $(LLAMA_OBJ) src/$(APP_NAME)
