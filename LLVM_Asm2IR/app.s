app
    ALLOCA x15 5000
    ALLOCA x0 5000
    CALL initCells
    FLUSH
    JMP app_loop

app_loop
    CALL updatePixels
    FLUSH
    JMP app_loop

app_exit
    RET



makeColor
    MVI x3 255
    ANDI x4 x3 255
    SLI x5 x4 24
    ANDI x4 x0 255
    SLI x6 x4 16
    OR x5 x5 x6
    ANDI x4 x1 255
    SLI x6 x4 8
    OR x5 x5 x6
    ANDI x4 x2 255
    OR x5 x5 x4
    MV x0 x5
    RET



paintCellPixels
    MULI x3 x0 16
    ADDI x3 x3 1
    MULI x4 x1 16
    ADDI x4 x4 1
    ADDI x5 x3 14
    ADDI x6 x4 14
    MV x7 x4
    JMP PCP_outer_loop_in

PCP_outer_loop_in
    ICMPGE x8 x7 x6
    CONDBR x8 PCP_exit PCP_draw

PCP_draw
    MV x0 x3
    MV x1 x7
    PUT_PIXELS_14
    ADDI x7 x7 1
    JMP PCP_outer_loop_in

PCP_exit
    RET



initCells
    MVI x1 0
    MVI x2 50
    JMP IC_outer_loop_in

IC_outer_loop_in
    ICMPGE x3 x1 x2
    CONDBR x3 IC_exit IC_outer_loop_body

IC_outer_loop_body
    MVI x4 0
    MVI x5 50
    JMP IC_inner_loop_in

IC_inner_loop_in
    ICMPGE x6 x4 x5
    CONDBR x6 IC_outer_loop_out IC_inner_loop_body

IC_inner_loop_body
    RAND x7
    REMI x7 x7 31
    MVI x8 0
    ICMPNE x9 x8 x7 
    CONDBR x9 IC_inner_loop_out IC_if_body

IC_if_body
    MULI x7 x1 50
    ADD x7 x4 x7
    MULI x7 x7 2
    MVI x8 1
    STORE x8 x0 x7
    ADDI x7 x7 1
    STORE x8 x0 x7
    MV x14 x0
    MV x13 x1
    MV x12 x2
    MV x11 x4
    MV x10 x5
    MVI x0 0
    MVI x1 255
    MVI x2 0
    CALL makeColor
    MV x2 x0
    MV x0 x11
    MV x1 x13
    CALL paintCellPixels
    MV x0 x14
    MV x1 x13
    MV x2 x12
    MV x4 x11
    MV x5 x10
    JMP IC_inner_loop_out

IC_inner_loop_out
    ADDI x4 x4 1
    JMP IC_inner_loop_in

IC_outer_loop_out
    ADDI x1 x1 1
    JMP IC_outer_loop_in

IC_exit
    RET



updatePixels
    MVI x1 0
    MVI x2 50
    JMP UP_outer_loop1_in

UP_outer_loop1_in
    ICMPGE x3 x1 x2
    CONDBR x3 UP_outer_loop2 UP_outer_loop1_body

UP_outer_loop1_body
    MVI x3 0
    MVI x4 50
    JMP UP_inner_loop1_in

UP_inner_loop1_in
    ICMPGE x5 x3 x4
    CONDBR x5 UP_outer_loop1_inc UP_inner_loop1_body

UP_inner_loop1_body
    ADDI x5 x3 49
    REMI x5 x5 50
    REMI x6 x3 50
    ADDI x7 x3 1
    REMI x7 x7 50
    ADDI x8 x1 49
    REMI x8 x8 50
    REMI x9 x1 50
    ADDI x10 x1 1
    REMI x10 x10 50
    MVI x11 0
    MVI x12 1
    MV x13 x8
    MULI x13 x13 50
    ADD x13 x13 x5
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_1 UP_neigh_0_inc

UP_neigh_0_inc
    ADDI x11 x11 1
    JMP UP_neigh_1

UP_neigh_1
    MV x13 x9
    MULI x13 x13 50
    ADD x13 x13 x5
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_2 UP_neigh_1_inc

UP_neigh_1_inc
    ADDI x11 x11 1
    JMP UP_neigh_2

UP_neigh_2
    MV x13 x10
    MULI x13 x13 50
    ADD x13 x13 x5
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_3 UP_neigh_2_inc

UP_neigh_2_inc
    ADDI x11 x11 1
    JMP UP_neigh_3

UP_neigh_3
    MV x13 x8
    MULI x13 x13 50
    ADD x13 x13 x6
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_4 UP_neigh_3_inc

UP_neigh_3_inc
    ADDI x11 x11 1
    JMP UP_neigh_4

UP_neigh_4
    MV x13 x10
    MULI x13 x13 50
    ADD x13 x13 x6
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_5 UP_neigh_4_inc

UP_neigh_4_inc
    ADDI x11 x11 1
    JMP UP_neigh_5

UP_neigh_5
    MV x13 x8
    MULI x13 x13 50
    ADD x13 x13 x7
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_6 UP_neigh_5_inc

UP_neigh_5_inc
    ADDI x11 x11 1
    JMP UP_neigh_6

UP_neigh_6
    MV x13 x9
    MULI x13 x13 50
    ADD x13 x13 x7
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_neigh_7 UP_neigh_6_inc

UP_neigh_6_inc
    ADDI x11 x11 1
    JMP UP_neigh_7

UP_neigh_7
    MV x13 x10
    MULI x13 x13 50
    ADD x13 x13 x7
    MULI x13 x13 2
    LOAD x13 x0 x13
    ICMPNE x14 x12 x13
    CONDBR x14 UP_cell_status UP_neigh_7_inc

