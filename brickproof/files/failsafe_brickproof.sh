#!/bin/sh
# Copyright 2023-04-01 Stan Grishin (stangri@melmac.ca)

failsafe_brickproof() {
	FAILSAFE=true
	export FAILSAFE
	touch /tmp/failsafe
}

boot_hook_add preinit_main failsafe_brickproof
