// test program that computes a factorial (recursively!)

	// set up a stack pointer
	sel #15
	seh #15
	mov >r6 // r6 now points to address 255, the end of memory

	// load our factorial argument
	addr fact_number
	mov >r0
	ld [r0]
	mov >r0			// r0 now contains the number

	// call factorial!
	addr factorial
	ba r5

	// finish up
	no
	hlt

factorial: // n in r0, return address in r5, return value in r0
	mov <r0
	bz fact_base	// if n is zero, just return
	b fact_recur	// if not, recurse

fact_base:
	sel #1			// accumulator is zero, so this is fine
	br r5			// 'bye!

fact_recur:
	mov <r6			// load stack pointer
	adi #-1			// allocate an item
	mov >r1			// store location
	adi #-1			// allocate another
	mov >r6			// store final stack pointer

	mov <r5			// load return address
	st [r6]			// store it on the stack

	mov <r0			// load current n
	st [r1]			// store it on the stack

	adi #-1			// subtract 1 from n
	mov >r0			// store in r0 in prep for call

	addr factorial	// load factorial address
	ba r5			// recursive call!

	ld [r6]			// retrieve return address
	mov >r5			// place in r5

	mov <r6			// load stack pointer
	adi #1			// deallocate first item
	mov >r1			// hang onto that address
	adi #1			// deallocate second item
	mov >r6			// and back to where it started

	ld [r1]			// load back n
	mul r0			// compute n*(n-1)!
	mov >r0			// set up for return
	br r5			// and we're back!

fact_number:
	#0
