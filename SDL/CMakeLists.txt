cmake_minimum_required(VERSION 3.11)

project(Free-Star VERSION 1.0)

set(LINK_OPT -lSDL2)
set(CMAKE_C_COMPILER "clang")

include_directories(lib)
include_directories(/usr/include/SDL2)

file(GLOB SRCS ./*.c ./lib/*.c)

add_executable(FreeStar.exe ${SRCS})

target_link_libraries(FreeStar.exe PUBLIC ${LINK_OPT})