; Snake86 - Snake of 8086
assume cs:code,ds:data,ss:stack
data segment
  ; 80*50 playground
  ; HIBYTE color, LOBYTE data
  buf dw 80 dup(0f55h)
      dw 0f55h,0201h,77 dup(0),0f55h
      dw 47 dup(0f55h,78 dup(0),0f55h)
      dw 80 dup(0f55h)
  ; snake starts at (1,1) with 1 length
  head dw 162
  tail dw 162
  len dw 1
  key db 'd'
  seed dw 0
data ends
stack segment stack
  db 256 dup(0)
stack ends
code segment
; draw a 4*4 block
; ah color, al data
; bx offset=2*(80*row+col)
draw_block:
  push bx
  mov dl,ah
  mov dh,dl
  mov ax,bx
  mov cx,160
  div cl
  ; ah 2*col, al row
  ; mapping to 320*200 video memory
  ; 16*80*row+4*col, 16*80*(row+4)+4*col+4
  xor bx,bx
  mov bl,ah
  shl bx,1
  sar cx,1
  mul cl
  ; bx 4*col, es 80*row
  add ax,0a000h
  mov es,ax
  mov cx,4
  DRAW_BLOCK_LOOP:
    mov es:[bx],dx
    mov es:[bx+2],dx
    ; rendering rows first
    add bx,320
    loop DRAW_BLOCK_LOOP
  pop bx
  ret
; double counter clock to consume some processor time
; cx master counter, ax slave counter
delay:
  mov cx,1
  xor ax,ax
  DELAY_LOOP:
    sub ax,1
    test ax,ax
    jnz DELAY_LOOP
    loop DELAY_LOOP
  ret
; buffer user input, need to discard verbose keys
get_key:
  mov ah,1
  int 16h
  jnz GET_KEY_LOOP
  ret
  GET_KEY_LOOP:
    mov ds:key,al
    xor ah,ah
    int 16h
    jmp get_key
; set direction (difference of offset) of snake
; right=1, left=-1, down=80, up=-80
; al input
set_dir:
  mov bx,ds:head
  mov ah,1
  cmp al,'d'
  jz _set_dir
  neg ah
  cmp al,'a'
  jz _set_dir
  mov ah,80
  cmp al,'s'
  jz _set_dir
  neg ah
  cmp al,'w'
  jnz SET_DIR_RET
  _set_dir:
    mov al,byte ptr ds:buf[bx]
    add al,ah
    jz SET_DIR_RET
    ; no turning around!
    mov byte ptr ds:buf[bx],ah
  SET_DIR_RET:
    ret
; srand(time)
srand:
  mov ah,2
  int 1ah
  add dx,cx
  mov ds:seed,dx
  ret
; rand(1,cx)
rand:
  mov ax,ds:seed
  mov dx,13
  mul dx
  add ax,1313
  adc dx,0
  div cx ; cx = 0 ??
  mov ax,dx
  mov ds:seed,ax
  inc ax
  ret
; generate food in a random free block
; HIBYTE 04 (red), LOBYTE 00 (not occupied)
gen_food:
  push bx
  mov cx,78*48
  mov ax,ds:len
  sub cx,ax
  call rand
  mov bx,160
  mov cx,ax
  ; bx offset, cx index of free space
  GEN_FOOD_LOOP:
    add bx,2
    mov al,byte ptr ds:buf[bx]
    test al,al
    jnz GEN_FOOD_LOOP
    loop GEN_FOOD_LOOP
    ; skip occupied block and stop when cx is zero
  GEN_FOOD_RET:
    mov ax,0400h
    mov ds:buf[bx],ax
    call draw_block
    pop bx
    ret
; move snake
; returns non-zero upon collison
snake_move:
  mov bx,ds:head
  mov al,byte ptr ds:buf[bx]
  cbw
  shl ax,1
  add bx,ax
  ; ax 2*direction (signed!), bx offset
  mov dx,ds:buf[bx]
  test dl,dl
  jnz SNAKE_MOVE_RET
  ; blocked! gameover now ...
  mov ds:head,bx
  sar ax,1
  mov ah,2
  mov ds:buf[bx],ax
  ; HIBYTE 02 (green), LOBYTE direction
  cmp dh,4
  jnz _snake_move
  ; update head only when eating food
  call draw_block
  mov dx,ds:len
  inc dx
  mov ds:len,dx ; increment lenth by 1
  call gen_food
  xor ax,ax
  jmp SNAKE_MOVE_RET
  _snake_move:
    call draw_block
    mov bx,ds:tail
    xor ax,ax
    call draw_block
    ; update tail when moving
    ; HIBYTE 00 (black), LOBYTE: 00 (not occupied)
    mov al,byte ptr ds:buf[bx]
    cbw
    shl ax,1
    mov dx,bx
    add dx,ax
    mov ds:tail,dx
    xor ax,ax
    mov ds:buf[bx],ax
  SNAKE_MOVE_RET:
    ret
start:
  mov ax,data
  mov ds,ax
  mov ax,stack
  mov ss,ax
  mov sp,256
  mov ax,13h
  int 10h ; graphic mode
  xor bx,bx
  initloop:
    mov ax,ds:buf[bx]
    call draw_block
    add bx,2
    cmp bx,50*80*2
    jb initloop
  call srand
  call gen_food
  mainloop:
    call delay
    call get_key
    ; 'q' quit the game
    mov al,ds:key
    cmp al,'q'
    jz exit
    call set_dir
    call snake_move
    test ax,ax
    jz mainloop
  exit:
    xor ax,ax
    int 16h ; any key to continue
    mov ax,03h
    int 10h ; quit graphic mode
    mov ax,4c00h
    int 21h
code ends
end start
