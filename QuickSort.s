# Quick Sort
.globl main

.text

main:
  jal   input
  addi  $sp, $sp, -4 # 1 space
  sw    $v0, 0($sp)  # size

  li    $a1, 0       # a1 = head
  move  $a2, $v0     # a2 = tail = size
  jal   quicksort

  jal   output

  li    $v0, 10      # exit
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
  addi  $t1, $t1, 1     # size += 1
  j     input_loop
exit_input:
  move  $v0, $t1        # return size
  jr    $ra             # return to caller

# void quickSort(vector<int> &A, int head, int tail) {
#   int mid;
#   if(head < tail) {
#     mid = partition(A, head, tail);
#     quickSort(A, head, mid);
#     quickSort(A, mid + 1, tail);
#   }
# }

quicksort:
  addi  $sp, $sp, -12 # 3 spaces
  sw    $a1, 0($sp)   # head
  sw    $a2, 4($sp)   # tail
  sw    $ra, 8($sp)   # return address

  bge   $a1, $a2, exit_quicksort # if head >= tail, exit

  jal   partition     # mid = partition(A, head, tail)

  move  $s0, $v0      # mid = $v0, from partition()

  lw    $a1, 0($sp)   # restore head
  move  $a2, $s0      # tail = mid
  jal   quicksort     # quickSort(A, head, mid)

  addi  $a1, $s0, 1   # head = mid + 1
  lw    $a2, 4($sp)   # restore tail
  jal   quicksort     # quickSort(A, mid + 1, tail)

exit_quicksort:
  lw    $a1, 0($sp)     # restore head
  lw    $a2, 4($sp)     # restore tail
  lw    $ra, 8($sp)     # restore return address
  addi  $sp, $sp, 12  	# restore the stack
  jr    $ra             # return to caller

# int partition(vector<int> &A, int head, int tail) {
#   int pivot = A[head];
#   int i = head;
#   int j;
#
#   for(j = head + 1; j < tail; j++) {
#     if(A[j] <= pivot) {
#       i++;
#       swap(A[i], A[j]);
#     }
#   }
#   swap(A[i], A[head]);
#   return i;
# }

partition:
  addi  $sp, $sp, -4   # 1 space
  sw    $ra, 0($sp)    # return address

  move  $s1, $a1       # s1 = head
  move  $s2, $a2       # s2 = tail

  sll   $s3, $a1, 2    # index *= 4
  lw    $s3, nums($s3) # pivot

  move  $s4, $a1       # i = head
  addi  $s5, $a1, 1    # j = head + 1

part_loop:
  bge   $s5, $s2, exit_loop # if j >= tail, break
  sll   $t1, $s4, 2         # index *= 4
  sll   $t2, $s5, 2         # index *= 4
  lw    $t1, nums($t1)
  lw    $t2, nums($t2)
  bgt   $t2, $s3, endif     # A[j] > pivot, endif
  addi  $s4, $s4, 1         # i++

  move  $a1, $s4
  move  $a2, $s5
  jal   swap               # swap(i, j)

  addi  $s5, $s5, 1        # j++
  j     part_loop

endif:
  addi  $s5, $s5, 1        # j++
  j     part_loop

exit_loop:
  move  $a1, $s4       # a1 = i
  move  $a2, $s1       # a2 = head
  jal   swap           # swap(i, head)

  move  $v0, $s4       # return i

  lw    $ra, 0($sp)
  addi  $sp, $sp, 4   # restore the stack
  jr    $ra           # return to caller

swap:
  sll  $a1, $a1, 2    # index1 *= 4
  sll  $a2, $a2, 2    # index2 *= 4

  lw   $t1, nums($a1)  # t1 = nums[index1]
  lw   $t2, nums($a2)  # t2 = nums[index2]

  sw   $t2, nums($a1)  # nums[index1] = t2
  sw   $t1, nums($a2)  # nums[index2] = t1

  jr   $ra             # return to caller

output:
  li  $t0, 0                  # offset
  li  $t1, 0                  # index
  lw  $t2, 0($sp)             # size
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
  jr    $ra                   # return to caller

.data

nums:       .space  1000
input_msg:  .asciiz	"Please enter a number, 0 to stop: "
