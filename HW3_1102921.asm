INCLUDE Irvine32.inc
BUFMAX = 100     	; maximum size

.data
sstring BYTE BUFMAX DUP(0)
sPrompt BYTE "This is a Morse Code Translator!",0
sInput BYTE "Please enter your string:",0
sOutput BYTE "Morse Code:",0
sRepeat BYTE "Would you like to proceed another translation (y/n)?",0
charIn BYTE ?
six BYTE 6
sum BYTE ?
morseTable  BYTE  ".-", 0, "-...", 0, "-.-.", 0, "-..", 0
            BYTE  ".", 0, "..-.", 0, "--.", 0, "....", 0
            BYTE  "..", 0, ".---", 0,"-.-", 0,".-..", 0
            BYTE  "--", 0,"-.", 0,"---", 0,".--.", 0
            BYTE  "--.-", 0,".-.", 0,"...", 0,"-", 0
            BYTE  "..-", 0,"...-", 0,".--", 0,"-..-", 0
            BYTE  "-.--", 0,"--..", 0
morseTableNUM BYTE 0,3,8,13,17,19,24,28,33,36,41,45,50,53,56,60,65,70,74,78,80,84,89,93,98,103

morseNUM    BYTE  "-----", 0, ".----", 0, "..---", 0, "...--", 0
            BYTE  "....-", 0, ".....", 0, "-....", 0, "--...", 0
            BYTE  "---..", 0, "----.", 0

morseSpecialTable BYTE ".-.-.-", 0, "--..--", 0,"..--..", 0,"-.--.", 0
                  BYTE "-.--.-", 0, ".----.", 0,"-.-.-.", 0, "---...", 0
                  BYTE "-..-.", 0, "-....-", 0, "-..-.", 0, "...-..-", 0
specialChars BYTE 2Eh,2Ch,3Fh,28h,29h,27h,3Bh,3Ah,22h,2Dh,2Fh,24h
morseSpecialTableNUM BYTE 0,7,14,21,27,34,41,48,55,61,68,74


.code
main PROC
	L1: mov  edx,OFFSET sPrompt
        call WriteString
        call crlf

        mov  edx,OFFSET sInput
        call WriteString
        call crlf
 
        mov	ecx,BUFMAX          
	    mov	edx,OFFSET sstring  
	    call	ReadString      ;輸入字串
	    mov	ecx,eax        	    ;存放所鍵入的字元數量
        mov eax,edx             ;輸入字串OFFSET存在ECX

        call lowercase          ;判斷字母大小寫

        mov  edx,OFFSET sOutput
        call WriteString
        call crlf

        call MorseTran          ;進行摩斯轉換     

        mov  edx, OFFSET sRepeat
        call WriteString

        call ReadChar           ;輸入y/n
        mov  charIn,al
        call WriteChar
        call crlf

        cmp charIn,'y'
        je L1
	exit
main ENDP
;------------------------------------
lowercase PROC
    push ecx
    push eax
        mov edi,eax         
    L2:
        mov eax,0
        mov al,[edi]     ;比較每個字元
        cmp al, 'a' 
        jae lowertoCap   ;大於等於a要去轉成大寫字母
        jb jump          ;小於a的就直接比下一個

    lowertoCap:
        cmp al, 'z'     
        ja jump         ;大於等於z的就直接比下一個
        mov ebx,[edi]   
        sub ebx,32       ;把小寫字母-32即得到大寫字母
        mov [edi],ebx    ;再覆寫回去
    jump:
        inc edi
    loop L2
    pop eax
    pop ecx
    ret
lowercase ENDP
;------------------------------------
MorseTran PROC  
    push ecx
    push eax
    mov edi,eax                 ;指到字串開頭
    L2:    
        mov eax,0
        mov al, byte ptr [edi]  ;把字串的字元讀至al 
        cmp al,' '
        je space                ;跳至空格輸出
      
        cmp al,'0'
        jae num                 ;大於'0',跳至數字輸出
     L1:cmp al,'A'              
        jae alpha               ;大於等於'A',跳至字母輸出
     L3:call special            ;印出其他字元
        cmp sum,1
        je jump                 ;如果sum等於1,代表特殊字元已印出
        jmp no                  ;如果sum等於0,則代表是其他字元
        
     alpha:
        mov ebx,0
        mov bl,al               ;把al存至bl,假如不是字母跳回去時al值不變
        sub bl,'A'              ;把讀取字元減掉'A'
        cmp bl,25
        ja L3                   ;大於25跳回L3繼續判斷
        mov al,bl               
        call alphabet           ;印出字母
        jmp jump

    space:
        mov eax, 2Fh
        call WriteChar
        mov eax, 20h
        call WriteChar
        jmp jump

    num:
        cmp al,'9'
        ja L1                    ;大於9跳回L1繼續判斷  
        call number              ;印出數字
        jmp jump
    no:
        call error               ;印出@
    jump:
        inc edi
    loop L2
    call crlf

    pop eax
    pop ecx
    ret
MorseTran ENDP
;------------------------------------
special PROC
        push edi
        push ecx
        mov ecx,LENGTHOF specialChars        ;特殊字元個數
        mov edi,0                            ;為特殊字元的索引值
        mov sum,0                           
    L1:
        cmp al,byte ptr specialChars[edi]
        jne jump                             ;不相等即跳至下一個

        mov esi, OFFSET morseSpecialTableNUM 
        mov ebx, 0
        add esi,edi                          ;加到指定的位置
        mov bl, byte ptr [esi]               ;bl為偏移量的值

        mov esi, offset morseSpecialTable    ;指到摩斯表
        add esi, ebx                         ;加到指定的位置
        add sum,1                            ;要印出特殊字元sum就+1
        mov edx, esi
        call WriteString
        mov eax, 20h
        call WriteChar
    jump:
        inc edi
    loop L1
        pop ecx
        pop edi
    ret
special ENDP
;------------------------------------
number PROC
    sub al,'0'                  ;al即為第幾個數字 
    mul six                     ;每個數字都是6個bits
    mov esi, OFFSET morseNUM
    add esi,eax                 ;把偏移量加進去
    mov edx,esi
    call WriteString
    mov eax, 20h
    call WriteChar
    ret
number ENDP
;------------------------------------
alphabet PROC
    mov esi, OFFSET morseTableNUM   ;指到每個字母開頭位置對照表
    mov ebx, 0
    mov bl, byte ptr [esi + eax]    ;bl為對應字母的開頭位置
    mov esi, offset morseTable      ;指到摩斯表
    add esi, ebx                    ;;加到指定的位置
    mov edx, esi
    call WriteString
    mov eax, 20h
    call WriteChar
    ret
alphabet ENDP
;------------------------------------
error PROC
    mov eax, 40h
    call WriteChar
    mov eax, 20h
    call WriteChar
    ret
error ENDP
END main