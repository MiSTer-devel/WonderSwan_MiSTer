set romname=timingtest

del %romname%.ws

..\nasm -f bin -o %romname%.ws %romname%.asm -l %romname%.lst 

pause
