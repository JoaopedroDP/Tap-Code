# 1 "main.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files (x86)/Microchip/MPLABX/v5.35/packs/Microchip/PIC18Fxxxx_DFP/1.2.26/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "main.c" 2
# 1 "./config.h" 1
# 38 "./config.h"
#pragma config MCLRE=ON
#pragma config OSC=HS
#pragma config WDT=OFF
#pragma config LVP=OFF
#pragma config DEBUG = OFF
#pragma config WDTPS = 1
# 1 "main.c" 2

# 1 "./pic18f4520.h" 1
# 2 "main.c" 2

# 1 "./lcd.h" 1
# 14 "./lcd.h"
void lcd_init(void);
void lcd_cmd(unsigned char val);
void lcd_dat(unsigned char val);
void lcd_str(const char* str);
void lcd_set_cursor(unsigned char line, unsigned char col);
# 3 "main.c" 2

# 1 "./decifrar.h" 1





int decifrar();
# 4 "main.c" 2

# 1 "./delay.h" 1



void atraso_ms(int t);
# 5 "main.c" 2





void atraso_animado() {
    (*(volatile __near unsigned char*)0xF93) = 0x00;
    (*(volatile __near unsigned char*)0xF81) = 0b01;
    atraso_ms(100);
    while((*(volatile __near unsigned char*)0xF81) != 0b10000000) {
        (*(volatile __near unsigned char*)0xF81) = (*(volatile __near unsigned char*)0xF81) << 1;
        atraso_ms(50);
    }
    while((*(volatile __near unsigned char*)0xF81) != 0b00000010) {
        (*(volatile __near unsigned char*)0xF81) = (*(volatile __near unsigned char*)0xF81) >> 1;
        atraso_ms(50);
    }
    (*(volatile __near unsigned char*)0xF81) = 0;
}

void main(void) {
    (*(volatile __near unsigned char*)0xFC1) = 0x06;
    (*(volatile __near unsigned char*)0xF94) = 0x00;
    (*(volatile __near unsigned char*)0xF95) = 0x00;
    (*(volatile __near unsigned char*)0xF96) = 0x00;

    (*(volatile __near unsigned char*)0xF82) |= 0b10;

    lcd_init();


    (*(volatile __near unsigned char*)0xF93) = 0xF8;


    lcd_init();
    lcd_str("Tradutor codigo ");
    lcd_set_cursor(1, 0);
    lcd_str("da batida       ");
    atraso_animado();
    lcd_cmd(0x01);
    lcd_str("Entre com numero");
    lcd_set_cursor(1, 0);
    lcd_str("de 1 a 5        ");
    atraso_animado();
    lcd_cmd(0x01);
    lcd_str("Ou aperte '#'   ");
    lcd_set_cursor(1, 0);
    lcd_str("para apagar tudo");
    atraso_animado();


    decifrar();
}
