[org 0x100]

jmp start

snake: times 240 dw -1
maxlen:dw 240
len:dw 0
flag:db 0
oldkb:dd 0
oldtimer:dd 0
lives:db 3
tickcount:db 0
maincount:dw 0
speed: db 0
minutes: db 4
seconds:db 0
level: db 1
score:dw 0
bigFood:db 0
finishGame:db 0
finishMessage:db 'Congratulations'


printTime:
pusha
cmp byte[seconds],0
jne skip5
sub byte[minutes],1
mov byte[seconds],60
skip5:
push 0xb800
pop es
mov al,[minutes]
add al,0x30					;adding 0x30 which is 48 which is ascii of 0 to point to the ascii of number
mov ah,0x07
mov word[es:136],ax
mov word[es:138],0x073A
mov ah,0
sub byte[seconds],5			;printing every five seconds
mov al,[seconds]
push ax
push 140
call printnum
cmp byte[minutes],0
jne skip7
cmp byte[seconds],0
jne skip7
sub byte[lives],1
mov byte[minutes],4
mov byte[seconds],0
mov al,[minutes]
add al,0x30
mov ah,0x07
mov word[es:136],ax
mov word[es:138],0x073A
mov ah,0
sub byte[seconds],5
mov al,[seconds]
push ax
push 140
call printnum
skip7:
popa
ret

printnum:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800			;point ax to video memory base address which is always 0xb800
mov es, ax				;mov to es bcz es register is used for memory:offset notation for video memory as in line 89
mov ax, [bp+6]
mov bx, 10
mov cx, 0 
nextdigit: mov dx, 0 		;storing numbers on stack
div bx 					
add dl, 0x30
push dx 
inc cx 
cmp ax,0 
jnz nextdigit
mov di, [bp+4]
nextpos: pop dx 			;poping and displaying from stack
mov dh, 0x07
mov [es:di],dx 
add di, 2
loop nextpos
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

timer: 
push ax
push es
push bx
push cx
push dx
inc word[cs:maincount]
inc byte [cs:tickcount]
xor dx,dx
xor ax,ax
mov ax,word[cs:maincount]
mov cl,91				;in assembly 8086 there are 18.2 clock ticks in one second so 91 in 5
div cl					;div cl with maincount if maincount>cl than qoutient will be 0 which is stored in ah
cmp ah,0
jne skip6
call printTime			
skip6:
xor dx,dx
mov ax,word[cs:maincount]
mov cx,364			;18.2 for one second so 364 for 20 
div cx
mov bl,16
sub bl,byte[speed]
cmp dx,0
jne skip
cmp byte[speed],15		;maximum speed 15 if speed is less than 15 and 20 seconds has passed than inc speed
jnl skip
mov cl,bl
shr cl,1
add byte[cs:speed],cl
mov bl,16				
sub bl,[cs:speed]		;bl is actually delay between each movement so to increase speed bl will be decreased
skip:
cmp byte[cs:tickcount],bl	;if tickcount has reached bl than move the snake
jb exit2
call movesnake
mov byte[cs:tickcount],0

cmp byte[cs:len],240	
jb exit2
cmp byte[cs:level],2
jb inclvl
mov byte[cs:finishGame],1
jmp exit2
inclvl:
mov byte[cs:level],2
mov byte[cs:minutes],4		;increase level if snake has reached 240 length
mov byte[cs:seconds],0
mov byte[cs:bigFood],0
call resetGame

exit2:
mov al, 0x20
out 0x20, al
pop dx
pop cx
pop bx
pop es
pop ax
iret

kbisr: 		
push ax
push es

in al, 0x60 		;interupt call for keyboard input
cmp al, 0x4b		;0x4b is code for left arrow key and 0x4d for right arrow key
jne rightcmp 
cmp byte[flag],1
je exit
mov byte[flag],0
jmp exit

rightcmp: 
cmp al, 0x4d		
jne upcmp
cmp byte[flag],0
je exit
mov byte[flag],1
jmp exit 

