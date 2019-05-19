#!/bin/sh -efu

# Prepare to create recovery.tar for Tavolga
# see also:  features.in/build-mr/lib/90-build-mr.mk
RECOVERY_WORKDIR="$BUILDDIR/tavolga-recovery"

mkdir -p "$RECOVERY_WORKDIR"
cp -a  -t "$RECOVERY_WORKDIR/" tavolga-recovery/*
echo "${RECOVERY_LINE:- Press ENTER to start recovery from USB}" \
	> "$RECOVERY_WORKDIR/line"
