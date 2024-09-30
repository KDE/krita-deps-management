# MACRO_BOOL_TO_ON_OFF( VAR RESULT0 ... RESULTN )
# This macro evaluates its first argument
# and sets all the given variables either to OFF or ON
# depending on the value of the first one

# SPDX-FileCopyrightText: 2024 Dmitry Kazakov <dimula73@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause
#

MACRO(MACRO_BOOL_TO_ON_OFF FOUND_VAR )
   FOREACH (_current_VAR ${ARGN})
      IF(${FOUND_VAR})
         SET(${_current_VAR} ON)
      ELSE(${FOUND_VAR})
         SET(${_current_VAR} OFF)
      ENDIF(${FOUND_VAR})
   ENDFOREACH(_current_VAR)
ENDMACRO(MACRO_BOOL_TO_ON_OFF)
