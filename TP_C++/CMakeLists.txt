project("TP_C++")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS
"${CMAKE_CXX_FLAGS}
-Wall -Werror -g -ggdb")
add_executable(tp_cpp
src/main.cpp
src/ETokenType.h
src/Lexer.cpp
src/Lexer.h
)
