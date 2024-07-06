RISCV_ARCH := rv32i
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


SRC_DIR = src
BUILD_DIR = build
VPATH = $(SRC_DIR)

TARGET = digital_clock_final

C_SRCS := \
	main.c \
	uart.c \
	xprintf.c \
	trap_handler.c \
	seg_show.c \
	sec_clock.c \
	button.c \
	buzzer.c \
	ring.c \
	process_func.c

include Makefile.common

