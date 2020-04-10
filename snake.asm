IDEAL
MODEL small
STACK 100h
DATASEG

SIZE_OF_HISTORY_POS equ 280 
position_history dw SIZE_OF_HISTORY_POS dup(10)

saveKey db 0

BLACK equ 0000b
WHITE equ 1111b
GREEN equ 0010b
RED	equ 0100b
YELLOW equ 1110b
CAYEN equ 0011b
MAGNETA equ 1101b

W_KEYBOARD equ 17
S_KEYBOARD equ 31
A_KEYBOARD equ 30
D_KEYBOARD equ 32

num_of_sqare db 1

next_square_color db BLACK

is_lost db FALSE

music_sounds dw 11EDh,0FE8h,0E2Bh,0D5Bh,0BE4h,0A98h,96Fh,8E5h

apple_color dw red
apple_counter db 0
ther_is_apple db FALSE

right_direction_on_key_board db D_KEYBOARD
left_direction_on_key_board db A_KEYBOARD

SQUARE_LINE_LENGTH equ 5
SQUARE_HEIGHT equ 5
highet dw SQUARE_HEIGHT
line_length dw SQUARE_LINE_LENGTH

REGULAR_SLEEP_TIME equ 0df00h
FAST_SLEEP_TIME equ 05f00h

random_x dw 0
random_y dw 0

POINT_OBJECT_SIZE equ 4 
next_place_in_arr dw POINT_OBJECT_SIZE

sleep_time dw REGULAR_SLEEP_TIME

UP_DIRECTION equ 0
DOWN_DIRECTION equ 1
LEFT_DIRECTION equ 2
RIGHT_DIRECTION equ 3

STRING_REGULAR_APPLE db "Red apple-Regular Apple$"
STRING_FAST_APPLE db "Yellow apple-Change the speed of your snake$"
STRING_TRIPPLE_APPLE db "Cayen apple-Tripple score apple$"
STRING_CONFUSE_APPLE db "Pink apple-Switch betwen left and right$"

LEN_REGULAR_APPLE_STRING equ 23
LEN_TRIPPLE_APPLE_STRING equ 31
LEN_CONFUSE_APPLE_STRING equ 39
LEN_FAST_APPLE_STRING equ 43

end_massage db "GG your score is $"

FALSE equ 0
TRUE equ 1

current_direction dw RIGHT_DIRECTION

start_message db 'welcome to the best game ever enter a char to start$'

CODESEG

proc print_dot
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp, sp
	
	push cx
	
	mov bh,0h
	mov cx,x
	mov dx,y
	mov al,color
	mov ah,0ch
	int 10h
	
	pop cx
	pop bp
	ret 6
endp print_dot

proc print_line
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	push bp
	mov bp,sp
	
	push cx
	
	mov cx,[line_length]
	
	next_dot:
		push x
		push y
		push color
		call print_dot
		
		mov ax,x
		inc ax
		mov x,ax
		loop next_dot
	pop cx
	pop bp
	ret 6
endp print_line

proc print_square
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp,sp

	mov cx,[highet]
	
	next_line:
		push x
		push y
		push color
		call print_line
		
		mov ax,y
		inc ax
		mov y,ax
		
		loop next_line
	pop bp
	ret 6
endp print_square


proc sleep
	;arguments sleep_time (in microseconds)
	sleep_time_arg equ [bp+4]
	push bp
	mov bp,sp
	mov cx,0
	mov dx,sleep_time_arg
	;--------- caling wait int
	mov ah, 86h
	int 15h
	pop bp
	ret 2
endp sleep


proc move_snake
	;arguments: direction,position_history,place_in_arr
	direction equ [bp+8]
	place_in_arr equ [bp+4]
	position_history_arg equ [bp+6]
	next_x equ [bp-4]
	next_y equ [bp-2]
	push bp
	mov bp,sp
	sub sp,4
	
	; extract current x, y.
	mov bx,position_history_arg
	mov si,place_in_arr
	mov ax,[bx+si- 4]
	mov next_x, ax
	mov ax,[bx+si- 2]
	mov next_y, ax
	
	
	mov ax,direction
	cmp ax,LEFT_DIRECTION
	je snake_left
	cmp ax,RIGHT_DIRECTION
	je snake_right
	cmp ax,UP_DIRECTION
	je snake_up
	cmp ax,DOWN_DIRECTION
	je snake_down
	
	snake_left:
		mov ax,SQUARE_LINE_LENGTH
		sub next_x,ax
		jmp  end_direction
	snake_right:
		mov ax,SQUARE_LINE_LENGTH
		add next_x,ax
		jmp end_direction
	snake_up:
		mov ax,SQUARE_HEIGHT
		sub next_y,ax
		jmp end_direction
	snake_down:
		mov ax,SQUARE_HEIGHT
		add next_y,ax
	end_direction:
	push next_x
	push next_y
	call set_next_square_color
	
	push next_x
	push next_y
	push GREEN
	call print_square
	
	push next_x
	push next_y
	call add_new_snake_position
	 
	
	
	
	add sp,4
	pop bp
	ret 6