UP_neigh_7_inc
    ADDI x11 x11 1
    JMP UP_cell_status

UP_cell_status
    MV x5 x1
    MULI x5 x5 50
    ADD x5 x5 x3
    MULI x5 x5 2
    LOAD x6 x0 x5
    ICMPNE x7 x6 x12
    CONDBR x7 UP_status_else UP_status_if_0

UP_status_if_0
    MVI x8 0
    ICMPNE x9 x11 x8
    CONDBR x9 UP_status_if_3 UP_status_if_if

UP_status_if_3
    MVI x8 3
    ICMPNE x9 x11 x8
    CONDBR x9 UP_status_if_4 UP_status_if_if

UP_status_if_4
    MVI x8 4
    ICMPNE x9 x11 x8
    CONDBR x9 UP_status_if_5 UP_status_if_if

UP_status_if_5
    MVI x8 5
    ICMPNE x9 x11 x8
    CONDBR x9 UP_status_if_else UP_status_if_if

UP_status_if_if
    MV x6 x5
    MVI x7 1
    STORE x7 x15 x6
    ADDI x6 x6 1
    LOAD x7 x0 x6
    ADDI x7 x7 1
    STORE x7 x15 x6
    JMP UP_inner_loop1_inc

UP_status_if_else
    MV x6 x5
    MVI x7 0
    STORE x7 x15 x6
    ADDI x6 x6 1
    STORE x7 x15 x6
    JMP UP_inner_loop1_inc

UP_status_else
    MVI x8 2
    ICMPNE x9 x11 x8
    CONDBR x9 UP_status_else_else UP_status_else_if

UP_status_else_if
    MV x6 x5
    MVI x7 1
    STORE x7 x15 x6
    ADDI x6 x6 1
    STORE x7 x15 x6
    JMP UP_inner_loop1_inc

UP_status_else_else
    MV x6 x5
    MVI x7 0
    STORE x7 x15 x6
    ADDI x6 x6 1
    STORE x7 x15 x6
    JMP UP_inner_loop1_inc

UP_inner_loop1_inc
    ADDI x3 x3 1
    JMP UP_inner_loop1_in

UP_outer_loop1_inc
    ADDI x1 x1 1
    JMP UP_outer_loop1_in

UP_outer_loop2
    MVI x1 0
    MVI x2 50
    JMP UP_outer_loop2_in

UP_outer_loop2_in
    ICMPGE x3 x1 x2
    CONDBR x3 UP_outer_loop2_out UP_outer_loop2_body

UP_outer_loop2_body
    MVI x3 0
    MVI x4 50
    JMP UP_inner_loop2_in

UP_inner_loop2_in
    ICMPGE x5 x3 x4
    CONDBR x5 UP_inner_loop2_out UP_inner_loop2_body

UP_inner_loop2_body
    MV x5 x1
    MULI x5 x5 50
    ADD x5 x5 x3
    MULI x5 x5 2
    ADDI x6 x5 1
    LOAD x7 x15 x5
    STORE x7 x0 x5
    LOAD x7 x15 x6
    STORE x7 x0 x6
    MVI x8 10
    ICMPNE x9 x7 x8
    CONDBR x9 UP_color UP_max_gen

UP_max_gen
    MVI x8 0
    STORE x8 x0 x5
    STORE x8 x0 x6
    JMP UP_color

UP_color
    MVI x14 0
    LOAD x8 x0 x5
    MVI x9 1
    ICMPNE x10 x8 x9
    CONDBR x10 UP_draw UP_make_color

UP_make_color
    MVI x8 0
    MVI x9 0
    MVI x10 0
    MVI x11 6
    ICMPGE x12 x11 x7
    CONDBR x12 UP_after_r UP_make_r

UP_make_r
    MVI x11 10
    SUB x12 x11 x7
    MULI x12 x12 2
    MVI x8 127
    SUB x8 x8 x12
    JMP UP_after_r

UP_after_r
    MVI x11 5
    ICMPGE x12 x7 x11
    CONDBR x12 UP_after_g UP_make_g

UP_make_g
    MVI x11 255
    DIV x9 x11 x7
    JMP UP_after_g

UP_after_g
    MVI x11 5
    ICMPGE x12 x7 x11
    CONDBR x12 UP_make_b1 UP_after_b

UP_make_b1
    MVI x11 6
    ICMPGE x12 x11 x7
    CONDBR x12 UP_make_b UP_after_b

UP_make_b
    MVI x10 127
    JMP UP_after_b

UP_after_b
    MV x13 x0
    MV x0 x8
    MV x12 x1
    MV x1 x9
    MV x11 x2
    MV x2 x10
    MV x10 x3
    MV x9 x4
    CALL makeColor
    MV x14 x0
    MV x0 x13
    MV x1 x12
    MV x2 x11
    MV x3 x10
    MV x4 x9
    JMP UP_draw

UP_draw
    MV x13 x0
    MV x12 x1
    MV x11 x2
    MV x10 x3
    MV x9 x4
    MV x0 x3
    MV x2 x14
    CALL paintCellPixels
    MV x0 x13
    MV x1 x12
    MV x2 x11
    MV x3 x10
    MV x4 x9
    JMP UP_inner_loop2_inc

UP_inner_loop2_inc
    ADDI x3 x3 1
    JMP UP_inner_loop2_in

UP_inner_loop2_out
    ADDI x1 x1 1
    JMP UP_outer_loop2_in

UP_outer_loop2_out
    RET
