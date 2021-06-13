%macro testgroup 1
   mov al,[es:pageCounter]
   cmp al,%1
   jnz test%1end
%endmacro

testgroup 0
execute  1, 54, teststring1  , test_jumponly
execute  2, 58, teststring2  , test_jumponlyUnaligned
execute  3, 58, teststring3  , test_nop
execute  4, 62, teststring4  , test_nop2x
execute  5, 58, teststring5  , test_incbl
execute  6, 58, teststring6  , test_incbx
execute  7, 62, teststring7  , test_incbx2x
execute  8, 70, teststring8  , test_cli
execute  9, 82, teststring9  , test_in_al
execute 10, 74, teststring10 , test_in_aldx
execute 11, 58, teststring11 , test_sp_add2
execute 12, 58, teststring12 , test_sp_sub2
execute 13, 62, teststring13 , test_push
execute 14, 62, teststring14 , test_pop
execute 15, 58, teststring15 , test_movaxmem
execute 16, 58, teststring16 , test_movaxmemes
test0end:

testgroup 1
execute  1, 66, teststringx00, test_op00
execute  2, 66, teststringx01, test_op01
execute  3, 62, teststringx02, test_op02
execute  4, 62, teststringx03, test_op03
execute  5, 58, teststringx04, test_op04
execute  6, 58, teststringx05, test_op05
execute  7, 66, teststringx06, test_op06
execute  8, 70, teststringx07, test_op07
execute  9, 66, teststringx08, test_op08
execute 10, 66, teststringx09, test_op09
execute 11, 62, teststringx0A, test_op0A
execute 12, 62, teststringx0B, test_op0B
execute 13, 58, teststringx0C, test_op0C
execute 14, 58, teststringx0D, test_op0D
execute 15, 66, teststringx0E, test_op0E
execute 16,  0, teststringx0F, test_op0F
test1end:

testgroup 2
execute  1, 66, teststringx10, test_op10
execute  2, 66, teststringx11, test_op11
execute  3, 62, teststringx12, test_op12
execute  4, 62, teststringx13, test_op13
execute  5, 58, teststringx14, test_op14
execute  6, 58, teststringx15, test_op15
execute  7, 66, teststringx16, test_op16
execute  8, 70, teststringx17, test_op17
execute  9, 66, teststringx18, test_op18
execute 10, 66, teststringx19, test_op19
execute 11, 62, teststringx1A, test_op1A
execute 12, 62, teststringx1B, test_op1B
execute 13, 58, teststringx1C, test_op1C
execute 14, 58, teststringx1D, test_op1D
execute 15, 66, teststringx1E, test_op1E
execute 16, 70, teststringx1F, test_op1F
test2end:

testgroup 3
execute  1, 66, teststringx20, test_op20
execute  2, 66, teststringx21, test_op21
execute  3, 62, teststringx22, test_op22
execute  4, 62, teststringx23, test_op23
execute  5, 58, teststringx24, test_op24
execute  6, 58, teststringx25, test_op25
execute  7, 58, teststringx26, test_op26
execute  8, 93, teststringx27, test_op27
execute  9, 66, teststringx28, test_op28
execute 10, 66, teststringx29, test_op29
execute 11, 62, teststringx2A, test_op2A
execute 12, 62, teststringx2B, test_op2B
execute 13, 58, teststringx2C, test_op2C
execute 14, 58, teststringx2D, test_op2D
execute 15, 58, teststringx2E, test_op2E
execute 16, 97, teststringx2F, test_op2F
test3end:

testgroup 4
execute  1, 66, teststringx30, test_op30
execute  2, 66, teststringx31, test_op31
execute  3, 62, teststringx32, test_op32
execute  4, 62, teststringx33, test_op33
execute  5, 58, teststringx34, test_op34
execute  6, 58, teststringx35, test_op35
execute  7, 58, teststringx36, test_op36
execute  8, 90, teststringx37, test_op37
execute  9, 62, teststringx38, test_op38
execute 10, 62, teststringx39, test_op39
execute 11, 62, teststringx3A, test_op3A
execute 12, 62, teststringx3B, test_op3B
execute 13, 58, teststringx3C, test_op3C
execute 14, 58, teststringx3D, test_op3D
execute 15, 58, teststringx3E, test_op3E
execute 16, 90, teststringx3F, test_op3F
test4end:

