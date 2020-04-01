IDEAL
MODEL small
STACK 100h
DATASEG

;VARIABLES HERE
x_start_pos dw 0
x_pos dw 0
y_pos dw 0
y_start_pos dw 0


color db GREEN
saveKey db 0

line_lengt dw LINE_LENGTH
highet dw HIGHET_OF_SQUARE
num_of_sqare db 1

current_direction db RIGHT_DIRECTION

position_history dw 200 dup(0)

lost db FALSE

sleep_time dw REGULAR_SLEEP_TIME

ther_is_apple db THERE_ISNT_APPLE

; Define new Point object: Point(x, y)
; x_position first 2 bytes.
; y_position seend_proc_mov_on_same_directiond 2 bytes.
POINT_OBJECT_SIZE equ 4 

W_KEYBOARD equ 17
S_KEYBOARD equ 31
A_KEYBOARD equ 30
D_KEYBOARD equ 32

UP_DIRECTION equ 0
DOWN_DIRECTION equ 1
LEFT_DIRECTION equ 2
RIGHT_DIRECTION equ 3

THERE_ISNT_APPLE equ 1

THERE_IS_APPLE equ 0
TRUE equ 1
FALSE equ 0

REGULAR_SLEEP_TIME equ 0df00h
FAST_SLEEP_TIME equ 05f00h

LINE_LENGTH equ 5
HIGHET_OF_SQUARE equ 5

next_place_in_arr dw POINT_OBJECT_SIZE

next_square_color db 0

apple_counter db 0

SIZE_OF_HISTORY_POS equ 200

BLACK equ 0000b
WHITE equ 1111b
GREEN equ 0010b
RED	equ 0100b
YELLOW equ 1110b
CAYEN equ 0011b

start_message db 'welcome to the best game ever enter a char to start$'
;----------


CODESEG


proc print_dot
mov bh,0h
mov cx,[x_pos]
mov dx,[y_pos]
mov al,[color]
mov ah,0ch
int 10h
ret
endp print_dot

proc print_line
mov cx,[line_lengt]
guy:
	inc [x_pos]
	push cx
	call print_dot
	pop cx
	loop guy
ret
endp print_line

proc print_square
mov cx,[highet]
mov ax,[y_start_pos]
mov [y_pos],ax
next_line:
	mov ax,[x_start_pos]
	mov [x_pos],ax
	inc [y_pos]
	push cx
	call print_line
	pop cx
	loop next_line
ret
endp print_square

proc erase_square
mov al,[color]
mov [color],BLACK
push ax
call print_square
pop ax
mov [color],al
ret
endp

proc add_new_snake_position
mov bx,offset position_history
cmp [next_place_in_arr],SIZE_OF_HISTORY_POS
jne skip_set_next_place_in_arr
mov [next_place_in_arr],0
skip_set_next_place_in_arr:
mov si,[next_place_in_arr]
mov ax,[x_start_pos]
mov [bx+si],ax
add si, 2
mov ax,[y_start_pos]
mov [bx+si],ax
add si, 2
mov [next_place_in_arr],si
ret
endp add_new_snake_position  


proc up

call erase_last_square
sub [y_start_pos],HIGHET_OF_SQUARE
call set_next_square_color
call print_square
call add_new_snake_position
mov [current_direction],UP_DIRECTION

ret
endp up


proc down

call erase_last_square

add [y_start_pos],HIGHET_OF_SQUARE
call set_next_square_color
call print_square
call add_new_snake_position
mov [current_direction],DOWN_DIRECTION
ret
endp down

proc left
call erase_last_square
sub [x_start_pos],LINE_LENGTH
call set_next_square_color
call print_square
call add_new_snake_position
mov [current_direction],LEFT_DIRECTION

ret
endp left

proc right
call erase_last_square
add [x_start_pos],LINE_LENGTH
call set_next_square_color
call print_square
call add_new_snake_position
mov [current_direction],RIGHT_DIRECTION