endp move_snake


proc generate_apple
	mov al,[ther_is_apple]
	cmp al,TRUE
	je end_proc_generate_apple

	call random_x_pos
	call random_y_pos
	mov [apple_color],RED

	cmp [apple_counter],7
	je tripple_sqare
	cmp [apple_counter],5
	je confuse_apple
	cmp [apple_counter],10
	je fast_apple
	jmp skip_change_color
	tripple_sqare:
	mov [apple_color],CAYEN
	jmp skip_change_color
	confuse_apple:
	mov [apple_color],MAGNETA
	jmp skip_change_color
	fast_apple:
	mov [apple_color],YELLOW
	mov [apple_counter],0

	skip_change_color:
	call check_x_and_random_y
	push [random_x]
	push [random_y]
	push [apple_color]
	call print_square


mov [ther_is_apple],TRUE


inc [apple_counter]
end_proc_generate_apple:

ret
endp generate_apple


proc random_x_pos
mov ah, 00
INT 1Ah
mov dh,0
mov ax,dx
mov cx,SQUARE_LINE_LENGTH
div cl
sub dl,ah
mov dh,0
add dx,50

mov [random_x],dx
end_proc_random_x_pos:

ret
endp random_x_pos

proc random_y_pos
mov ah, 00
INT 1Ah
mov dh,0
mov ax,dx
mov cx,SQUARE_HEIGHT
div cl
sub dl,ah
add dx,25
mov dh,0
mov [random_y],dx
ret
endp random_y_pos

proc check_x_and_random_y
cmp [random_x],5
jg skip_x_to_low
mov [random_x],10
skip_x_to_low:
cmp [random_x],300
jl skip_x_to_high
mov [random_x],270
skip_x_to_high:
cmp [random_y],5
jg skip_y_to_low
mov [random_y],10
skip_y_to_low:
cmp [random_y],190
jl skip_y_to_high
mov [random_y],185
skip_y_to_high:
ret
endp check_x_and_random_y


proc add_new_snake_position
;TODO add to arguments snake object
	;arguments: x,y
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	mov bx,offset position_history
	cmp [next_place_in_arr],SIZE_OF_HISTORY_POS
	jne skip_set_next_place_in_arr
	mov [next_place_in_arr],0
	skip_set_next_place_in_arr:
		mov si,[next_place_in_arr]
		mov ax,x
		mov [bx+si],ax
		add si, 2
		mov ax,y
		mov [bx+si],ax
		add si, 2
		mov [next_place_in_arr],si
	pop bp
	ret 4
endp add_new_snake_position

proc set_next_square_color
	; arguments: x,y
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	mov bh,0
	mov cx,x
	mov dx,y
	add cx,2
	add dx,2
	mov ah,0Dh
	int 10h
	mov [next_square_color],al
	pop bp
	ret 4
endp set_next_square_color

proc erase_square
	; arguments: x, y
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	push x
	push y
	push BLACK
	call print_square
	
	pop bp
	ret 4
endp erase_square


proc make_lines
	push [line_length]
	;----------- print horizental dwon line
	mov [line_length],320

	push 0
	push 0
	push WHITE

	call print_square
	;----------- print horizental up line
	push 0
	mov ax,200
	sub ax,SQUARE_HEIGHT
	push ax
	push WHITE

	call print_square

	pop [line_length]
	;----------- print vertical right line
	push [highet]

	mov ax,320
	sub ax,SQUARE_LINE_LENGTH
	push ax
	push 0
	mov [highet],200
	push WHITE
	call print_square
	;----------- print vertical left line
	push 0
	push 0
	push WHITE
	call print_square

	pop [highet]
	ret
endp make_lines

