test_jumponly:
   mov cx,1000
align 2
repeat_jumponly:
   fill_prefetch
   dec cx
   jnz repeat_jumponly
   ret

;-----------------------------------------------------------------------------

test_jumponlyUnaligned:
   mov cx,1000
align 2
   nop
repeat_jumponlyUnaligned:
   fill_prefetch
   dec cx
   jnz repeat_jumponlyUnaligned
   ret

;-----------------------------------------------------------------------------

test_nop:
   dotest nop, nop
   ret
   
test_nop2x:
   dotest2 nop, nop, nop2x
   ret
   
test_incbl:
   dotest inc bl, incbl
   ret
   
test_incbx:
   dotest inc bx, incbx
   ret

test_incbx2x:
   dotest2 inc bx, inc bx, incbx2x
   ret
   
test_cli:
   dotest cli, cli
   ret
   
test_in_al:
   dotest {in al, 0}, in_al
   ret

test_in_aldx:
   dotest {in al, dx}, in_al_dx
   ret
   
test_sp_add2:
   mov [es:workword], sp
   dotest {add sp, 2}, sp_add2
   mov sp, [es:workword]
   ret
   
test_sp_sub2:
   mov [es:workword], sp
   dotest {sub sp, 2}, sp_sub2
   mov sp, [es:workword]
   ret
   
test_push:
   dotest2 push ax, {add sp, 2}, push
   ret

test_pop:
   push ax
   dotest2 pop ax, {sub sp, 2}, pop
   pop ax
   ret
   
test_movaxmem:
   dotest {mov ax, [workword]}, movaxmem
   ret
   
test_movaxmemes:
   dotest {mov ax, [es:workword]}, movaxmemes
   ret