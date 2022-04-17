// test program that computes the nth Fibonacci number (recursively!)

	// set up a stack pointer
	sel #15
	seh #15
	mov >r6 // r6 now points to address 255, the end of memory

	// load which fibonacci number we're going for
	addr fibonacci_index
	mov >r0
	ld [r0]
	mov >r0			// r0 now contains the target index

	// call factorial!
	addr fibonacci
	ba r5

	// finish up
	mov <r0 		// load returned value so we can see it
	hlt

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

fibonacci_index:
	#13
