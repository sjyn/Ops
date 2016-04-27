rm -f ./first.bin
rm -f ./first.iso

nasm -f bin -o first.bin first.asm
dd conv=notrunc if=./first.bin of=./first.flp
# mv ./first.flp ./cdiso/
mkisofs -o first.iso -b first.flp .