testgroup 5
execute  1, 58, teststringx40, test_op40
execute  2,  0, teststringx41, test_op41
execute  3, 58, teststringx42, test_op42
execute  4, 58, teststringx43, test_op43
execute  5,  0, teststringx44, test_op44
execute  6, 58, teststringx45, test_op45
execute  7, 58, teststringx46, test_op46
execute  8, 58, teststringx47, test_op47
execute  9, 58, teststringx48, test_op48
execute 10,  0, teststringx49, test_op49
execute 11, 58, teststringx4A, test_op4A
execute 12, 58, teststringx4B, test_op4B
execute 13,  0, teststringx4C, test_op4C
execute 14, 58, teststringx4D, test_op4D
execute 15, 58, teststringx4E, test_op4E
execute 16, 58, teststringx4F, test_op4F
test5end:

testgroup 6
execute  1, 62, teststringx50, test_op50
execute  2, 62, teststringx51, test_op51
execute  3, 62, teststringx52, test_op52
execute  4, 62, teststringx53, test_op53
execute  5, 62, teststringx54, test_op54
execute  6, 62, teststringx55, test_op55
execute  7, 62, teststringx56, test_op56
execute  8, 62, teststringx57, test_op57
execute  9, 62, teststringx58, test_op58
execute 10,  0, teststringx59, test_op59
execute 11, 62, teststringx5A, test_op5A
execute 12, 62, teststringx5B, test_op5B
execute 13,  0, teststringx5C, test_op5C
execute 14, 62, teststringx5D, test_op5D
execute 15, 62, teststringx5E, test_op5E
execute 16, 62, teststringx5F, test_op5F
test6end:

testgroup 7
execute  1, 93, teststringx60, test_op60
execute  2,101, teststringx61, test_op61
execute  3, 62, teststringx68, test_op68
execute  4, 78, teststringx69, test_op69
execute  5, 62, teststringx6A, test_op6A
execute  6, 78, teststringx6B, test_op6B
test7end:

testgroup 8
execute  1, 66, teststringx80, test_op80
execute  2, 66, teststringx81, test_op81
execute  3, 66, teststringx82, test_op82
execute  4, 66, teststringx83, test_op83
execute  5, 62, teststringx84, test_op84
execute  6, 62, teststringx85, test_op85
execute  7, 74, teststringx86, test_op86
execute  8, 74, teststringx87, test_op87
execute  9, 58, teststringx88, test_op88
execute 10, 58, teststringx89, test_op89
execute 11, 58, teststringx8A, test_op8A
execute 12, 58, teststringx8B, test_op8B
execute 13, 58, teststringx8C, test_op8C
execute 14, 58, teststringx8D, test_op8D
execute 15, 66, teststringx8E, test_op8E
execute 16, 70, teststringx8F, test_op8F
test8end:

testgroup 9
execute  1, 58, teststringx90, test_op90
execute  2, 70, teststringx91, test_op91
execute  3, 66, teststringx92, test_op92
execute  4, 66, teststringx93, test_op93
execute  5, 70, teststringx94, test_op94
execute  6, 70, teststringx95, test_op95
execute  7, 70, teststringx96, test_op96
execute  8, 70, teststringx97, test_op97
execute  9, 58, teststringx98, test_op98
execute 10, 58, teststringx99, test_op99
execute 11, 66, teststringx9C, test_op9C
execute 12, 70, teststringx9D, test_op9D
execute 13, 70, teststringx9E, test_op9E
execute 14, 62, teststringx9F, test_op9F
test9end:

