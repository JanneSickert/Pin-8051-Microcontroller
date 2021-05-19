L0 EQU P0.0							;Alle stellen im Code L0 heisen werden durch P0.0 ersetzt.
L1 EQU P0.1							;Alle stellen im Code L1 heisen werden durch P0.1 ersetzt.
L2 EQU P0.2							;Alle stellen im Code L2 heisen werden durch P0.2 ersetzt.
OK EQU P0.7							;Alle stellen im Code OK heisen werden durch P0.7 ersetzt.
AKTUELLE_NUMMER EQU P2				;Alle stellen im Code AKTUELLE_NUMMER heisen werden durch P2 ersetzt.

ORG 0h								;Ab den Speicher 0h wird Code in den ROM(Programmspeicher) geschrieben. Dies ist auch der Anfang des Programms.
JMP Main							;Springe zur Sprungmarke Main
ORG 3h								;Wenn interrupt 0 ausgelöst wird springt das programm zu den Speicher 3h. Der interrupt wird durch das drücken von P3.2 ausgelöst. Die endung h steht für Hexadezimal.
JMP Werte_speichern					;Springe zu Werte_speichern.
JMP Anzeige							;Springe zu Anzeige

Zaehler_Init:						;Mit P3.4 wird der Zähler hochgezählt. Namen mit : dahinter sind Sprungmarken die mit JMP aufgerufen werden können.
	MOV TMOD, #5h					;Setzt den Timer/Counter Mode 00000101b = 5		--> siehe Formelsammlung
	MOV TL0, #0d					;Speichert in Speicher TL0 den Wert 0.
	SETB TR0						;Startet den Counter.
RET									;Springt dorthin zurück wo Zaehler_Init aufgerufen wurde.

Interrupt_INIT:						;Dieses Unterprogramm aktiviert interrupt 0. Der interrupt kann am Port P3.2 ausgelöst werden. In diesen fall übernahme der Ziffern.
	SETB IT0						;Interrupt wird bei dem wechsel von 1 nach 0 ausgelöst.
	SETB EX0						;Externe interrupt Freigabe 0.
	SETB EA							;Globale interrupt Freigabe.
RET									;Springt dorthin zurück wo Interrupt_INIT aufgerufen wurde.

Auswertung:
	MOV R0, A						;Kopiere den Wert von A in R0.
	MOV A, R5						;Kopiere den Wert von R5 in A.
	CJNE A, 254d, Anzeige			;CJNE(compare jump not equals) Wenn der in A gespeicherte Wert nicht gleich den am Speicher 254d ist wird zu Fail gesprungen.
	MOV A, R6						;Kopiere den Wert von R6 in A.
	CJNE A, 253d, Anzeige			;CJNE(compare jump not equals) Wenn der in A gespeicherte Wert nicht gleich den am Speicher 253d ist wird zu Fail gesprungen.
	MOV A, R7						;Kopiere den Wert von R7 in A.
	CJNE A, 252d, Anzeige			;CJNE(compare jump not equals) Wenn der in A gespeicherte Wert nicht gleich den am Speicher 252d ist wird zu Fail gesprungen.
	MOV A, R0						;Kopiere den Wert von R0 in A.
	SETB OK							;Setzt das Bit bei P0.7
RETI								;Springt innerhalb des Interrupts zurück dorthin wo es aufgerufen wurde.

Werte_speichern:
	CJNE A, #0d, J1					;Wenn A nicht 0 ist springt er zu J1.
	MOV R5, P2
	SETB L0							;Setzt das Bit bei P0.0.
	MOV TL0, #0d					;Setzt das Counter Register wieder auf 0
	INC A							;Zählt A eins nach oben.
	JMP Ende
	J1:
		CJNE A, #1d, J2				;Da A beim zweiten speichern nicht mehr 0 sondern 1 ist wird dieser Block ausgeführt.
		MOV R6, P2
		SETB L1
		MOV TL0, #0d
		INC A
		JMP Ende
	J2:
		CJNE A, #2d, Anzeige		;Da A beim dritten speichern nicht mehr 1 sondern 2 ist wird dieser Block ausgeführt.
		MOV R7, P2
		SETB L2
		MOV TL0, #0d
		JMP Auswertung
		INC A
	Ende:
RETI

Load_Data:
	MOV DPTR, #Tabelle				;Speichert die Speicheradressen der Tabelle in DPTR. Mit diesen Adressen kann auf die Nummern 3 1 7 zugekriffen werden.
	
	MOV A, #0d						;Speichert den Wert 0 in A. Die endung d steht für Dezimal.
	MOVC A, @A+DPTR					;Holt die Adresse für den 0 eintrag für die Tabelle aus DPTR. Und holt anschliesend den Wert aus der Tabelle und Speichert ihn in A.
	MOV 254d, A						;Der Wert von A wird im RAM(Schreibe und lese Speicher) an der Adresse 254 gespeichert.
	
	MOV A, #1d						;Dieser Vorgang wird nun noch für die anderen beiden Nummern wiederholt.
	MOVC A, @A+DPTR
	MOV 253d, A
	
	MOV A, #2d
	MOVC A, @A+DPTR
	MOV 252d, A
RET

Main:
	MOV P0, #0d						;Setzt alle Bits an Port 0 auf 0.
	CALL Load_Data					;Ruft das Unterprogramm Load_Data auf.
	MOV A, #0d
	CALL Interrupt_INIT				;Ruft das Unterprogramm Interrupt_INIT auf.
	CALL Zaehler_Init				;Ruft Zaehler_Init auf. Der Unterschied zwischen CALL und JMP ist das mit Call ein Unterprogramm aufgerufen wird. Am Ende des Unterprogramms wird zum CALL Befehl zurückgesprungen.

Anzeige:
	MOV AKTUELLE_NUMMER, TL0		;Kopiert den Wert von TL0 in P2.
	JMP Anzeige						;Springt zurück zu Anzeige. Dies ist eine Endlosschleife.

Tabelle:
DB 3, 1, 7 							;Hier wird der Pin gespeichert.

END									;Ende des Assemblerprogramms.