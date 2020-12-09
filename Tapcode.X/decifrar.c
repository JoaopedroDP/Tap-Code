#include "decifrar.h"
#include "config.h"
#include "pic18f4520.h"
#include "lcd.h"
#include "teclado.h"

#define BUZZER_TIME 6

/// o par de inputas atual
unsigned char input_atual[2] = {0, 0};
/// o par de inputs anterior
unsigned char input_ant[2] = {0, 0};
char input_num = 0;

/// o contador de delay do buzzer
int buzzer_delay = 0;

/// Liga o buzzer e inicio o timer dele
void start_buzzer() {
    PORTC &= ~0b10;
    buzzer_delay = BUZZER_TIME;
}

/// posição do cursor no lcd
unsigned char cursor = 0;

/// Adiciona um char ao lcd.
/// Se a primeira linha encher, move o cursor para a segunda linha.
/// Se a segunda linha encher, copia essa linha para a primeira, e
/// move o cursor para o inicio da segunda linha
void add_char(unsigned char c) {
    // uma copia do que está escrito na segunda linha
    static char linha_buffer[17] = "                ";
    
    if (cursor < 16) { //escrevendo na primeira linha
        lcd_dat(c);
        cursor += 1;
        if (cursor == 16) { // a primeira linha encheu
            lcd_set_cursor(1, 0);
        }
    } else { // escrevendo na segunda linha
        linha_buffer[cursor - 16] = c;
        lcd_dat(c);
        cursor += 1;
        if (cursor == 32) { // segunda linha encheu
            lcd_set_cursor(0, 0);
            lcd_str(linha_buffer);
            lcd_set_cursor(1, 0);
            lcd_str("                ");
            lcd_set_cursor(1, 0);
            cursor = 16;
        }
    }
}

/// Mostra o número 'number' na base 'b' no display 7 segmentos,
/// por um tempo proporcional a 'tempo'
void displayNum(unsigned int number, unsigned int b, int tempo) {
    unsigned int values7seg[] = {
        0x3f, //0
        0x06, //1
        0x5b, //2
        0x4f, //3
        0x66, //4
        0x6d, //5
        0x7d, //6
        0x07, //7
        0x7f, //8
        0x67, //9
        0x77, //A
        0x7C, //b
        0x39, //C
        0x5E, //d
        0x79, //E
        0x71, //F
    };
    TRISA = 0x00; // define PORTA como saida
    TRISD = 0x00; // define PORTD como saida
    int i, j, d;
    for(i = 0; i<tempo;) {
        d = 5;
        int n = number;
        do {
            if (n%b!=0) {
                PORTA = 0;
                PORTD = values7seg[n%b];
                PORTA = 1 << d;
                for(j = 0; j < 40; j++);
            }
            n = n / b;
            d--;
            i++;
        } while(n > 0 && d >= 2);
    }
    PORTA = 0;
}

/// Limpa o lcd e os display 7 seg
void limpar_dados() {
    input_atual[0] = 0;
    input_atual[1] = 0;
    input_ant[0] = 0;
    input_ant[1] = 0;
    cursor = 0;
    lcd_cmd(L_CLR);
    buzzer_delay = 0;
    PORTC |= 0b10;
}

/// Lê o botão precionado no teclado, e verifica se está entre 1 e 5,
/// e adiciona ao input atual.
/// Se já houver um par de inputs na variavel atual,
/// move esse par para o par de inputs anterior.
///
/// Se o botão precionado for '#', o lcd e o display é limpo.
void ler_input() {
    TRISD = 0x0F;
    int a = tc_tecla();
    TRISD = 0x00;
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

/// Mostra o par de inputs anterior nos display 1 2 (à esquerda)
/// e mostra o par de inputs atual nos display 3 e 4.
void display_input() {
    displayNum(input_ant[0]*1000 + input_ant[1]*100 + input_atual[0]*10 + input_atual[1], 10, 25);
}

/// Contém o loop responsável por ler os inputs, apresenta-los no display 7seg,
/// decifra-los, e exibir o resultado no lcd.
int decifrar() {
    // a matriz que representa o quadrado de polibio
    const static unsigned char polibiouSquare[5][5] = {
        {'A', 'B', 'C', 'D', 'E'},
        {'F', 'G', 'H', 'I', 'J'},
        {'L', 'M', 'N', 'O', 'P'},
        {'Q', 'R', 'S', 'T', 'U'},
        {'V', 'W', 'X', 'Y', 'Z'},
    };
    
    limpar_dados();
    
    for (;;) {
        // enquanto não tive lido um par de inputs, tenta ler o proximo input
        // e controla o buzzer
        while (input_num != 2) {
            display_input();
            ler_input();
            // faz a contagem regressiva do buzzer, e o desliga quando chegar a zero
            if (buzzer_delay > 0) {
                buzzer_delay--;
                if (buzzer_delay == 0) {
                    PORTC |= 0b10;
                }
            }
        }
        input_num = 0;
        //adiciona a respectiva letra do quadrado de polibio no lcd
        add_char(polibiouSquare[input_atual[0]-1][input_atual[1]-1]);
    }

    return 0;
}