testgroup 10
execute  1, 58, teststringxA0, test_opA0
execute  2, 58, teststringxA1, test_opA1
execute  3, 58, teststringxA2, test_opA2
execute  4, 58, teststringxA3, test_opA3
execute  5, 74, teststringxA4, test_opA4
execute  6, 74, teststringxA5, test_opA5
execute  7, 78, teststringxA6, test_opA6
execute  8, 78, teststringxA7, test_opA7
execute  9, 58, teststringxA8, test_opA8
execute 10, 58, teststringxA9, test_opA9
execute 11, 66, teststringxAA, test_opAA
execute 12, 66, teststringxAB, test_opAB
execute 13, 66, teststringxAC, test_opAC
execute 14, 66, teststringxAD, test_opAD
execute 15, 70, teststringxAE, test_opAE
execute 16, 70, teststringxAF, test_opAF
test10end:

testgroup 11
execute  1, 58, teststringxB0, test_opB0
execute  2,  0, teststringxB1, test_opB1
execute  3, 58, teststringxB2, test_opB2
execute  4, 58, teststringxB3, test_opB3
execute  5, 58, teststringxB4, test_opB4
execute  6,  0, teststringxB5, test_opB5
execute  7, 58, teststringxB6, test_opB6
execute  8, 58, teststringxB7, test_opB7
execute  9, 58, teststringxB8, test_opB8
execute 10,  0, teststringxB9, test_opB9
execute 11, 58, teststringxBA, test_opBA
execute 12, 58, teststringxBB, test_opBB
execute 13, 58, teststringxBC, test_opBC
execute 14, 58, teststringxBD, test_opBD
execute 15, 58, teststringxBE, test_opBE
execute 16, 58, teststringxBF, test_opBF
test11end:

testgroup 12
execute  1, 74, teststringxC0, test_opC0
execute  2, 74, teststringxC1, test_opC1
execute  3, 78, teststringxC4, test_opC4
execute  4, 78, teststringxC5, test_opC5
execute  5, 58, teststringxC6, test_opC6
execute  6, 58, teststringxC7, test_opC7
test12end:

testgroup 13
execute  1, 66, teststringxD0, test_opD0
execute  2, 66, teststringxD1, test_opD1
execute  3, 74, teststringxD2, test_opD2
execute  4, 74, teststringxD3, test_opD3
execute  5,117, teststringxD4, test_opD4
execute  6, 78, teststringxD5, test_opD5
execute  7, 86, teststringxD6, test_opD6
execute  8, 74, teststringxD7, test_opD7
test13end:

testgroup 14
execute  1, 82, teststringxE4, test_opE4
execute  2, 82, teststringxE5, test_opE5
execute  3, 82, teststringxE6, test_opE6
execute  4, 82, teststringxE7, test_opE7
execute  5, 74, teststringxEC, test_opEC
execute  6, 74, teststringxED, test_opED
execute  7, 74, teststringxEE, test_opEE
execute  8, 74, teststringxEF, test_opEF
test14end:

testgroup 15
execute  1, 70, teststringxF8, test_opF8
execute  2, 70, teststringxF9, test_opF9
execute  3, 70, teststringxFA, test_opFA
execute  4,  0, teststringxFB, test_opFB
execute  5, 70, teststringxFC, test_opFC
execute  6,  0, teststringxFD, test_opFD
test15end:

testgroup 16
execute  1, 62, teststringI30, test_I30
execute  2, 66, teststringI32, test_I32
execute  3, 66, teststringI33, test_I33
execute  4, 70, teststringI34, test_I34
execute  5, 70, teststringI35, test_I35
execute  6,117, teststringI36, test_I36
execute  7,125, teststringI37, test_I37
execute  8, 62, teststringI38, test_I38
execute  9, 66, teststringI3A, test_I3A
execute 10, 66, teststringI3B, test_I3B
execute 11, 70, teststringI3C, test_I3C
execute 12, 70, teststringI3D, test_I3D
execute 13,  0, teststringI3E, test_I3E
execute 14,  0, teststringI3F, test_I3F
test16end:

testgroup 17
execute  1, 66, teststringI40, test_I40
execute  2, 66, teststringI41, test_I41
execute  3, 66, teststringI48, test_I48
execute  4, 66, teststringI49, test_I49
execute  5, 66, teststringI4E, test_I4E
test17end:

