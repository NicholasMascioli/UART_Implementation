LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity parity is
    port ( 
            w, reset, clock : in std_logic;
            P : out std_logic
        );
end parity;

architecture struct of parity is
    signal int_dY, int_y : std_logic;
    component d_FF_ASR IS
        port(
                    i_set, i_reset : IN STD_LOGIC;
                    i_d : IN STD_LOGIC;
                    i_clock : IN STD_LOGIC;
                    o_q, o_qBar : OUT STD_LOGIC
            );
    end component;
begin
    int_dY <= (int_y and not(w)) or(not(int_y) and w);

    dFF_1: d_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_d => int_dY,
        i_clock => clock, 
        o_q => int_y, 
        o_qBar => open
    );

    p<=int_y;

end architecture struct;
            
            