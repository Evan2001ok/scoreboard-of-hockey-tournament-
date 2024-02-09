      AREA RESET, CODE
      THUMB
      ENTRY
Main
      bl home_score
      bl away_score
      bl subsevenseg
      bl sub_bonus
      b .

home_score
      push {lr} ;lr = a
      ldr r0, =homescores;upload r0 is array packed
      ldr r1, =Unpacked_home ; set a 32 bits space
      mov r2, #0;initialize counter
      mov r4, #28;set r4 is 28
      mov r6, #0
home_loop
      ldr r3, [r0]; upload value of r0 to r3
      lsr r3, r4 ;right shift 7 byte
      sub r4, #4; 28-4 =24, next loop will shift 6 byte  
      and r3, #0xF; make sure only stroe rightest lsb ; 0x00000001
      strb r3, [r1, r6];store value to unpacked_home counter
      add r6, #1;index store
      add r2, #1; counter to check length of array
      cmp r2, #8; if length = 8, reset counters rx. if not, loop home_loop
      bne home_Notequal;
      mov r2, #0
      mov r4, #28
      add r0, #4
      ldr r5,[r0]; check next 4 byte is 0 or not, if is 0 exit home_loop, if not 0 loop again
      cmp r5, #0
      beq home_exit
home_Notequal
      b home_loop
home_exit
      mov r11, r6 ; save length of Unpacked_home
      pop {lr};lr = a
      bx lr
      
away_score
      push {lr}; lr = b
      mov r6,#0
      ldr r6, =awayscores;upload r0 is array packed
      ldr r7, =Unpacked_away ; set a 32 bits space
      mov r2, #0;initialize counter
      mov r4, #28;set r4 is 28
      mov r3, #0
      mov r8, #0
      mov r9, #0
away_loop
      ldr r3, [r6]; upload values of r0 to r3
      lsr r3, r4;r3 logic right shift 28bits, Reserve half byte in righest lsb.
      sub r4, #4; 28-4 =24, next loop will store the next half byte  
      and r3, #0xF; make sure only stroe rightest lsb
      strb r3, [r7, r8];store r3 value to
      add r8, #1
      add r2, #1; counter add one.
      cmp r2, #8; compare r2 to 8, if not equal, branch Notequal.
      bne away_Notequal;
      mov r2, #0
      mov r4, #28
      add r6, #4
      ldr r5,[r6]
      cmp r5, #0
      beq away_exit
away_Notequal
      b away_loop
away_exit
      pop {lr} ; lr = b
      bx lr

subsevenseg
      push {lr}
      mov r8, #0 ;initialization r8
      mov r6, #0
      ldr r6, =bouns_list ;upload bouns_list
      push{r6} ;keep r6
      ldr r8, =scoreboard;
      ldr r9, =winning
      mov r0, #0
      mov r2, #0
      mov r3, #0
      mov r4, #0
      mov r5, #0
      mov r12, #0
sevenseg_loop
      add r12, #1 ;counter +1
      ldrb r0, [r1],#1;upload unpacked_home value into r0
      ldr r10, =sevensequal ;upload sevensequal
      ldrb r2,[r10, r0]; ldrb rx+score = representation
      strb r2, [r8];representation to scoreboard
      
      ldrb r3,[r7],#1; upload Unpacked_away value to
      ldrb r4, [r10, r3] ;larb rx+score = representation
      strb r4,[r8, #1];representation to scoreboard second byte
      strb r4, [r6],#1;store r4 to bouns_list
      strb r2, [r6],#1;stor r2 to bonus_list second byte
      bl winnersub
      cmp r12, r11 ;compare counter and length of unpacked_home
      bgt exit ;if > ,branch exit
      b sevenseg_loop

winnersub
      cmp r2, r4
      bgt homewin ;home > away, branch
      cmp r2, r4
      blt awaywin ;home < away,branch
      mov r5, #0xFF ; -1
      strb r5, [r9] ; store to winning
      b back
homewin
      mov r5, #0 ;0
      strb r5, [r9]
      b back
awaywin
      mov r5, #1 ;1
      strb r5, [r9]
back
      bx lr
exit
      pop{r6}
      pop{lr}
      bx lr
      
sub_bonus
      push{lr}
      mov r0,#0
      mov r1,#0
      mov r2,#0
      mov r3,#0
      mov r4,#0
      ldr r1, =bonus ;upload bonus array to r1
loop
      ldr r0,[r6,r2] ;upload index value to r0
      add r2, #2
      lsl r0,#16
      lsr r0,#16
      str r0, [r1,r3]
      add r3, #4
      cmp r0,#0
      beq endloop
      b loop
endloop
      pop{lr}
      bx lr
      
      AREA MyData, DATA
homescores dcd 0x12345678,0x89123488,0x23232323,0x00000000
awayscores dcd 0x90182736,0x23456789,0x24242424,0x00000000
scoreboard dcb 0,0
winning dcb 0
sevensequal dcb 0x3F,0x03,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x77
Unpacked_home space 32
Unpacked_away space 32
bouns_list space 64
bonus space 32