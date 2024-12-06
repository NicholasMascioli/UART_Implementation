LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 8 Bit OR block. Takes in two 8 bit values and outputs each bit ORed with each other.
entity bit8_or is
    port ( 
            x0, x1, x2, x3, x4, x5, x6, x7, y0, y1, y2, y3, y4, y5, y6, y7 : in std_logic;      -- x0-x7 and y0-y7 are input bits
            q0, q1, q2, q3, q4, q5, q6, q7 : out std_logic      -- ORed output
        );
end bit8_or;

architecture struct of bit8_or is
begin
        q0<= x0 or y0;  -- Or each bit
        q1<= x1 or y1;
        q2<= x2 or y2;
        q3<= x3 or y3;
        q4<= x4 or y4;
        q5<= x5 or y5;
        q6<= x6 or y6;
        q7<= x7 or y7;
end architecture struct;
            
            