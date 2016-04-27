org 0x7C00                                          ;magical start point for the BIOS
BITS 16                                             ;running in 16 bit mode

start:
    jmp loader                                      ;jump to the load label

;;; OEM BLOCK
TIMES 0Bh-$+start DB 0

bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	DB 2
bpbRootEntries: 	DW 224
bpbTotalSectors: 	DW 2880
bpbMedia: 	        DB 0xF0
bpbSectorsPerFAT: 	DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors:       DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	        DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "

msg	db	"Welcome to My Operating System!", 0        ;the message to print

print:
    lodsb                                           ;load the next byte from SI to AL
    or al, al                                       ;is the byte in AL null?
    jz return                                       ;return if it is
    mov ah, 0Eh                                     ;otherwise, print the character
    int 10h
    jmp print                                       ;repeat

return:
    ret                                             ;return to call instruction

loader:
    xor ax, ax                                      ;clear the AX register
    mov ds, ax                                      ;clear the DS register
    mov es, ax                                      ;clear the ES register
    mov si, msg                                     ;move the message into SI
    call print                                      ;make print call

    ;cli                                             ;clear interrupts
    ;hlt                                             ;halt the system

    .reset:
        mov ah, 0                                   ;reset disk function
        mov dl, 0                                   ;drive 0 is the disk
        int 0x13                                    ;call the BIOS
        jc .reset                                   ;if there was an error, try again
    .read:
        mov ah, 0x02                                ;move to funtion two
        mov al, 1                                   ;read 1 sector
        mov ch, 1                                   ;continue on track 1
        mov cl, 2                                   ;move to the second sector
        mov dh, 0                                   ;set head number to 0
        mov dl, 0                                   ;set drive number to 0
        int 0x13                                    ;call the BIOS
        jc .read                                    ;if there was an error, retry
        jmp 0x1000:0x0                              ;jump to the execute sector

times 510 - ($-$$) db 0                             ;excess bytes should be set to 0
dw 0xAA55                                           ;magical BIOS end (Boot signature)

;; SECTOR 2
;org 0x1000
;cli
;hlt
