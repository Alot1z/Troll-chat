# Makefile for TrollChat iOS app including llama.cpp build, compile, package and sign

# App settings
APP_NAME := TrollChat
SRC      := src/main.m
OBJ      := src/main.o
BIN      := src/$(APP_NAME)

# Compiler and SDK settings
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp build settings
LLAMA_DIR   := llama
LLAMA_BUILD := $(LLAMA_DIR)/build
LLAMA_BIN   := $(LLAMA_BUILD)/bin/llama

# Entitlements and signing
ENTITLEMENTS := entitlements.plist
SIGN_TOOL   := ldid

# Output IPA
IPA_NAME := $(APP_NAME).ipa
PAYLOAD_DIR := Payload/$(APP_NAME).app

# Build llama.cpp using CMake
$(LLAMA_BIN):
	@echo "Building llama.cpp..."
	mkdir -p $(LLAMA_BUILD)
	cd $(LLAMA_BUILD) && cmake .. && cmake --build . --target llama -j$$(sysctl -n hw.ncpu)

# Compiler flags for iOS ARM64 target
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

.PHONY: all clean package sign

all: $(BIN)

# Link app binary, depends on object file and llama binary
$(BIN): $(OBJ) $(LLAMA_BIN)
	@echo "Linking binary $(BIN)..."
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

# Compile main.m to object file
$(OBJ): $(SRC)
	@echo "Compiling source $< ..."
	$(CC) $(CFLAGS) -c $< -o $@

# Clean all build files
clean:
	rm -f src/*.o $(BIN)
	rm -rf $(LLAMA_BUILD) $(PAYLOAD_DIR) $(IPA_NAME)

# Package .ipa with Payload structure
package: all
	@echo "Packaging .ipa..."
	rm -rf $(PAYLOAD_DIR)
	mkdir -p $(PAYLOAD_DIR)

	# Copy binary and resources (add more as needed)
	cp $(BIN) $(PAYLOAD_DIR)/$(APP_NAME)
	cp Info.plist $(PAYLOAD_DIR)/Info.plist

	# Optional: Copy assets, frameworks, resources here if needed
	# cp -R Resources $(PAYLOAD_DIR)/Resources

	# Sign the executable
	$(MAKE) sign

	# Zip Payload to IPA
	zip -qr $(IPA_NAME) Payload
	@echo "Created $(IPA_NAME)"

# Sign the binary with entitlements using ldid
sign:
	@echo "Signing binary with $(SIGN_TOOL)..."
	$(SIGN_TOOL) -S$(ENTITLEMENTS) $(PAYLOAD_DIR)/$(APP_NAME)

