# LLVM IR Generation
Generating IR for SDL graphical sample and executing it using Execution Engine

## Usage:
```
clang++ `llvm-config --cppflags --ldflags --libs` app_ir_gen.cpp -lSDL2
```

## Again, if the compiler does not see `begin_code.h` file (as it was for me), you can try:
```
clang++ `llvm-config --cppflags --ldflags --libs` app_ir_gen.cpp -lSDL2 -I/usr/include/SDL2
```

## Now run:
```
./a.out
```

## Dump generated IR:
```
./a.out > app_ir_gen.ll
```

## You can `diff` with compiler created file:
```
diff -I -W --width=200 --minimal --color -y app_ir_gen.ll ../SDL/app.ll
``` 