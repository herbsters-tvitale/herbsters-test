#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

LITECOIND=${LITECOIND:-$SRCDIR/herbstersd}
LITECOINCLI=${LITECOINCLI:-$SRCDIR/herbsters-cli}
LITECOINTX=${LITECOINTX:-$SRCDIR/herbsters-tx}
LITECOINQT=${LITECOINQT:-$SRCDIR/qt/herbsters-qt}

[ ! -x $LITECOIND ] && echo "$LITECOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
HRSVER=($($LITECOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for herbstersd if --version-string is not set,
# but has different outcomes for herbsters-qt and herbsters-cli.
echo "[COPYRIGHT]" > footer.h2m
$LITECOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $LITECOIND $LITECOINCLI $LITECOINTX $LITECOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${HRSVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${HRSVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m