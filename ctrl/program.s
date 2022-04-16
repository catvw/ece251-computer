	// set r0 to 15
	set #0
	lsl #4
	set #15
	mov >r0

loop:
	// loop until accumulator goes negative
	add r0
	bnn loop

	// store and load
	st [r0]
	set #0
	ld [r0]

	hlt
