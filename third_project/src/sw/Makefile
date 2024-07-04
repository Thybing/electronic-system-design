RISCV_ARCH := rv32i
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
VPATH = $(SRC_DIR)

$(shell if[! -e $(BIN_DIR)];then mkdir -p $(BIN_DIR); fi)
TARGET = ex_app

C_SRCS := \
	main.c \
	uart.c \
	xprintf.c \
	trap_handler.c

include Makefile.common

