APP_NAME = trollchat
SRC = src/main.m
OBJ = src/main.o
CC = clang
IOS_SDK = $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp opsætning
LLAMA_DIR = llama
LLAMA_SRC = $(LLAMA_DIR)/llama.cpp
LLAMA_OBJ = $(LLAMA_DIR)/llama.o
LLAMA_HDR = $(LLAMA_DIR)

# Compile-flags (kun til .m og .cpp)
CFLAGS = -target arm64-apple-ios11.0 -isysroot $(IOS_SDK) -fobjc-arc -I$(LLAMA_HDR)

# Link-flags (kun til binær)
LDFLAGS = -framework Foundation -framework UIKit -lobjc

all: src/$(APP_NAME)

src/$(APP_NAME): $(OBJ) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

# Kompilér main.m
src/main.o: src/main.m
	$(CC) $(CFLAGS) -c $< -o $@

# Kompilér llama.cpp
$(LLAMA_OBJ): $(LLAMA_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(LLAMA_OBJ) src/$(APP_NAME)
