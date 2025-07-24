APP_NAME = trollchat
SRC = src/main.m
OBJ = $(SRC:.m=.o)
CC = clang
CFLAGS = -target arm64-apple-ios11.0 -isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) -fobjc-arc -framework Foundation -framework UIKit -Isrc/llama
LDFLAGS = -lobjc -Lsrc/llama/build -lllama

all: $(APP_NAME)

$(APP_NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o src/$(APP_NAME) $(LDFLAGS)

clean:
	rm -f *.o src/$(APP_NAME)
