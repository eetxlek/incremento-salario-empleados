      ******************************************************************
      *  DESCRIPCION: INCREMENTO DE SALARIO A ALGUNOS EMPLEADOS        *
      *                                                                *
      *  OBJETIVO:    ESTE PROGRAMA HACE UN CRUCE DE FICHEROS ENTRE EL *
      *               MAESTRO DE EMPLEADOS Y EL SECUENCIAL DE SUBIDAS  *
      *               PARA GRABAR UN FICHERO QUE SERA COPIA DEL        *
      *               MAESTRO CON LAS SUBIDAS DE LOS AFORTUNADOS       *
      *               AVISAR DE LA INCONSISTENCIA                      *
      *                                                                *
      *  TIPO:        BATCH/MATCHING 1:1                               *
      *                                                                *
      *  INPUTS:      DATOS DEL SISTEMA                                *
      *               FICHERO MAESTRO DE EMPLEADOS                     *
      *               FICHERO SECUENCIAL DE SUBIDAS                    *
      *                                                                *
      *  OUTPUTS:     FICHERO DE SALIDA COPIA DEL MAESTRO              *
      *               INFORME (CONTADORES DE LEIDOS Y GRABADOS)        *
      *                                                                *
      ******************************************************************    

       IDENTIFICATION DIVISION.

       PROGRAM-ID. PB0EC319.
       AUTHOR.     ESTIBALIZ (ORIZON).
       DATE-WRITTEN.  OCTUBRE, 2025.
       DATE-COMPILED.
      
       ENVIRONMENT DIVISION.
      
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MAESTRO
                ASSIGN TO MAESTRO
                ORGANIZATION IS INDEXED
                ACCESS MODE IS SEQUENTIAL
                RECORD KEY  IS CLAVE
                FILE STATUS IS FS-ERROR1.
      
           SELECT SUBIDAS
                ASSIGN TO SUBIDAS
                ORGANIZATION IS SEQUENTIAL
                ACCESS MODE IS SEQUENTIAL
                FILE STATUS IS FS-ERROR2.
      
           SELECT SALIDA
                ASSIGN TO SALIDA
                ORGANIZATION IS SEQUENTIAL
                ACCESS MODE IS SEQUENTIAL
                FILE STATUS IS FS-ERROR3.
      
       DATA DIVISION.
      
       FILE SECTION.
       FD  MAESTRO.
       01  REG-MAESTRO.
           05  CLAVE               PIC X(5).
           05  FILLER              PIC X(95).
      
       FD  SUBIDAS
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORDING MODE IS F
           RECORD CONTAINS 100 CHARACTERS
           DATA RECORD IS REG-SUBIDAS.
       01  REG-SUBIDAS             PIC X(100).
      
       FD  SALIDA
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORDING MODE IS F
           RECORD CONTAINS 100 CHARACTERS
           DATA RECORD IS REG-SALIDA.
       01  REG-SALIDA              PIC X(100).
      
       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05  WS-IO-REG-MAESTRO.
               COPY VEMPE.
      
           05  WS-IN-REG-SUBIDAS.
               10  WS-IN-CODIGO    PIC X(5)     VALUE ZEROS.
               10  FILLER          PIC X(49)    VALUE SPACES.
               10  WS-IN-SUBIDA    PIC S9(9) PACKED-DECIMAL VALUE ZEROS.
               10  FILLER          PIC X(41)    VALUE SPACES.
      
           05  CTR-LEIDOS-MAESTRO  PIC S9(5) COMP-3   VALUE ZEROS.
           05  CTR-LEIDOS-SUBIDAS  PIC S9(5) COMP-3   VALUE ZEROS.
           05  CTR-GRABADOS        PIC S9(5) PACKED-DECIMAL VALUE ZEROS.
      
           05  FS-ERROR1           PIC 99       VALUE ZEROS.
           05  FS-ERROR2           PIC 99       VALUE ZEROS.
           05  FS-ERROR3           PIC 99       VALUE ZEROS.
      
           05  END-OF-FILE-SWITCH-M  PIC 9        VALUE ZEROS.
           88  END-OF-FILE-M                  VALUE 1.
      
           05  END-OF-FILE-SWITCH-S  PIC 9        VALUE ZEROS.
           88  END-OF-FILE-S                  VALUE 1.
      
           05  EMPTY-FILE-SWITCH     PIC 9        VALUE ZEROS.
           88  EMPTY-FILE                     VALUE 1.
      
           05  ERRORES-SWITCH      PIC 9        VALUE ZEROS.
           88  ERRORES                      VALUE 1.
      
           05  AUX-FECHA.
           10  AUX-ANO         PIC 9(4)     VALUE ZEROS.
           10  AUX-MES         PIC 9(2)     VALUE ZEROS.
           10  AUX-DIA         PIC 9(2)     VALUE ZEROS.
      
           05  AUX-HOR.
           10  AUX-HORA        PIC 9(2)     VALUE ZEROS.
           10  AUX-MINUTO      PIC 9(2)     VALUE ZEROS.
           10  AUX-SEGUNDO     PIC 9(2)     VALUE ZEROS.
           10  AUX-MILI        PIC 9(2)     VALUE ZEROS.
      
       PROCEDURE DIVISION.
      
        1000-PRINCIPAL.
           PERFORM 2000-INICIO
      
           PERFORM 3000-PROCESO
            THRU 3000-PROCESO-EXIT
           UNTIL END-OF-FILE-M
             AND END-OF-FILE-S
               OR EMPTY-FILE
               OR ERRORES
      
           PERFORM 8000-FIN
      
           STOP RUN.
      
       2000-INICIO.
           DISPLAY 'COMIENZA EL PROGRAMA PB0XC319'.
      
           ACCEPT AUX-FECHA FROM DATE YYYYMMDD
           ACCEPT AUX-HOR   FROM TIME
      
           DISPLAY 'HOY ES: '  AUX-ANO  '-' AUX-MES    '-' AUX-DIA
           DISPLAY 'SON LAS: ' AUX-HORA ':' AUX-MINUTO ':' AUX-SEGUNDO
           ':' AUX-MILI.
      
           OPEN INPUT MAESTRO
                    SUBIDAS
           OUTPUT SALIDA
      
           IF  FS-ERROR1 NOT EQUAL TO ZEROS
           DISPLAY 'ERROR AL ABRIR MAESTRO  ' FS-ERROR1
           SET ERRORES TO TRUE
           END-IF
      
           IF  FS-ERROR2 NOT EQUAL TO ZEROS
           DISPLAY 'ERROR AL ABRIR SUBIDAS   ' FS-ERROR2
           SET ERRORES TO TRUE
           END-IF
      
           IF  FS-ERROR3 NOT EQUAL TO ZEROS
           DISPLAY 'ERROR AL ABRIR SALIDA   ' FS-ERROR3
           SET ERRORES TO TRUE
           END-IF
      
           PERFORM 9000-LEER-MAESTRO
      
           PERFORM 9100-LEER-SUBIDAS
      
           IF  END-OF-FILE-S
           SET EMPTY-FILE TO TRUE
           END-IF.
      
       3000-PROCESO.
           IF  CLAVE EQUAL TO WS-IN-CODIGO
           PERFORM 3100-INCREMENTO
      
           ELSE
           IF  CLAVE LESS THAN WS-IN-CODIGO
                 PERFORM 3200-MANTENER
      
           ELSE
                 PERFORM 3300-INCONSISTENCIA
           END-IF
           END-IF.
      
       3000-PROCESO-EXIT.
           EXIT.
      
       3100-INCREMENTO.
           ADD WS-IN-SUBIDA TO WS-IO-SALARIO
      
           WRITE REG-SALIDA FROM WS-IO-REG-MAESTRO
      
           IF  FS-ERROR3 EQUAL TO ZEROS
           ADD 1 TO CTR-GRABADOS
      
           ELSE
           DISPLAY 'ERROR AL GRABAR SALIDA ' FS-ERROR3
           SET ERRORES TO TRUE
           END-IF
      
           PERFORM 9000-LEER-MAESTRO
      
           PERFORM 9100-LEER-SUBIDAS.
      
       3200-MANTENER.
           WRITE REG-SALIDA FROM WS-IO-REG-MAESTRO
      
           IF  FS-ERROR3 EQUAL TO ZEROS
           ADD 1 TO CTR-GRABADOS
      
           ELSE
           DISPLAY 'ERROR AL GRABAR SALIDA ' FS-ERROR3
           SET ERRORES TO TRUE
           END-IF
      
           PERFORM 9000-LEER-MAESTRO.
      
       3300-INCONSISTENCIA.
           DISPLAY 'ATENCION: SUBIDA SIN EMPLEADO ' WS-IN-CODIGO
      
           PERFORM 9100-LEER-SUBIDAS.
      
       8000-FIN.
           IF  EMPTY-FILE
           DISPLAY 'FICHERO DE SUBIDAS  VACIO'
      
           ELSE
           IF  ERRORES
                 DISPLAY '////////////////////'
                 DISPLAY '//A T E N C I O N///'
                 DISPLAY '/////ERRORES////////'
                 DISPLAY '/SE CANCELA EL PGM//'
                 DISPLAY '///Y EL JCL ////////'
      
                 MOVE 1001 TO RETURN-CODE
      
           ELSE
                 DISPLAY '********************'
                 DISPLAY '***EJECUCION OK*****'
                 DISPLAY '********************'
                 DISPLAY 'LEIDOS MAESTRO   ' CTR-LEIDOS-MAESTRO
                 DISPLAY 'LEIDOS SUBIDAS   ' CTR-LEIDOS-SUBIDAS
                 DISPLAY 'GRABADOS         ' CTR-GRABADOS
           END-IF
           END-IF
      
           IF NOT ERRORES
           CLOSE MAESTRO
                  SUBIDAS
                  SALIDA
           END-IF
      
           DISPLAY 'FIN DEL PROGRAMA PB0XC319'.
      
       9000-LEER-MAESTRO.
           READ MAESTRO  INTO WS-IO-REG-MAESTRO
      
           EVALUATE FS-ERROR1
           WHEN ZEROS
                  ADD 1 TO CTR-LEIDOS-MAESTRO
      
           WHEN 10
                 SET END-OF-FILE-M TO TRUE
      
                 MOVE HIGH-VALUES TO CLAVE
      
           WHEN OTHER
                  DISPLAY 'ERROR AL LEER EN MAESTRO  ' FS-ERROR1
                  SET ERRORES TO TRUE
           END-EVALUATE.
      
       9100-LEER-SUBIDAS.
           READ SUBIDAS INTO WS-IN-REG-SUBIDAS
      
           EVALUATE FS-ERROR2
           WHEN ZEROS
                  ADD 1 TO CTR-LEIDOS-SUBIDAS
      
           WHEN 10
                  SET END-OF-FILE-S TO TRUE
      
                  MOVE HIGH-VALUES TO WS-IN-CODIGO
      
           WHEN OTHER
                  DISPLAY 'ERROR AL LEER SUBIDAS ' FS-ERROR2
                  SET ERRORES TO TRUE
           END-EVALUATE.
      