upcmp:
cmp al, 0x48
jne downcmp
cmp byte[flag],3
je exit
mov byte[flag],2
jmp exit 

downcmp:
cmp al, 0x50
jne exit 
cmp byte[flag],2
je exit
mov byte[flag],3
exit:
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop es
pop ax
iret

clrscr:
push ax
push es
push cx
push di
push 0xb800			
pop es
xor di,di
mov ax,0x0720			;store 0x720 at every pixel to clear screen
mov cx,2000
cld
rep stosw

pop di
pop cx
pop es
pop ax
ret


movesnake:
pusha

mov cx,[len]
sub cx,1	
mov bx,cx
shl bx,1			;mov length to bx and multiply bx by 2 bcz in video momory every pixel is of 2 bytes
mov di,snake
add di,bx
mov si,di
sub si,2

push ds
pop es
mov dx,[es:di]
std
l4:
lodsw
stosw
loop l4
push 0xb800
pop es
mov di,[snake]
mov cl,[flag]
cmp cl,0		;if snake was moving left than sub 2 from snake to move it left
jne right
left:
sub di,2
sub word[snake],2
cmp word[es:di],0x0720
jne collide
jmp body
right:
cmp cl,1		;if snake was moving right than add 2 from snake to move it right
jne up
add di,2
add word[snake],2
cmp word[es:di],0x0720
jne collide
jmp body
up:
cmp cl,2		;if snake was moving up than sub 160 from snake to move it up bcz each row has 80 pixels and each pixel is of 2 byte
jne down
sub di,160
sub word[snake],160		;array snake is actually storing location of each pixel of snake on video memory
cmp word[es:di],0x0720
jne collide
jmp body
down:
add di,160		;if snake was moving down than add 160 from snake to move it down
add word[snake],160
cmp word[es:di],0x0720
jne collide

body:
mov di,dx
mov word[es:di],0x0720
call printsnake
jmp exit3

collide:
call collider
mov di,dx
mov word[es:di],0x0720
call printsnake
exit3:
popa
ret

collider:
push ax
push bx
push dx
push es
push di
cmp word[es:di],0x072a		;if next location is small apple
jne bigOne
push 4560
push 3000		
call playsound
add word[cs:score],2
add byte[cs:bigFood],1
jmp simpl
bigOne:
cmp word[es:di],0x074F			;if next location is big apple
jne reset
push 4560
push 3000
call playsound
add word[cs:score],20
mov byte[cs:bigFood],0
simpl:
mov word[es:di],0x0720
call GenerateRandom
add word[ds:len],4
jmp exit4
reset:		;if next location is snake itself than reset
push 1207
push 10000
call playsound
sub byte[ds:lives],1
call resetGame
exit4:
push word[cs:score]
push 120
call printnum
pop di
pop es
pop dx
pop bx
pop ax
ret


printsnake:
pusha

push 0xb800
pop es
mov ax,0x4000	;color for head
mov di,0
mov di,[ds:snake]
mov [es:di],ax
mov si,2
mov cx,[ds:len]
sub cx,1		;-1 bcz head is already printed
mov ax,0x1000	;color for snake body
l3:
mov di,[snake+si]
mov [es:di],ax
add si,2
loop l3 

mov al,byte[cs:lives]
add al,0x30
mov ah,0x07
mov word[es:46],ax	;display lives on screen

popa
ret

printBorder:
push ax
push bx
push cx
push es
push di
push si
push 0xb800
pop es
mov di,0
mov ax,0x5000
mov cx,80
cld
rep stosw		;stosw stores ax at es:di and rep is loop until value of cx to print horizontal border
mov cx,80
mov di,3840
rep stosw
mov di,0
mov si,158
mov cx,25
l2:
mov [es:di],ax
mov [es:si],ax
add di,160
add si,160
loop l2

