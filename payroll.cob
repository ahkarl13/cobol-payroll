      ******************************************************************
      * PAYROLL  --  a classic batch payroll register.                 *
      *                                                                *
      * Reads a fixed-width employee file (employees.dat), computes    *
      * regular + overtime pay, tax, and net for each worker, and      *
      * prints a formatted report with running totals.  This is the    *
      * sort of program COBOL was born to do in 1959.                  *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYROLL.
       AUTHOR. AK.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMP-FILE ASSIGN TO "employees.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  EMP-FILE.
       01  EMP-RECORD.
           05  EMP-NAME       PIC X(20).
           05  EMP-HOURS      PIC 9(3).
           05  EMP-RATE       PIC 9(3)V99.

       WORKING-STORAGE SECTION.
       01  WS-FLAGS.
           05  WS-EOF         PIC X VALUE "N".
               88  END-OF-FILE          VALUE "Y".

       01  WS-CALC.
           05  WS-REG-HOURS   PIC 9(3)V99.
           05  WS-OT-HOURS    PIC 9(3)V99.
           05  WS-GROSS       PIC 9(6)V99.
           05  WS-TAX         PIC 9(6)V99.
           05  WS-NET         PIC 9(6)V99.

       01  WS-TOTALS.
           05  WS-TOT-GROSS   PIC 9(7)V99 VALUE 0.
           05  WS-TOT-TAX     PIC 9(7)V99 VALUE 0.
           05  WS-TOT-NET     PIC 9(7)V99 VALUE 0.
           05  WS-COUNT       PIC 9(4)    VALUE 0.
           05  WS-COUNT-ED    PIC Z,ZZ9.

       01  HEAD-COLS.
           05  FILLER  PIC X(20) VALUE "EMPLOYEE".
           05  FILLER  PIC X(7)  VALUE "  HOURS".
           05  FILLER  PIC X(11) VALUE "       RATE".
           05  FILLER  PIC X(13) VALUE "        GROSS".
           05  FILLER  PIC X(13) VALUE "          TAX".
           05  FILLER  PIC X(13) VALUE "          NET".

       01  DETAIL-LINE.
           05  DL-NAME   PIC X(20).
           05  DL-HOURS  PIC BBBBZZ9.
           05  DL-RATE   PIC BBB$$$9.99.
           05  DL-GROSS  PIC BB$$$,$$9.99.
           05  DL-TAX    PIC BB$$$,$$9.99.
           05  DL-NET    PIC BB$$$,$$9.99.

       01  TOTAL-LINE.
           05  FILLER    PIC X(20) VALUE "TOTALS".
           05  FILLER    PIC X(7)  VALUE SPACES.
           05  FILLER    PIC X(11) VALUE SPACES.
           05  TL-GROSS  PIC BB$$$,$$9.99.
           05  TL-TAX    PIC BB$$$,$$9.99.
           05  TL-NET    PIC BB$$$,$$9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           OPEN INPUT EMP-FILE
           PERFORM PRINT-HEADINGS
           PERFORM READ-EMP
           PERFORM PROCESS-EMP UNTIL END-OF-FILE
           PERFORM PRINT-TOTALS
           CLOSE EMP-FILE
           STOP RUN.

       PRINT-HEADINGS.
           DISPLAY "=================================================="
                   "==============="
           DISPLAY "         ANARCHY CORP  --  PAYROLL REGISTER"
           DISPLAY "=================================================="
                   "==============="
           DISPLAY HEAD-COLS
           DISPLAY "--------------------------------------------------"
                   "---------------".

       READ-EMP.
           READ EMP-FILE
               AT END SET END-OF-FILE TO TRUE
           END-READ.

       PROCESS-EMP.
           IF EMP-HOURS > 40
               MOVE 40 TO WS-REG-HOURS
               COMPUTE WS-OT-HOURS = EMP-HOURS - 40
           ELSE
               MOVE EMP-HOURS TO WS-REG-HOURS
               MOVE 0 TO WS-OT-HOURS
           END-IF
           COMPUTE WS-GROSS ROUNDED =
               (WS-REG-HOURS * EMP-RATE)
               + (WS-OT-HOURS * EMP-RATE * 1.5)
           COMPUTE WS-TAX ROUNDED = WS-GROSS * 0.20
           COMPUTE WS-NET = WS-GROSS - WS-TAX
           ADD WS-GROSS TO WS-TOT-GROSS
           ADD WS-TAX   TO WS-TOT-TAX
           ADD WS-NET   TO WS-TOT-NET
           ADD 1        TO WS-COUNT
           MOVE EMP-NAME  TO DL-NAME
           MOVE EMP-HOURS TO DL-HOURS
           MOVE EMP-RATE  TO DL-RATE
           MOVE WS-GROSS  TO DL-GROSS
           MOVE WS-TAX    TO DL-TAX
           MOVE WS-NET    TO DL-NET
           DISPLAY DETAIL-LINE
           PERFORM READ-EMP.

       PRINT-TOTALS.
           DISPLAY "--------------------------------------------------"
                   "---------------"
           MOVE WS-TOT-GROSS TO TL-GROSS
           MOVE WS-TOT-TAX   TO TL-TAX
           MOVE WS-TOT-NET   TO TL-NET
           DISPLAY TOTAL-LINE
           MOVE WS-COUNT TO WS-COUNT-ED
           DISPLAY " "
           DISPLAY "EMPLOYEES PROCESSED: " WS-COUNT-ED.
