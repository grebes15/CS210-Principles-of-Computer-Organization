            .data
HEADING:    .word   0xffff8010  # set by program
LEAVETRK:   .word   0xffff8020  # set by program
WHEREX:     .word   0xffff8030  # read by program
WHEREY:     .word   0xffff8040  # read by program
MOVE:       .word   0xffff8050  # set by program

            .text
            .globl  main
main:       #draw a line horizontally
            li      $a0,200     
            li      $a1,1       
            jal     horiz       

            lw      $t0,LEAVETRK  #set the end point
            sw      $zero,0($t0)

            
            li      $a0,100     #draw a line vertically
            li      $a1,1       
            jal     vert        
 
 
 	lw $t0,LEAVETRK #set the end point
 	sw $zero,0($t0)
 
            li $a0,100 #draw a line horizontally
            li $a1,1
            jal horiz
            
            lw $t0, LEAVETRK #set the end point
            sw $zero,0($t0)
            
            
            li $a0,0 #draw a line veritically to finish off the rectangle
            li $a1,1
            jal vert
            
            lw $t0,LEAVETRK #set the end point
            sw $zero,0($t0)
            
            li $v0,10
            syscall
            
            
            
            
            ##################################################
# horiz -- move horizontally to given x-value
# $a0 = goal x-value
# $a1 = true if we should leave a track, false otherwise
##################################################
horiz:      # Preserve registers (in case they're being used elsewhere!)
            addi    $sp,$sp,-16

            sw      $s0,0($sp)
            sw      $s1,4($sp)
            sw      $s2,8($sp)
            sw      $s3,12($sp)

            lw      $s0,HEADING     # MMIO address for heading
            lw      $s1,WHEREX      # MMIO address for x-value
            lw      $s2,MOVE        # MMIO address for move command
            lw      $s3,LEAVETRK    # MMIO address for leave track

            # Loop until we reach goal value
xloop:      lw      $t0,0($s1)      # t0 = current x location
            beq     $t0,$a0,donex   # "Are we there yet?"...

            # ... No. See if we have to move left or right:
            sw      $a1,0($s3)      # set "leave track" as specified
            blt     $t0,$a0,h90     # if current < goal, move right (heading 90)

h270:       # We have to move left (heading 270):
            li      $t0,270         # store the heading (270)...
            sw      $t0,0($s0)      # ... in the appropriate MMIO address
            li      $t0,1           # t0 = "true"
            sw      $t0,0($s2)      # start moving
busyX1:     lw      $t0,0($s1)      # Get current location
            ble     $t0,$a0,donex   # "Are we there yet?"
            j       busyX1

h90:        # We have to move right (heading 90):
            li      $t0,90          # store the heading (90)...
            sw      $t0,0($s0)      # ... in the appropriate MMIO address
            li      $t0,1           # t0 = "true"
            sw      $t0,0($s2)      # start moving
busyX2:     lw      $t0,0($s1)      # Get current location
            bge     $t0,$a0,donex   # "Are we there yet?"
            j       busyX2

donex:      sw      $zero,0($s2)    # stop moving

            lw      $s0,0($sp)      # restore registers
            lw      $s1,4($sp)
            lw      $s2,8($sp)
            lw      $s3,12($sp)
            addi    $sp,$sp,16
            jr      $ra

##################################################
# vert -- move vertically to given x-value
# $a0 = goal y-value
# $a1 = true if we should leave a track, false otherwise
##################################################
vert:      # Preserve registers (in case they are being used)
            addi    $sp,$sp,-16

            sw      $s0,0($sp)
            sw      $s1,4($sp)
            sw      $s2,8($sp)
            sw      $s3,12($sp)

            lw      $s0,HEADING     # MMIO address for heading
            lw      $s1,WHEREY      # MMIO address for y-value
            lw      $s2,MOVE        # MMIO address for move command
            lw      $s3,LEAVETRK    # MMIO address for leave track

yloop:      lw      $t0,0($s1)      # t0 = current y location
            beq     $t0,$a0,doney   # "Are we there yet?"...

            # ... No. See if we have to move up or down:
            sw      $a1,0($s3)      # set "leave track" as specified
            blt     $t0,$a0,h180    # if current < goal, move down (heading 180)
h0:       # We have to move up (heading 0):
            li      $t0,0           # store the heading (0)...
            sw      $t0,0($s0)      # ... in the appropriate MMIO address
            li      $t0,1           # t0 = "true"
            sw      $t0,0($s2)      # start moving
busyY1:     lw      $t0,0($s1)      # Get current location
            ble     $t0,$a0,doney   # "Are we there yet?"
            j       busyY1
h180:       # We have to move down (heading 180):
            li      $t0,180         # store the heading (180)...
            sw      $t0,0($s0)      # ... in the appropriate MMIO address
            li      $t0,1           # t0 = "true"
            sw      $t0,0($s2)      # start moving
busyY2:     lw      $t0,0($s1)      # Get current location
            bge     $t0,$a0,doney   # "Are we there yet?"
            j       busyY2
doney:      sw      $zero,0($s2)    # stop moving

            lw      $s0,0($sp)      # restore registers
            lw      $s1,4($sp)
            lw      $s2,8($sp)
            lw      $s3,12($sp)
            addi    $sp,$sp,16
            jr      $ra