# LLVM Pass example
LLVM IR traces. Top most executed instructions during program runtime

## Usage:
```
clang++ Pass_cfg.cpp -c -fPIC -I`llvm-config --includedir` -o Pass.o
clang++ Pass.o -fPIC -shared -o libPass.so
clang ../SDL/app.c -c -o app.o -Xclang -load -Xclang ./libPass.so -O2
clang ../SDL/lib/sim.c log.c app.o -o IR_traces -lSDL2
```

#### For most recent versions of clang you might need to add `-flegacy-pass-manager`:
```
clang ../SDL/app.c -c -o app.o -Xclang -load -Xclang ./libPass.so -O2 -flegacy-pass-manager
```

#### If the compiler does not see `begin_code.h` file (as it was for me), you can try:
```
clang ../SDL/lib/sim.c log.c app.o -o IR_traces -lSDL2 -I/usr/include/SDL2
```


#### Staitistics


##### O1:
![10 most frequent instructions](Traces/O1/freq_1.png)
![10 most frequent pairs of instructions](Traces/O1/freq_2.png)
![10 most frequent triplets of instructions](Traces/O1/freq_3.png)
![10 most frequent quadruples of instructions](Traces/O1/freq_4.png)
![10 most frequent quintets of instructions](Traces/O1/freq_5.png)


##### O2:
![10 most frequent instructions](Traces/O2/freq_1.png)
![10 most frequent pairs of instructions](Traces/O2/freq_2.png)
![10 most frequent triplets of instructions](Traces/O2/freq_3.png)
![10 most frequent quadruples of instructions](Traces/O2/freq_4.png)
![10 most frequent quintets of instructions](Traces/O2/freq_5.png)


##### O3:
![10 most frequent instructions](Traces/O3/freq_1.png)
![10 most frequent pairs of instructions](Traces/O3/freq_2.png)
![10 most frequent triplets of instructions](Traces/O3/freq_3.png)
![10 most frequent quadruples of instructions](Traces/O3/freq_4.png)
![10 most frequent quintets of instructions](Traces/O3/freq_5.png)
