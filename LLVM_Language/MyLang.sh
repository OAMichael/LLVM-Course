bison -d MyLang.y
lex MyLang.lex
clang++ lex.yy.c MyLang.tab.c `llvm-config --cppflags --ldflags --libs` -lSDL2 -o MyLang -I/usr/include/SDL2
cat MyLang.txt
printf "\n"
cat MyLang.txt | ./MyLang