cmp byte[cs:level],2
jne nolevel
mov di,1330
mov si,2770
mov cx,30
l8:
mov [es:di],ax
mov [es:si],ax
add si,2
add di,2
loop l8
nolevel:
mov word[es:20],0x0754		;storing constant labels in top bar such as label of lives and timer etc
mov word[es:22],0x074c
mov word[es:24],0x073A
mov word[es:26],0x0733
mov word[es:40],0x0752
mov word[es:42],0x074c
mov word[es:44],0x073A
mov word[es:114],0x0753
mov word[es:116],0x0743
mov word[es:118],0x073A
push word[cs:score]
push 120
call printnum
pop si
pop di
pop es
pop cx
pop bx
pop ax
ret

GenerateRandom:		;divide maincount by 2000 bcz 2000 pixels on screen and using the remainder to place apple on screen
pusha
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
Get:
mov ax,word[cs:maincount]	
mov  cx, 2000
div  cx		
skip3:
mov bx,dx
shl bx,1
notSpace:
cmp word[es:bx],0x0720
je food
mov ax,bx
add ax,2		;is location not empty than move to next location and chech again
div cx
mov bx,dx
jmp notSpace
food:
cmp byte[cs:bigFood],2
jb simp
mov word[es:bx],0x074F
jmp exit5
simp:
mov word[es:bx],0x072a
exit5:
popa
ret

resetGame:
push ax
push cx
push es
push ds
push di
push si

push ds
pop es
call clrscr
mov word[cs:len],20
mov byte[cs:speed],1
mov cx,240
mov bx,0
l7:
mov word[ds:snake+bx],-1		
add bx,2
loop l7
mov word[snake],1980
mov byte[flag],0
mov cx,[len]
sub cx,1
mov si,snake
mov di,snake
add di,2
l1:
lodsw
add ax,2
stosw
loop l1
call printBorder
call printsnake
cmp word[cs:maincount],0
jne notStart
push 0xb800
pop es
mov word [es:600],0x072a
mov al,[cs:minutes]
add al,0x30
mov ah,0x07
mov word[es:136],ax
mov word[es:138],0x073A
mov al,[cs:seconds]
add al,0x30
mov word[es:140],ax
mov word[es:142],ax
jmp skip4
notStart:
call GenerateRandom
skip4:
pop si
pop di
pop ds
pop es
pop cx
pop ax
ret

start:
call resetGame
xor di,di
xor ax,ax
mov es,ax
mov ax,[es:8*4]
mov bx,[es:8*4+2]
mov [oldtimer],ax
mov [oldtimer+2],bx

mov ax,[es:9*4]
mov bx,[es:9*4+2]
mov [oldkb],ax
mov [oldkb+2],bx
cli
mov word[es:8*4],timer		;initializing interupts
mov word[es:8*4+2],cs
mov word[es:9*4],kbisr
mov word[es:9*4+2],cs
sti
l5:
cmp byte[cs:finishGame],1
je finish
cmp byte[cs:lives],0
jne l5
finish:
cli
mov ax,[oldkb]			;we were overriting the actual interupts so after finishing the game storing the original ones
mov bx,[oldkb+2]
mov [es:9*4],ax
mov [es:9*4+2],bx
mov ax,[oldtimer]
mov bx,[oldtimer+2]
mov [es:8*4],ax
mov [es:8*4+2],bx
sti
call clrscr
cmp byte[cs:finishGame],1
jne endGame
push ax
push cx
push es
push di
push si
push ds
push 0xb800
pop es
mov si,finishMessage
push word[cs:score]
push 1200
call printnum
mov di,400
mov cx,15
mov ah ,0x07
l9:
lodsb
stosw
loop l9

endGame:
mov ax,0x4c00
int 21h

playsound:
push bp
mov bp,sp
push ax
push bx
push cx

mov al, 182
out 43h, al  
mov ax, [bp+6]   
out 42h, al     
mov al, ah    
out 42h, al 
in  al, 61h       
or  al, 00000011b   
out 61h, al        
mov bx, 25          
.pause1:
mov cx, [bp+4]
.pause2:
dec cx
jne .pause2
dec bx
jne .pause1
in  al, 61h         
and al, 11111100b  
out 61h, al  
pop cx
pop bx
pop ax
pop bp
ret 4