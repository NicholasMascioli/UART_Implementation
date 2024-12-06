LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 4 bit counter, that counts up 1 bit at a time when w is active.
-- When w is low, the counter always stays at 0.

entity counter_3bit is
    port ( 
                w, clock, reset : in std_logic;
                z : out std_logic_vector(2 downto 0)
        );
end counter_3bit;

architecture struct of counter_3bit is
signal Y_in : std_logic_vector(2 downto 0);
signal y_out : std_logic_vector(2 downto 0);

        component d_FF_ASR
        port(
                i_set, i_reset : IN STD_LOGIC;
                i_d : IN STD_LOGIC;
                i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
            );
        end component;
begin

        -- Excitation equations derived from state table
        Y_in(2) <= w and (y_out(2) or (y_out(1) and y_out(0)));
        Y_in(1) <= w and ((not(y_out(1)) and y_out(0)) or (y_out(1) and not(y_out(0))) or (y_out(2) and y_out(1)));
        Y_in(0) <= w and (not(y_out(0)) or (y_out(2) and y_out(1)));

        dff_2 : d_FF_ASR
        port map(
                i_set => '1', -- 1 disables active low set 
                i_reset => reset,
                i_d => Y_in(2), 
                i_clock => clock,
                o_q => y_out(2), 
                o_qBar => open
        );

        dff_1 : d_FF_ASR
        port map(
                i_set => '1', -- 1 disables active low set 
                i_reset => reset,
                i_d => Y_in(1), 
                i_clock => clock,
                o_q => y_out(1), 
                o_qBar => open
        );

        dff_0 : d_FF_ASR
        port map(
                i_set => '1', -- 1 disables active low set
                i_reset => reset,
                i_d => Y_in(0), 
                i_clock => clock,
                o_q => y_out(0), 
                o_qBar => open
        );

        -- Counter output matches the state outputs
        z(2)<=y_out(2);
        z(1)<=y_out(1);
        z(0)<=y_out(0);
end architecture struct;

            
            