proc check_next_square_color
;arguments: next_square_color
	next_square_color_arg equ [bp+4]
	PUSH BP
	MOV BP,SP
	mov al,next_square_color_arg
	cmp al,BLACK
	je end_proc_check_next_square_color
	cmp al,RED
	je eat_apple
	cmp al,WHITE
	je loosing
	cmp al,GREEN
	je loosing
	cmp al,YELLOW
	je set_fast_apple
	cmp al,CAYEN
	je tripple_sqare_apple
	cmp al,MAGNETA
	je set_confuse_apple
	jmp end_proc_check_next_square_color

	eat_apple:
	call eat_regular_apple
	jmp end_proc_check_next_square_color

	set_confuse_apple:
	call eat_confuse_apple
	jmp end_proc_check_next_square_color

	set_fast_apple:
	call eat_fast_apple
	jmp end_proc_check_next_square_color

	tripple_sqare_apple:
	call eat_tripple_sqare_apple
	jmp end_proc_check_next_square_color

	loosing:
	mov [is_lost],TRUE
	end_proc_check_next_square_color:
	
	pop bp
	ret 2
endp check_next_square_color

proc eat_regular_apple
	mov [right_direction_on_key_board],D_KEYBOARD
	mov [left_direction_on_key_board],A_KEYBOARD
	mov [ther_is_apple],FALSE
	inc [num_of_sqare]
	mov [sleep_time],REGULAR_SLEEP_TIME
	mov si,0
	call play_music_sounds
	ret
endp eat_regular_apple

proc eat_fast_apple
	mov [sleep_time],FAST_SLEEP_TIME
	mov [ther_is_apple],FALSE
	inc [num_of_sqare]
	mov si,1
	call play_music_sounds
	ret
endp eat_fast_apple

proc eat_tripple_sqare_apple
	mov [ther_is_apple],FALSE
	add [num_of_sqare],3
	mov si,2
	call play_music_sounds
	ret
endp eat_tripple_sqare_apple

proc eat_confuse_apple
	mov [right_direction_on_key_board],A_KEYBOARD
	mov [left_direction_on_key_board], D_KEYBOARD
	mov si,3
	mov [ther_is_apple],FALSE
	inc [num_of_sqare]
	call play_music_sounds
	ret
endp eat_confuse_apple

proc  play_music_sounds ;--- paramater in si
	mov ax, [offset music_sounds+si]	
	out 42h,al
	mov al,ah
	out 42h,al
	mov al,61h
	mov al,11b
	out 61h,al
	
	;caling sleep otherwise you cant hear sound
	push REGULAR_SLEEP_TIME
	call sleep
	call stop_playing_nusic
	ret
endp play_music_sounds


proc stop_playing_nusic
	mov al,61h				
	out 61h,al
	ret
endp stop_playing_nusic

proc erase_last_square
	;arguments: position_history,place_in_arr
	position_history_arg equ [bp+6]
	place_in_arr equ [bp+4]
	push bp
	mov bp,sp

	mov cx,place_in_arr
	mov al,POINT_OBJECT_SIZE
	mov bl,[num_of_sqare]
	mul bl
	cmp ax,cx
	jg num_of_square_bigger_then_next_place_in_arr
	sub cx,ax

	jmp skip_num_of_square_bigger_then_next_place_in_arr
	num_of_square_bigger_then_next_place_in_arr:
	sub ax,cx
	mov cx,SIZE_OF_HISTORY_POS
	sub cx,ax
	skip_num_of_square_bigger_then_next_place_in_arr:
	mov si,cx
	mov bx,position_history_arg
	mov ax,[bx+si]
	push ax
	mov ax,[bx+si+2]
	push ax
	call erase_square

	
	pop bp
	ret 4
endp erase_last_square



