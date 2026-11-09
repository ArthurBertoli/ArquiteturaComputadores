.data
array:      .word 34, 7, 23, 32, 5, 62, 78, 1, 55, 19
size:       .word 10

msg_orig:   .asciiz "Array original:\n"
msg_sorted: .asciiz "\nArray ordenado (DECRESCENTE):\n"
space:      .asciiz " "
newline:    .asciiz "\n"

.text
.globl main

main:
    # Imprimir array original
    li   $v0, 4
    la   $a0, msg_orig
    syscall

    la   $a0, array
    lw   $a1, size
    jal  print_array

    # Chamada do Quicksort: quicksort(array, 0, size-1)
    la   $a0, array       
    li   $a1, 0           
    lw   $t0, size
    addi $a2, $t0, -1     
    jal  quicksort

    # Imprimir mensagem de ordenado
    li   $v0, 4
    la   $a0, msg_sorted
    syscall

    # Imprimir array resultante
    la   $a0, array
    lw   $a1, size
    jal  print_array

    # Encerrar programa
    li   $v0, 10
    syscall

############################################################
# print_array
############################################################
print_array:
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $s0, 4($sp)
    sw   $s1, 0($sp)

    move $s0, $a0      
    move $s1, $a1      
    li   $t0, 0        

print_loop:
    bge  $t0, $s1, print_done
    sll  $t1, $t0, 2        
    add  $t2, $s0, $t1      
    lw   $a0, 0($t2)        
    li   $v0, 1             
    syscall
    li   $v0, 4
    la   $a0, space
    syscall
    addi $t0, $t0, 1
    j    print_loop

print_done:
    li   $v0, 4
    la   $a0, newline
    syscall
    lw   $s1, 0($sp)
    lw   $s0, 4($sp)
    lw   $ra, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

############################################################
# quicksort (Recursivo - Função Não-Folha)
############################################################
quicksort:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2, 8($sp)
    sw   $s3, 4($sp)
    sw   $s4, 0($sp)

    move $s0, $a0     
    move $s1, $a1     
    move $s2, $a2     

    bge  $s1, $s2, qs_return

    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal  partition
    move $s3, $v0     

    # quicksort esquerda
    move $a0, $s0
    move $a1, $s1
    addi $a2, $s3, -1
    jal  quicksort

    # quicksort direita
    move $a0, $s0
    addi $a1, $s3, 1
    move $a2, $s2
    jal  quicksort

qs_return:
    lw   $s4, 0($sp)
    lw   $s3, 4($sp)
    lw   $s2, 8($sp)
    lw   $s1, 12($sp)
    lw   $s0, 16($sp)
    lw   $ra, 20($sp)
    addi $sp, $sp, 24
    jr   $ra

############################################################
# partition (Lógica alterada para DECRESCENTE)
############################################################
partition:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s0, 20($sp)
    sw   $s1, 16($sp)
    sw   $s2, 12($sp)
    sw   $s3, 8($sp)
    sw   $s4, 4($sp)
    sw   $s5, 0($sp)

    move $s0, $a0      
    move $s1, $a1      
    move $s2, $a2      

    # pivot = array[right]
    sll  $t0, $s2, 2
    add  $t1, $s0, $t0
    lw   $s3, 0($t1)   

    addi $s4, $s1, -1  
    move $s5, $s1      

part_loop:
    bge  $s5, $s2, part_after_loop

    sll  $t2, $s5, 2
    add  $t3, $s0, $t2
    lw   $t4, 0($t3)

    # ALTERAÇÃO AQUI: bge em vez de ble para ordem decrescente
    # Se array[j] >= pivot, incrementa i e troca
    bge  $t4, $s3, part_if
    j    part_next

part_if:
    addi $s4, $s4, 1   
    move $a0, $s0
    move $a1, $s4
    move $a2, $s5
    jal  swap

part_next:
    addi $s5, $s5, 1
    j    part_loop

part_after_loop:
    addi $t5, $s4, 1
    move $a0, $s0
    move $a1, $t5
    move $a2, $s2
    jal  swap

    addi $v0, $s4, 1   

    lw   $s5, 0($sp)
    lw   $s4, 4($sp)
    lw   $s3, 8($sp)
    lw   $s2, 12($sp)
    lw   $s1, 16($sp)
    lw   $s0, 20($sp)
    lw   $ra, 24($sp)
    addi $sp, $sp, 28
    jr   $ra

############################################################
# swap
############################################################
swap:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)

    move $s0, $a0      
    move $s1, $a1      
    move $s2, $a2      

    sll  $t0, $s1, 2
    add  $t1, $s0, $t0
    sll  $t2, $s2, 2
    add  $t3, $s0, $t2

    lw   $t4, 0($t1)
    lw   $t5, 0($t3)
    sw   $t5, 0($t1)
    sw   $t4, 0($t3)

    lw   $s2, 0($sp)
    lw   $s1, 4($sp)
    lw   $s0, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra