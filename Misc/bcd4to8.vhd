LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4bit to 8 bit binary coded decimal converter

entity bcd4to8 is
    port(
        d : in std_logic_vector(3 downto 0);
        z1,z0 : out std_logic_vector(3 downto 0)
    );
end bcd4to8;

architecture struct of bcd4to8 is
    begin

        
        z1(3) <= '0'; -- 4 bits does not exceed 15, therefore second bcd bit will only ever by 0001
        z1(2) <= '0'; -- "                                                                        "
        z1(1) <= '0'; -- "                                                                        "

        -- Equations derived from table
        z1(0) <= ((d(3) and d(2)) or (d(3) and d(1)));
        z0(3) <= d(3) and not(d(2)) and not(d(1));
        z0(2) <= ((not(d(3)) and d(2)) or (d(2) and d(1)));
        z0(1) <= ((not(d(3)) and d(1)) or (d(3) and d(2) and not(d(1))));
        z0(0) <= d(0);
end architecture struct;