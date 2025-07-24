APP_NAME = trollchat
SRC = src/main.m
OBJ = $(SRC:.m=.o)
CC = clang
IOS_SDK = $(shell xcrun --sdk iphoneos --show-sdk-path)

# llama.cpp opsætning
LLAMA_DIR = llama
LLAMA_SRC = $(LLAMA_DIR)/llama.cpp
LLAMA_OBJ = $(LLAMA_DIR)/llama.o
LLAMA_HDR = $(LLAMA_DIR)

CFLAGS = -target arm64-apple-ios11.0 -isysroot $(IOS_SDK) -fobjc-arc -I$(LLAMA_HDR) -framework Foundation -framework UIKit
LDFLAGS = -lobjc

all: $(APP_NAME)

$(APP_NAME): $(OBJ) $(LLAMA_OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LLAMA_OBJ) -o src/$(APP_NAME) $(LDFLAGS)

# Kompilér llama.cpp
$(LLAMA_OBJ): $(LLAMA_SRC)
	$(CC) $(CFLAGS) -c $(LLAMA_SRC) -o $(LLAMA_OBJ)

# Kompilér main.m
%.o: %.m
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(LLAMA_OBJ) src/$(APP_NAME)
