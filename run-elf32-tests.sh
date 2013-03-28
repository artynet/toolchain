#!/bin/sh

# Copyright (C) 2012, 2013 Synopsys Inc.

# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# This file is a master script for building ARC tool chains.

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.

# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.          

#		   SCRIPT TO RUN ARC-ELF32 REGRESSION TESTS
#                  ========================================

# Usage:

#   ./run-elf32-tests.sh

# The following environment variables must be supplied

# RELEASE

#     The number of the current ARC tool chain release.

# LOGDIR

#     Directory for all log files.

# RESDIR

#     Directory for all results directories.

# ARC_GNU

#     The directory containing all the sources. If not set, this will default
#     to the directory containing this script.

# ARC_ENDIAN

#     "little" or "big"

# PARALLEL

#     string "-j <jobs> -l <load>" to control parallel make.

# ARC_TEST_TARGET

#     The IP address for the target if required by the board.

# Result is 0 if successful, 1 otherwise.


# Standard setup
. "${ARC_GNU}"/toolchain/arc-init.sh

# Run ELF32 regression and gather results. Gathering results is a separate
# function because of the variation in the location and number of results
# files for each tool.
export DEJAGNU=${ARC_GNU}/toolchain/site.exp
echo "Running elf32 tests"

# Create the ELF log file and results directory
logfile_elf="${LOGDIR}/elf32-check-$(date -u +%F-%H%M).log"
rm -f "${logfile_elf}"
res_elf="${RESDIR}/elf32-results-$(date -u +%F-%H%M)"
mkdir ${res_elf}

# Location of some files depends on endianess. For now with ELF this is
# ignored, but this code is a holding position.
if [ "${ARC_ENDIAN}" = "little" ]
then
    target_dir=arc-elf32
    bd_elf=${ARC_GNU}/bd-${RELEASE}-elf32
else
    target_dir=arceb-elf32
    bd_elf=${ARC_GNU}/bd-${RELEASE}-elf32eb
fi

# The target board to use
board=arc-sim

# Run the tests
status=0
run_check ${bd_elf}     binutils            "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} binutils/binutils     "${logfile_elf}" \
    || status=1
run_check ${bd_elf}     gas                 "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} gas/testsuite/gas     "${logfile_elf}" \
    || status=1
run_check ${bd_elf}     ld                  "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} ld/ld                 "${logfile_elf}" \
    || status=1
run_check ${bd_elf}     gcc                 "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} gcc/testsuite/gcc/gcc "${logfile_elf}" \
    || status=1
echo "Testing g++..."
save_res  ${bd_elf}     ${res_elf} gcc/testsuite/g++/g++ "${logfile_elf}" \
    || status=1
# libgcc and libgloss tests are currently empty, so nothing to run or save.
# run_check ${bd_elf}     target-libgcc       "${logfile_elf}"
# run_check ${bd_elf}     target-libgloss     "${logfile_elf}"
run_check ${bd_elf}     target-newlib       "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} ${target_dir}/newlib/testsuite/newlib \
    "${logfile_elf}" || status=1
run_check ${bd_elf}     target-libstdc++-v3 "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf}     ${res_elf} \
    ${target_dir}/libstdc++-v3/testsuite/libstdc++ "${logfile_elf}" \
    || status=1
run_check ${bd_elf} sim                 "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf} ${res_elf} sim/testsuite/sim     "${logfile_elf}" \
    || status=1
run_check ${bd_elf} gdb                 "${logfile_elf}" ${board} \
    || status=1
save_res  ${bd_elf} ${res_elf} gdb/testsuite/gdb     "${logfile_elf}" \
    || status=1

exit ${status}
