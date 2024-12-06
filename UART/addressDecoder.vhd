
library ieee;
use ieee.std_logic_1164.all;

-- Decodes R/W commands from MCU into UART operations
entity addressDecoder is 
    port( 
        en, R_Wbar : in std_logic;
        addr : in std_logic_vector(1 downto 0); -- address of selected register
        readRDR, writeTDR, readSCSR, readSCCR, writeSCCR : out std_logic
    );
end addressDecoder;

architecture structural of addressDecoder is

    signal w2, w1, w0 : std_logic;

    begin

    w2 <= addr(1);
    w1 <= addr(0);
    w0 <= R_Wbar;

    readRDR <= en and (not w2) and (not w1) and w0;
    writeTDR <= en and (not w2) and (not w1) and (not w0);
    readSCSR <= en and (not w2) and w1 and w0;
    readSCCR <= en and w2 and w0;
    writeSCCR <= en and w2 and (not w0);

end structural;