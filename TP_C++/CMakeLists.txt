project("TP_C++")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS
"${CMAKE_CXX_FLAGS}
-Wall -Werror -g -ggdb")
add_executable(tp_cpp
src/main.cpp
src/truc.cpp
)
