LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 2 bit timer. Used to represent the yellow light timers in the traffic light controller.
-- Sst (Side street timer) is active after 2 counts
-- Mst (Main street timer) is active after 4 counts

entity timer_2bit is
    port ( 
            w, clock, reset : in std_logic;
            sst, mst : out std_logic
        );
end timer_2bit;

architecture struct of timer_2bit is
    signal Y_in : std_logic_vector(1 downto 0);
    signal y_out : std_logic_vector(1 downto 0);

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
    Y_in(1) <= w and (y_out(0) or y_out(1));
    Y_in(0) <= w and (not(y_out(0)) or y_out(1));

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

    -- Output equations derived from state table
    sst <= y_out(0) or y_out(1);
    mst <= y_out(0) and y_out(1);
end architecture struct;
            
            