ret
endp right

proc erase_last_square

push [x_start_pos]

push [y_start_pos]

mov cx,[next_place_in_arr]
mov al,POINT_OBJECT_SIZE
mov bl,[num_of_sqare]
mul bl
cmp ax,cx
jg nun_ofsquare_biger_then_next_place_inr_arr
sub cx,ax

jmp skip_nun_ofsquare_biger_then_next_place_inr_arr
nun_ofsquare_biger_then_next_place_inr_arr:
sub ax,cx
mov cx,SIZE_OF_HISTORY_POS
sub cx,ax
skip_nun_ofsquare_biger_then_next_place_inr_arr:
mov si,cx
mov bx,offset position_history
mov ax,[bx+si]
mov [x_start_pos],ax
mov ax,[bx+si+2]
mov [y_start_pos],ax
call erase_square

pop [y_start_pos]
pop [x_start_pos]
ret
endp erase_last_square


proc mov_on_same_direction
	call sleep
	xor ax,ax
	mov al,[current_direction]
	cmp ax,UP_DIRECTION
	je stay_up
	cmp ax,DOWN_DIRECTION
	je stay_down
	cmp ax,LEFT_DIRECTION
	je stay_left
	;have to be right direction
	jmp stay_right
stay_up:
	call up
	jmp end_proc_mov_on_same_direction
stay_down:
	call down
	jmp end_proc_mov_on_same_direction
stay_left:
	call left
	jmp end_proc_mov_on_same_direction
stay_right:
	call right
end_proc_mov_on_same_direction:
	ret
	endp mov_on_same_direction

proc sleep

mov cx,0
mov dx,[sleep_time]
;--------- caling wait int
mov ah, 86h
int 15h
ret
endp sleep


proc to_start
mov bl,[color]
push bx
mov [color],WHITE

push [line_lengt]
mov [line_lengt],320

call print_square
mov [y_start_pos],0

call print_square

mov [y_start_pos],200
sub [y_start_pos],HIGHET_OF_SQUARE
call print_square

pop [line_lengt]

push [highet]

mov [x_start_pos],320

sub [x_start_pos],LINE_LENGTH
mov [y_start_pos],0
mov [highet],200
call print_square
mov [x_start_pos],0
call print_square
add [x_start_pos],LINE_LENGTH
add [y_start_pos],LINE_LENGTH

pop [highet]
pop bx
mov [color],bl
ret
endp to_start

proc generate_apple
mov al,[ther_is_apple]
cmp aL,THERE_IS_APPLE
je end_proc_generate_apple

push [x_start_pos]
push [y_start_pos]
mov al,[color]
push ax

call random_x_pos
call random_y_pos
mov [color],RED

cmp [apple_counter],7
je tripple_sqare

cmp [apple_counter],10
je fast_apple
jmp skip_change_color
tripple_sqare:
mov [color],CAYEN
jmp skip_change_color
fast_apple:
mov [color],YELLOW
mov [apple_counter],0
skip_change_color:
call print_square


pop ax
mov [color],al
pop [y_start_pos]
pop[x_start_pos]

mov [ther_is_apple],THERE_IS_APPLE


inc [apple_counter]
end_proc_generate_apple:

ret
endp generate_apple

proc random_x_pos
mov ah, 00
INT 1Ah
mov dh,0
mov ax,dx
mov cx,[line_lengt]
div cl
sub dl,ah
add dx,50

mov [x_start_pos],dx
cmp [x_start_pos],6
jg end_proc_random_x_pos
add [x_start_pos],10

end_proc_random_x_pos:

ret
endp random_x_pos

proc random_y_pos
mov ah, 00
INT 1Ah
mov dh,0
mov ax,dx
mov cx,[highet]
div cl
sub dl,ah
add dx,HIGHET_OF_SQUARE
cmp dl,120
jl end_proc_random_y_pos
sub dl,60
end_proc_random_y_pos:

	mov [y_start_pos],dx
	ret
	endp random_y_pos



