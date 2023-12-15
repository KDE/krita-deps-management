cmake_minimum_required(VERSION 3.23)
#project (setuptools-launcher LANGUAGES C)

add_executable(setuptools-launcher launcher.c)
target_compile_definitions(setuptools-launcher PRIVATE "GUI=0")
set_target_properties(setuptools-launcher PROPERTIES EXCLUDE_FROM_ALL TRUE)
