NAME := template

INCS := include

LDFLAGS :=
LDLIBS := -lmlx

OS = $(shell uname)

ifeq ($(OS), Linux)
	MLX_DIR := libs/minilibx-linux
	LDFLAGS += -L$(MLX_DIR) -L/usr/bin/lib/
	LDLIBS += -lXext -lX11 -lm
else
	MLX_DIR := libs/minilibx-macos
	LDFLAGS += -L$(MLX_DIR)
	LDLIBS += -framework OpenGL -framework AppKit
endif

SRC_DIR := src
BUILD_DIR := .build

SRCS := main.c

OBJS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

CC := gcc
CFLAGS := -Wall -Werror -Wextra
CPPFLAGS := $(addprefix -I, $(INCS)) -MMD -MP

RM := rm -rf

all: $(NAME)

debug: CFLAGS += -g -DDEBUG
debug: all

address: CFLAGS += -fsanitize=address -g
address: re

thread: CFLAGS += -fsanitize=thread -g
thread: re

$(NAME): $(BUILD_DIR) $(OBJS)
	@make -sC $(MLX_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(OBJS) -o $(NAME) $(LDFLAGS) $(LDLIBS)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	@make -sC $(MLX_DIR) clean
	$(RM) $(BUILD_DIR)

fclean: clean
	$(RM) $(NAME)

re: fclean all

-include $(DEPS)

.PHONY: all clean fclean re debug address thread
