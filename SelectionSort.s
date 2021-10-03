# Selection Sort

# void selectionSort(vector<int> &A, int n) {
#   for (int i = 0; i < n-1; i++) {
#     int min_idx = i;
#     for (int j = i+1; j < n; j++)
#     if (A[j] < A[min_idx])
#         min_idx = j;
#     swap(A[min_idx], A[i]);
#   }
# }

.globl main

.text

main:
  jal input
  addi  $sp, $sp, -4 # 1 space
  sw    $v0, 0($sp)

  jal selection_sort

  jal output

  li  $v0, 10     # exit
  syscall

input:
  li  $t0, 0            # offset = 0
  li  $t1, 0            # size = 0
input_loop:
  li  $v0, 4            # print string syscall code = 4
  la  $a0, input_msg
  syscall

  li  $v0, 5            # read int syscall code = 5
  syscall

  sw    $v0, nums($t0)  # num[offset/4] = input
  addi  $t0, $t0, 4     # offset += 4
  beqz  $v0, exit_input # if index == 0, break
  addi  $t1, $t1, 1     # size   += 1
  j     input_loop
exit_input:
  move  $v0, $t1        # return size
  jr    $ra             # return to caller

selection_sort:
  lw    $t0, 0($sp)           # size
  addi  $sp, $sp, -4          # 1 space
  sw    $ra, 0($sp)

  li    $t1, 0                # i = 0
  addi  $t2, $t0, -1          # size - 1
foreach:
  bge  $t1, $t2, exit_foreach # if i >= size - 1, break

  move $t3, $t1               # min_index = i
  addi $t4, $t1, 1            # j = i + 1
loop:
  bge  $t4, $t0, exit_loop

  move $t5, $t4
  move $t6, $t3
  sll  $t5, $t5, 2
  sll  $t6, $t6, 2
  lw   $t5, nums($t5)
  lw   $t6, nums($t6)

  bge  $t5, $t6, endif
  move $t3, $t4         # min_index = j
endif:
  addi, $t4, $t4, 1     # j++
  j loop

exit_loop:
  move $a1, $t3
  move $a2, $t1
  jal swap
  addi $t1, $t1, 1    # i++
  j foreach

exit_foreach:
  lw  $ra, 0($sp)
  addi  $sp, $sp, 4   # 1 space
  jr  $ra

swap:
  sll $a1, $a1, 2     # index1 *= 4
  sll $a2, $a2, 2     # index2 *= 4

  lw  $s1, nums($a1)  # t1 = nums[index1]
  lw  $s2, nums($a2)  # t2 = nums[index2]

  sw  $s2, nums($a1)  # nums[index1] = t2
  sw  $s1, nums($a2)  # nums[index2] = t1

  jr  $ra             # return to caller

output:
  li  $t0, 0                  # offset
  li  $t1, 0                  # index
  lw  $t2, 0($sp)
output_loop:
  li  $v0, 1                  # print int syscall code = 1
  lw  $a0, nums($t0)          # output = nums[offset/4]
  syscall

  li  $a0, 32                 # space ASCII = 32
  li  $v0, 11                 # print char syscall code = 11
  syscall

  addi  $t0, $t0, 4           # offset += 4
  addi  $t1, $t1, 1           # index  += 1
  bne   $t1, $t2, output_loop # index != size, continue

  li  $a0, 10                 # \n ASCII = 10
  li  $v0, 11                 # print char syscall code = 11
  syscall

  addi  $sp, $sp, 4           # restore the stack
  jr  $ra                     # return to caller

.data

nums:       .space  1000
input_msg:  .asciiz "Please enter a number, 0 to stop: "
