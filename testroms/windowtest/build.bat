set romname=windowtest

del ..\emulator\rom\%romname%.ws

del %romname%.ws

..\nasm -f bin -o %romname%.ws %romname%.asm -l %romname%.lst 

pause