proc game_loop
WaitForKey:

	call generate_apple
	push [sleep_time]
	call sleep
	
	push offset position_history
	push [next_place_in_arr]
	call erase_last_square
	
	push [current_direction]
	push offset position_history
	push [next_place_in_arr]
	call move_snake
	
	mov al,[next_square_color]
	push ax
	call check_next_square_color
	
	;check if there is a a new key in buffer
	in al, 64h
	cmp al, 10b
	; If there isn't a new key, jump to start.
	je WaitForKey
	in al, 60h	
	cmp al, [saveKey]  ;check if the key is same as already pressed
	je WaitForKey
	mov [saveKey], al  ;new key - store it
	
	mov bx,[current_direction]
	
	cmp al,6
	je pressed_add_square
	
	cmp al,[right_direction_on_key_board]
	je pressed_right
	
	cmp al,[left_direction_on_key_board]
	je pressed_left
	
	cmp al,S_KEYBOARD
	je pressed_down

	cmp al,W_KEYBOARD
	je pressed_up
	
	;------end
	cmp al,1
	je ending
	
	mov al,[is_lost]
	cmp al,TRUE
	je ending
	
	jmpWaitForKey:
	jmp WaitForKey

	pressed_up:
		cmp bx,DOWN_DIRECTION
		je WaitForKey
		mov [current_direction],UP_DIRECTION
		jmp WaitForKey
	pressed_down:
		cmp bx,UP_DIRECTION
		je jmpWaitForKey
		mov [current_direction],DOWN_DIRECTION
		jmp WaitForKey
	pressed_left:
		cmp bx,RIGHT_DIRECTION
		je jmpWaitForKey
		mov [current_direction],LEFT_DIRECTION
		jmp WaitForKey
	pressed_right:
		cmp bx,LEFT_DIRECTION
		je jmpWaitForKey
		mov [current_direction],RIGHT_DIRECTION
		jmp WaitForKey
	pressed_add_square:
		inc [num_of_sqare]
		mov [ther_is_apple],FALSE
		jmp WaitForKey
ending:
ret
endp game_loop


proc new_line
	;carriage return
	mov dl, 10
	mov ah,2
	int 21h
	;new line
	mov dl, 13
	mov ah,2
	int 21h
	ret
endp new_line

proc open_scrin
	mov dx, offset start_message
	mov ah, 9h
	Int 21h

	call new_line

	mov ax,offset STRING_REGULAR_APPLE
	mov bl,RED
	mov cx,LEN_REGULAR_APPLE_STRING
	call print_with_color

	call new_line

	mov ax,offset STRING_FAST_APPLE
	mov bl,YELLOW
	mov cx,LEN_FAST_APPLE_STRING
	call print_with_color

	call new_line

	mov ax,offset STRING_TRIPPLE_APPLE
	mov bl,CAYEN
	mov cx,LEN_TRIPPLE_APPLE_STRING
	call print_with_color

	call new_line

	mov ax,offset STRING_CONFUSE_APPLE
	mov bl,MAGNETA
	mov cx,LEN_CONFUSE_APPLE_STRING
	call print_with_color

	call new_line

	;get input from user to start
	mov ax,0
	mov ah, 1h
	int 21h
	ret
endp open_scrin


proc return_to_text_mode
	mov ah, 0
	mov al, 2
	int 10h
	ret
endp return_to_text_mode


proc print_with_color ;ax- offset of the string bl-color ;cx <--- number of chars
	;ax <--- offset of the String
	;bl <--- color 
	;cx <--- number of chars
	mov dx,ax
	mov ah, 9

	int 10h

	int 21H
	ret 
endp print_with_color




 proc SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp SetGraphic

proc end_screen
	mov si,4
	;call play_music_sounds
	call return_to_text_mode
	mov al,0
	call mov_to_the_middle_of_the_screen
	 MOV DX, OFFSET end_massage
	 MOV AH, 9H
	 INT 21H 
	 mov al,1
	call mov_to_the_middle_of_the_screen
	mov ah,0
	mov al,[num_of_sqare]
	mov cl,10
	div cl
	mov dl ,al
	push ax
	add dl,30h
	mov ah, 2h
	int 21h
	pop ax
	mov dl ,ah
	push ax
	add dl,30h
	mov ah, 2h
	int 21h
	pop ax
	;carriage return
	mov dl, 10
	mov ah,2
	int 21h
	;new line
	mov dl, 13
	mov ah,2
	int 21h
	waitkey:
	mov ah, 06h
	mov dl, 0ffh
	int 021h
	jz waitkey
	ret
endp end_screen


proc mov_to_the_middle_of_the_screen;----al is parmater wiche line to you want
; Set cursor location to (11, 33)
	 MOV BH, 0
	 MOV DH, 11
	 add dh,al
	 MOV DL, 33
	 MOV AH, 2H
	 INT 10H 
	 ret
 endp mov_to_the_middle_of_the_screen


start:
	mov ax, @data
	mov ds, ax
	call open_scrin
	call SetGraphic
	call make_lines
	call game_loop
	call end_screen
	
	exit:
	mov ax, 4c00h
	int 21h
END start