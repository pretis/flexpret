# Override the variables and reuse the clients.mk makefile
CLIENT_DIR = .
CLIENT_BUILD_DIR = build

include clients.mk

.DEFAULT_GOAL = all

all: $(CLIENTS)

clean:
	rm -rf $(CLIENT_BUILD_DIR)