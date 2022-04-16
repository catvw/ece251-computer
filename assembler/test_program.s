	// load 1 into register 0
	set #0
	lsl #4
	set #1
	mov >r0

loop: // loop until accumulator goes negative
	add r0
	bnn loop

	hlt
