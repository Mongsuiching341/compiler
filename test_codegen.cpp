#include "code_generator.h"

int main()
{
    CodeGenerator generator("output.asm");

    generator.emit("MOV AX, 10");
    generator.emit("MOV BX, AX");
    generator.emit("ADD BX, 5");

    generator.emitLabel("L1");

    generator.emit("MOV AX, BX");

    return 0;
}