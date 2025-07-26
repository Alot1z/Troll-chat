# App settings
APP_NAME := TrollChat
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
.PHONY: all clean package

all: $(BIN)

$(BIN): $(OBJ) $(LLAMA_BIN)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(LLAMA_BIN):
	mkdir -p $(LLAMA_BUILD)
	cd $(LLAMA_BUILD) && cmake .. && cmake --build . --target llama -j$$(sysctl -n hw.ncpu)

package: all
	mkdir -p Payload/$(APP_NAME).app
	cp $(BIN) Payload/$(APP_NAME).app/$(APP_NAME)
	cp Info.plist Payload/$(APP_NAME).app/Info.plist
	cp entitlements.plist Payload/$(APP_NAME).app/entitlements.plist
	ldid -S Payload/$(APP_NAME).app/entitlements.plist Payload/$(APP_NAME).app/$(APP_NAME)
	zip -r $(APP_NAME).ipa Payload

clean:
	rm -f src/*.o $(BIN)
	rm -rf $(LLAMA_BUILD) Payload $(APP_NAME).ipa
