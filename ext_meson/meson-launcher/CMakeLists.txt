cmake_minimum_required(VERSION 3.23)
project (meson-launcher LANGUAGES C)

add_executable(meson launcher.c)
target_compile_definitions(meson PRIVATE "GUI=0")
install(TARGETS meson RUNTIME)