proc set_next_square_color
mov bh,0
mov cx,[x_start_pos]
mov dx,[y_start_pos]
add cx,2
add dx,2
mov ah,0Dh
int 10h
mov [next_square_color],al
end_proc_set_next_square_color:
ret
endp set_next_square_color

proc check_next_square_color
mov al,[next_square_color]
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
jmp end_proc_check_next_square_color
eat_apple:
mov [ther_is_apple],THERE_ISNT_APPLE
call add_square
mov [sleep_time],REGULAR_SLEEP_TIME
jmp end_proc_check_next_square_color

set_fast_apple:
mov [sleep_time],FAST_SLEEP_TIME
mov [ther_is_apple],THERE_ISNT_APPLE
call add_square
jmp end_proc_check_next_square_color

tripple_sqare_apple:
mov [ther_is_apple],THERE_ISNT_APPLE
call add_square
call add_square
call add_square
mov [sleep_time],REGULAR_SLEEP_TIME
jmp end_proc_check_next_square_color

loosing:
mov [lost],TRUE
end_proc_check_next_square_color:
ret 
endp check_next_square_color

proc moov
WaitForKey:
	mov al,[lost]
	cmp al,TRUE
	je ending
	
	call mov_on_same_direction
	call generate_apple
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
	
	mov bx,0
	mov bl,[current_direction];check last direction
	
	cmp al,6
	je pressed_add_square
	
	cmp al,D_KEYBOARD
	je pressed_right
	
	cmp al,A_KEYBOARD
	je pressed_left
	
	cmp al,S_KEYBOARD
	je pressed_down

	cmp al,W_KEYBOARD
	je pressed_up
	
	;------end
	cmp al,1
	je ending
	
	
	jmp WaitForKey	


pressed_up:
	cmp bx,1
	je WaitForKey
	call up
	jmp WaitForKey
pressed_down:

	cmp bx,0
	je WaitForKey
	call down
	jmp WaitForKey
pressed_left:
	cmp bx,3
	je WaitForKey
	call left
	jmp WaitForKey
pressed_right:
	cmp bx,2
	je WaitForKey
	call right
	jmp WaitForKey
pressed_add_square:
	call add_square
	mov [ther_is_apple],THERE_ISNT_APPLE
	jmp WaitForKey
ending:
ret
endp moov


proc add_square
push [x_start_pos]

push [y_start_pos]


;bx point on first place in arr
mov bx,offset position_history
;ax will point on new square x pos in arr
inc [num_of_sqare]
mov cx,[next_place_in_arr]

mov dl, [num_of_sqare]

mov al, POINT_OBJECT_SIZE
mul dl
cmp ax,cx
jg cant_sub_num_of_square_from_place_in_arr
sub cx,ax

jmp can_sub_num_of_square_from_place_in_arr
cant_sub_num_of_square_from_place_in_arr:
sub ax,cx
mov cx,SIZE_OF_HISTORY_POS
sub cx,ax
can_sub_num_of_square_from_place_in_arr:
mov si,cx
;mov x_start_pos x_pos of new square
mov cx, [bx+si]
mov [x_start_pos], cx
;mov y_start_pos y_pos of new square
mov cx,[bx+si+2]
mov [y_start_pos],cx
;------ new square
call print_square
;new square done


pop [y_start_pos]

pop [x_start_pos]

ret
endp add_square


proc SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp SetGraphic

proc open_scrin
mov dx, offset start_message
mov ah, 9h
Int 21h
;carriage return
mov dl, 10
mov ah,2
int 21h
;new line
mov dl, 13
mov ah,2
int 21h

;get input from user to start
mov ax,0
mov ah, 1h
int 21h
ret
endp open_scrin

START:

mov ax,@data
mov ds,ax



;start coding here
call open_scrin
call SetGraphic
call to_start

call generate_apple
call moov
call random_y_pos

exit:
mov ax,4c00h
int 21h
end start 