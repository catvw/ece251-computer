//---------------------------------------------------------------------//
// test program; computes the first n Fibonacci numbers (recursively!) //
//---------------------------------------------------------------------//

	b _start 		// so that we can have the "data segment" up here

fibonacci_index: #13

_start:
	// set up a stack pointer
	sel #0
	seh #0
	mov >r6 		// r6 now points to 0x100, one byte past the end of memory

	// load which Fibonacci number we're going for
	mov >r2			// our loop counter and the current value of n
	addr fibonacci_index
	mov >r0
	ld [r0]
	mov >r3			// r3 now contains the target index

print_loop:
	mov <r2			// load current n
	mov >r0			// r0 now contains current n

	addr fibonacci	// load fibonacci() address
	ba r5			// call fibonacci(n)!
	mov <r0			// load fibonacci(n)
	wr				// show it to the world

	mov <r2			// load current n
	sub r3			// compare n to target
	bz end			// break out if finished
	b continue		// continue loop if not

end: // not much to do here, really
	hlt

continue:
	mov <r2			// load current n
	adi #1			// add 1
	mov >r2			// re-store it
	addr print_loop	// get print_loop address (because it's far away)
	ba r5			// away we go again!

fibonacci: // n in r0, return address in r5, return value in r0
	mov <r0			// load n into accumulator
	adi #-2
	bnn recurse		// if n > 2, recurse
	br r5			// if n is 0 or 1, just return n

recurse:
	mov <r6			// load stack pointer
	adi #-1			// allocate an item
	mov >r1			// store that address
	adi #-1			// allocate another
	mov >r6			// store final stack pointer

	mov <r5			// load return address
	st [r1]			// store it at [sp + 1]

	mov <r0			// load current n
	st [r6]			// store it at [sp]

	adi #-1			// subtract 1 from n
	mov >r0			// store in r0 in prep for call

	addr fibonacci	// load fibonacci() address
	ba r5			// recursive call!

	mov <r0			// load fibonacci(n - 1)
	mov >r1			// store in r1
	ld [r6]			// load n
	adi #-2			// subtract 2 in prep for call
	mov >r0			// store in r0
	mov <r1			// load fibonacci(n - 1) again
	st [r6]			// store it at [sp]

	addr fibonacci	// load fibonacci() address
	ba r5			// recursive call again!

	ld [r6]			// load fibonacci(n - 1)
	add r0			// add fibonacci(n - 2)
	mov >r0			// store in r0

	mov <r6			// load stack pointer
	adi #1			// deallocate one item
	mov >r1			// store next item's address in r1
	adi #1			// deallocate another item
	mov >r6			// and back to where it started

	ld [r1]			// retrieve return address (as that was the item)
	ba r5			// branch back to caller!

// Copyright (C) 2022, C. R. Van West
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
