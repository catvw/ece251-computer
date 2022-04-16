	set #0
	lsl #4
	set #1
	mov >r0

loop:
	add r0
	bnn loop

	hlt
