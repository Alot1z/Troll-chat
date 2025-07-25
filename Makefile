APP_NAME := trollchat
SRC      := src/main.m
OBJ      := src/main.o
CC       := clang
IOS_SDK  := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp opsætning
LLAMA_DIR := llama
LLAMA_LIB := $(LLAMA_DIR)/build/libllama.a
LLAMA_OBJ := $(LLAMA_DIR)/build/CMakeFiles/llama.dir/llama.o

CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_DIR)/ \
          -I$(LLAMA_DIR)/ggml/include \
          -I$(LLAMA_DIR)/ggml/src

LDFLAGS := -framework Foundation \
           -framework UIKit \
           -lobjc \
           $(LLAMA_LIB)

.PHONY: all clean

all: src/$(APP_NAME)

src/$(APP_NAME): $(OBJ) $(LLAMA_LIB)
	$(CC) $(CFLAGS) $< $(LLAMA_OBJ) -o $@ $(LDFLAGS)

src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

$(LLAMA_LIB):
	cd $(LLAMA_DIR) && mkdir -p build && cd build && cmake .. && make -j$(shell sysctl -n hw.ncpu)

clean:
	rm -f src/*.o src/$(APP_NAME)
	rm -rf $(LLAMA_DIR)/build
