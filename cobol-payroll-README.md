# cobol-payroll

A batch **payroll register** in COBOL — the kind of program COBOL was invented
for in 1959 and still runs on mainframes today. It reads a fixed-width employee
file, computes regular + overtime pay, tax, and net for each worker using
fixed-point decimal money math, and prints a formatted report with running
totals.

Written in authentic **fixed-format** COBOL (the column layout inherited from
80-column punch cards) and built with [GnuCOBOL](https://gnucobol.sourceforge.io/).

## Sample output

```
=================================================================
         ANARCHY CORP  --  PAYROLL REGISTER
=================================================================
EMPLOYEE              HOURS       RATE        GROSS          TAX          NET
-----------------------------------------------------------------
Ada Lovelace             45    $25.00   $1,187.50     $237.50     $950.00
Grace Hopper             50    $32.00   $1,760.00     $352.00   $1,408.00
Alan Turing              38    $45.00   $1,710.00     $342.00   $1,368.00
Dennis Ritchie           42    $50.00   $2,150.00     $430.00   $1,720.00
Margaret Hamilton        60    $40.00   $2,800.00     $560.00   $2,240.00
Ken Thompson             40    $55.00   $2,200.00     $440.00   $1,760.00
-----------------------------------------------------------------
TOTALS                                  $11,807.50   $2,361.50   $9,446.00

EMPLOYEES PROCESSED:     6
```

Overtime is paid at 1.5x for hours over 40; tax is a flat 20%. (Grace worked 50
hours, so 10 of them are time-and-a-half.)

## Build & run

Install GnuCOBOL, then compile and run:

```bash
# Debian/Ubuntu: apt-get install gnucobol   |   macOS: brew install gnucobol
cobc -x payroll.cob -o payroll
./payroll
```

`payroll` reads `employees.dat` from the current directory.

## The data file

`employees.dat` is fixed-width — no delimiters, just columns, exactly as the
`FD` record layout in the program declares:

```
columns  1-20  employee name        PIC X(20)
columns 21-23  hours worked         PIC 9(3)      e.g. 045
columns 24-28  hourly rate (cents)  PIC 9(3)V99   e.g. 02500 = $25.00
```

```
Ada Lovelace        04502500
Grace Hopper        05003200
```

The `V99` is an *implied* decimal point — it isn't stored in the file, it just
tells COBOL where the cents are. Edit the file (keeping the columns aligned) to
run your own roster.

## What it shows off

- **`FILE-CONTROL` / `FD` / record layout** — reading fixed-width records into a
  structured `01` record with `PIC` fields.
- **Fixed-point decimal arithmetic** — `9(6)V99` money fields and
  `COMPUTE ... ROUNDED`, so there's no floating-point cent drift.
- **Edited pictures** — `$$$,$$9.99` turns `1187.50` into `$1,187.50`; `B`
  inserts spacing; `Z` suppresses leading zeros.
- **Classic control flow** — a priming `READ`, `PERFORM ... UNTIL END-OF-FILE`,
  an `88`-level condition name for end-of-file, and `PERFORM`ed paragraphs.

## How it's organized

The four COBOL divisions, in order:

- **IDENTIFICATION** — program name.
- **ENVIRONMENT** — `SELECT`/`ASSIGN` the input file.
- **DATA** — the file record, working-storage calculations and totals, and the
  report line layouts.
- **PROCEDURE** — open, print headings, loop reading and processing each record,
  print totals, close.

## Roadmap

- [ ] Write the report to a print file instead of `DISPLAY`
- [ ] Page breaks with headers every N lines, and a run date
- [ ] Read tax brackets from a parameter file
- [ ] A second program that sorts the file by net pay (`SORT`)

## License

MIT — see [LICENSE](LICENSE).
