*----------------------------------------------------------------------
*
        ORG     $0
        DC.L    $3000           * Stack pointer value after a reset
        DC.L    start           * Program counter value after a reset
        ORG     $3000           * Start at location 3000 Hex
*
*----------------------------------------------------------------------
*
#minclude /home/cs/faculty/riggins/bsvc/macros/iomacs.s
#minclude /home/cs/faculty/riggins/bsvc/macros/evtmacs.s
*
*----------------------------------------------------------------------
*
* Register use
*
*----------------------------------------------------------------------
*
start:          initIO                  * Initialize (required for I/O)
                setEVT                  * Error handling routines
                *initF                  * For floating point macros only


                lineout         title   * Your code goes HERE
                lineout         skipln

                *Repeat these steps until user says 'N/n'


loop:           lineout         prompt1
                linein          buffer
                move.l          D0,D1                   *Stores length of base in D1
                subq.b          #1,D1
                lea             buffer,A1               *Stores base of number to convert at A1



isT:            cmpi.b          #'0',(A1)               *decimal number?
                blo             e1
                cmpi.b          #'9',(A1)+
                bhi             e1
                dbra            D1,isT

                cvta2           buffer,D0
                move.l          D0,D1           *converted base into a 2s complement number into D1
                cmpi.l          #2,D1
                blo             e1
                cmpi.l          #16,D1          *checks if in range between 2-16
                bhi             e1
                bra             loop2

e1:             lineout         errBase         *spits error and prompts
                bra             loop



loop2:          lineout         prompt2
                linein          buffer
                move.l          D0,D2           *Stores length of number to convert in D2
                move.l          D2,D4           *Make a copy of the length of the number
                subq.b          #1,D2
                lea             buffer,A2



isValidNumber:  cmpi.b          #'0',(A2)       *checks if in decimal range
                blo             e2
                cmp.b           #'9',(A2)
                bhi             hex
                subi.b          #'0',(A2)
                bra             skhex

hex:            andi.b          #$5f,(A2)       *converts ascii to a twos complement by subtracting
                cmpi.b          #'A',(A2)
                blo             e2
                cmpi.b          #'F',(A2)
                bhi             e2
                subi.b          #$37,(A2)

skhex:          cmp.b           (A2)+,D1
                bls             e2
                dbra            D2,isValidNumber
                bra             convert





e2:             lineout         errorNum        *spits out error and prompts
                bra             loop2




convert:        lea             buffer,A3
                subq.b          #1,D4
                move.b          (A3)+,D5        *Stores first byte of number into D5
cloop:          tst.b           D4
                beq             loop3           *algorithm to convert to a standard value
                mulu            D1,D5
                add.b           (A3)+,D5
                subq.b          #1,D4
                bra             cloop




****D5 is the raw value entered****





loop3:          lineout         prompt3
                linein          buffer
                move.l          D0,D3
                subq.b          #1,D3           *Stores length of base to convert at D3
                lea             buffer,A4


isT2:           cmpi.b          #'0',(A4)       *check if a decimal number
                blo             e3
                cmpi.b          #'9',(A4)+
                bhi             e3
                dbra            D3,isT2

                cvta2           buffer,D0
                move.l          D0,D3           *converted base into a 2s complement number into D3
                cmpi.l          #2,D3
                blo             e3
                cmpi.l          #16,D3          *check if in range 2-16
                bhi             e3
                bra             divide




e3:             lineout         errBase
                bra             loop3           *spits out error and prompts



divide:         lea             buffer,A5               *divide by the base and spit out remainders to get backwards answer
                move.b          #0,(A5)+
dloop:          andi.l          #$0000FFFF,D5
                divu            D3,D5
                swap            D5
                cmpi.b          #'9',(A5)
                bhi             hexr
                addi.b          #'0',D5
                bra             skiph
hexr:           addi.b          #$37,D5
skiph:          move.b          D5,(A5)+
                swap            D5
                tst.w           D5
                bne             dloop


                lea             buff2,A6                *reverse the answer to correct form and copy into separate buffer
revloop:        move.b          -(A5),(A6)+
                tst.b           (A5)
                bne             revloop

                move.b          #0,(A6)                 *null terminate


                lineout         answer
                lineout         skipln

ynloop:         lineout         prompt4                 *continue converting bases?
                linein          buffer
                cmpi.b          #1,D0
                bne             e4


                lea             buffer,A0               *check if a y or n
                andi.b          #$5F,(A0)
                cmpi.b          #'Y',(A0)
                beq             loop
                cmpi.b          #'N',(A0)
                beq             fin
                bra             e4



e4:             lineout         erryn
                bra             ynloop          *spits out error and prompts


fin:            lineout         done




        break                   * Terminate execution
*
*----------------------------------------------------------------------
*       Storage declarations
                        * Your storage declarations go HERE

title:  dc.b    'Program #3, Will Gebbie, cssc0200',0
skipln: dc.b    0,0
prompt1: dc.b   'Enter the base of the number to convert (2..16): ',0
prompt2: dc.b   'Enter the number to convert: ',0
prompt3: dc.b   'Enter the base to convert to: ',0
prompt4: dc.b   'Do you want to convert another number (Y/N)?',0
done:   dc.b    'The program has finished.',0
errBase:  dc.b  'Please enter a valid base.',0
errorNum: dc.b  'Please enter a valid number.',0
erryn:  dc.b    'Please enter Y or N.',0
buffer: ds.b    82
answer: dc.b    'The number is '
buff2:  ds.b    82


        end
