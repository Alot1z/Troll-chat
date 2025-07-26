# Makefile for TrollChat iOS app using llama.cpp

APP_NAME := TrollChat
SRC := src/main.m
OBJ := src/main.o
BIN := src/$(APP_NAME)

CC := clang
IOS_SDK := $(shell xcrun --sdk iphoneos --show-sdk-path)

LLAMA_DIR := llama
LLAMA_BUILD := $(LLAMA_DIR)/build
LLAMA_BIN := $(LLAMA_BUILD)/bin/llama

ENTITLEMENTS := entitlements.plist
SIGN_TOOL := ldid

IPA_NAME := $(APP_NAME).ipa
PAYLOAD_DIR := Payload/$(APP_NAME).app

CFLAGS := -target arm64-apple-ios11.0 \
  -isysroot $(IOS_SDK) \
  -fobjc-arc \
  -I$(LLAMA_DIR)/ \
  -I$(LLAMA_DIR)/ggml/include \
  -I$(LLAMA_DIR)/ggml/src \
  -I$(LLAMA_DIR)/common

LDFLAGS := -framework Foundation -framework UIKit -lobjc

.PHONY: all clean package sign

all: $(BIN)

$(LLAMA_BIN):
	mkdir -p $(LLAMA_BUILD)
	cd $(LLAMA_BUILD) && cmake .. && cmake --build . --target llama -j$$(sysctl -n hw.ncpu)

$(BIN): $(OBJ) $(LLAMA_BIN)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f src/*.o $(BIN)
	rm -rf $(LLAMA_BUILD) $(PAYLOAD_DIR) $(IPA_NAME)

package: all sign
	rm -rf $(PAYLOAD_DIR)
	mkdir -p $(PAYLOAD_DIR)
	cp $(BIN) $(PAYLOAD_DIR)/$(APP_NAME)
	cp Info.plist $(PAYLOAD_DIR)/Info.plist
	zip -qr $(IPA_NAME) Payload

sign:
	$(SIGN_TOOL) -S$(ENTITLEMENTS) $(PAYLOAD_DIR)/$(APP_NAME)
