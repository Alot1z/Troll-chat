APP_NAME  := trollchat
SRC       := src/main.m
OBJ       := $(SRC:.m=.o)
CC        := clang
IOS_SDK   := $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp konfiguration
LLAMA_DIR  := llama
LLAMA_INC  := $(LLAMA_DIR)/include
LLAMA_GGML := $(LLAMA_DIR)/ggml/src
LLAMA_LIB  := $(LLAMA_DIR)/build/libllama.a

CFLAGS := -target arm64-apple-ios11.0 \
          -isysroot $(IOS_SDK) \
          -fobjc-arc \
          -I$(LLAMA_INC) \
          -I$(LLAMA_GGML)

LDFLAGS := -L$(LLAMA_DIR)/build \
           -llama \
           -framework Foundation \
           -framework UIKit \
           -lobjc

.PHONY: all clean

all: src/$(APP_NAME)

src/$(APP_NAME): $(OBJ) $(LLAMA_LIB)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

$(LLAMA_LIB):
	cd $(LLAMA_DIR) && mkdir -p build && cd build && cmake .. && make -j$(shell sysctl -n hw.ncpu)

clean:
	rm -f src/*.o src/$(APP_NAME)
	rm -rf $(LLAMA_DIR)/build
