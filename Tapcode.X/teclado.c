#include "pic18f4520.h"
#include "teclado.h"
#include "delay.h"

// TC0 PORTDbits.RD3 BitTst(PORTD,3)
// TC1 PORTDbits.RD2 BitTst(PORTD,2)
// TC2 PORTDbits.RD1 BitTst(PORTD,1)
// TC3 PORTDbits.RD0 BitTst(PORTD,0)

const unsigned char coluna[3] = {0x1, 0x2, 0x4};
unsigned int atraso_min = 5;
unsigned int atraso = 15;

/// Verifica se um dos bot�es do teclado matricial est� precionado
/// Se um deles estiver, � feito um debound (o testa novamente depois de um atraso)
/// Se ele passar no debounce, ent�o se espera at� o bot�o ser solto, e retorna
/// o numero do bot�o. (Os bot�es '*' e '#' s�o representados por 10 e 12, respectivamente)
/// Caso contr�rio, se retorna 255.
unsigned char tc_tecla() {
    unsigned char i;
    unsigned char ret = 0;
    unsigned char tmp = PORTB;
    
    for (i = 0; i < 3; i++) {
        PORTB = ~coluna[i];
        atraso_ms(atraso_min);
        if (!BitTst(PORTD, 3)) { //TC1
            atraso_ms(atraso);
            if (!BitTst(PORTD, 3)) {
                while (!BitTst(PORTD, 3));
                ret = 1 + i;
                break;
            }
        };
        if (!BitTst(PORTD, 2)) {
            atraso_ms(atraso);
            if (!BitTst(PORTD, 2)) {
                while (!BitTst(PORTD, 2));
                ret = 4 + i;
                break;
            }
        };
        if (!BitTst(PORTD, 1)) {
            atraso_ms(atraso);
            if (!BitTst(PORTD, 1)) {
                while (!BitTst(PORTD, 1));
                ret = 7 + i;
                break;
            }
        };
        if (!BitTst(PORTD, 0)) {
            atraso_ms(atraso);
            if (!BitTst(PORTD, 0)) {
                while (!BitTst(PORTD, 0));
                ret = 10 + i;
                break;
            }
        };
        PORTB = 0x0;
    };

    if (!ret)ret = 255;
    if (ret == 11)ret = 0;
    PORTB = tmp;
    return ret;
}