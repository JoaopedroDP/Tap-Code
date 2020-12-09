# 1 "decifrar.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files (x86)/Microchip/MPLABX/v5.35/packs/Microchip/PIC18Fxxxx_DFP/1.2.26/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "decifrar.c" 2
# 1 "./decifrar.h" 1





int decifrar();
# 1 "decifrar.c" 2

# 1 "./config.h" 1
# 38 "./config.h"
#pragma config MCLRE=ON
#pragma config OSC=HS
#pragma config WDT=OFF
#pragma config LVP=OFF
#pragma config DEBUG = OFF
#pragma config WDTPS = 1
# 2 "decifrar.c" 2

# 1 "./pic18f4520.h" 1
# 3 "decifrar.c" 2

# 1 "./lcd.h" 1
# 14 "./lcd.h"
void lcd_init(void);
void lcd_cmd(unsigned char val);
void lcd_dat(unsigned char val);
void lcd_str(const char* str);
void lcd_set_cursor(unsigned char line, unsigned char col);
# 4 "decifrar.c" 2

# 1 "./teclado.h" 1








unsigned char tc_tecla();
# 5 "decifrar.c" 2





unsigned char input_atual[2] = {0, 0};

unsigned char input_ant[2] = {0, 0};
char input_num = 0;


int buzzer_delay = 0;


void start_buzzer() {
    (*(volatile __near unsigned char*)0xF82) &= ~0b10;
    buzzer_delay = 6;
}


unsigned char cursor = 0;





void add_char(unsigned char c) {

    static char linha_buffer[17] = "                ";

    if (cursor < 16) {
        lcd_dat(c);
        cursor += 1;
        if (cursor == 16) {
            lcd_set_cursor(1, 0);
        }
    } else {
        linha_buffer[cursor - 16] = c;
        lcd_dat(c);
        cursor += 1;
        if (cursor == 32) {
            lcd_set_cursor(0, 0);
            lcd_str(linha_buffer);
            lcd_set_cursor(1, 0);
            lcd_str("                ");
            lcd_set_cursor(1, 0);
            cursor = 16;
        }
    }
}



void displayNum(unsigned int number, unsigned int b, int tempo) {
    unsigned int values7seg[] = {
        0x3f,
        0x06,
        0x5b,
        0x4f,
        0x66,
        0x6d,
        0x7d,
        0x07,
        0x7f,
        0x67,
        0x77,
        0x7C,
        0x39,
        0x5E,
        0x79,
        0x71,
    };
    (*(volatile __near unsigned char*)0xF92) = 0x00;
    (*(volatile __near unsigned char*)0xF95) = 0x00;
    int i, j, d;
    for(i = 0; i<tempo;) {
        d = 5;
        int n = number;
        do {
            if (n%b!=0) {
                (*(volatile __near unsigned char*)0xF80) = 0;
                (*(volatile __near unsigned char*)0xF83) = values7seg[n%b];
                (*(volatile __near unsigned char*)0xF80) = 1 << d;
                for(j = 0; j < 40; j++);
            }
            n = n / b;
            d--;
            i++;
        } while(n > 0 && d >= 2);
    }
    (*(volatile __near unsigned char*)0xF80) = 0;
}


void limpar_dados() {
    input_atual[0] = 0;
    input_atual[1] = 0;
    input_ant[0] = 0;
    input_ant[1] = 0;
    cursor = 0;
    lcd_cmd(0x01);
    buzzer_delay = 0;
    (*(volatile __near unsigned char*)0xF82) |= 0b10;
}







void ler_input() {
    (*(volatile __near unsigned char*)0xF95) = 0x0F;
    int a = tc_tecla();
    (*(volatile __near unsigned char*)0xF95) = 0x00;
    if (a > 0 && a <= 5) {
        if (input_num == 0) {
            input_ant[0] = input_atual[0];
            input_ant[1] = input_atual[1];
            input_atual[1] = 0;
        }
        start_buzzer();
        input_atual[input_num] = a;
        input_num++;
    } else if (a == 12) {
        limpar_dados();
    }
}



void display_input() {
    displayNum(input_ant[0]*1000 + input_ant[1]*100 + input_atual[0]*10 + input_atual[1], 10, 25);
}



int decifrar() {

    const static unsigned char polibiouSquare[5][5] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'J'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'},
    };

    limpar_dados();

    for (;;) {


        while (input_num != 2) {
            display_input();
            ler_input();

            if (buzzer_delay > 0) {
                buzzer_delay--;
                if (buzzer_delay == 0) {
                    (*(volatile __near unsigned char*)0xF82) |= 0b10;
                }
            }
        }
        input_num = 0;

        add_char(polibiouSquare[input_atual[0]-1][input_atual[1]-1]);
    }

    return 0;
}
