# 1 "teclado.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files (x86)/Microchip/MPLABX/v5.35/packs/Microchip/PIC18Fxxxx_DFP/1.2.26/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "teclado.c" 2
# 1 "./pic18f4520.h" 1
# 2 "teclado.c" 2
# 1 "./teclado.h" 1








unsigned char tc_tecla();
# 3 "teclado.c" 2
# 1 "./delay.h" 1



void atraso_ms(int t);
# 4 "teclado.c" 2






const unsigned char coluna[3] = {0x1, 0x2, 0x4};
unsigned int atraso_min = 5;
unsigned int atraso = 15;






unsigned char tc_tecla() {
    unsigned char i;
    unsigned char ret = 0;
    unsigned char tmp = (*(volatile __near unsigned char*)0xF81);

    for (i = 0; i < 3; i++) {
        (*(volatile __near unsigned char*)0xF81) = ~coluna[i];
        atraso_ms(atraso_min);
        if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<3))) {
            atraso_ms(atraso);
            if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<3))) {
                while (!(((*(volatile __near unsigned char*)0xF83)) & (1<<3)));
                ret = 1 + i;
                break;
            }
        };
        if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<2))) {
            atraso_ms(atraso);
            if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<2))) {
                while (!(((*(volatile __near unsigned char*)0xF83)) & (1<<2)));
                ret = 4 + i;
                break;
            }
        };
        if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<1))) {
            atraso_ms(atraso);
            if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<1))) {
                while (!(((*(volatile __near unsigned char*)0xF83)) & (1<<1)));
                ret = 7 + i;
                break;
            }
        };
        if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<0))) {
            atraso_ms(atraso);
            if (!(((*(volatile __near unsigned char*)0xF83)) & (1<<0))) {
                while (!(((*(volatile __near unsigned char*)0xF83)) & (1<<0)));
                ret = 10 + i;
                break;
            }
        };
        (*(volatile __near unsigned char*)0xF81) = 0x0;
    };

    if (!ret)ret = 255;
    if (ret == 11)ret = 0;
    (*(volatile __near unsigned char*)0xF81) = tmp;
    return ret;
}
