LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity divider_256 is
    port ( 
            clock, reset : in std_logic;
            divide : out std_logic_vector(7 downto 0)
        );
end divider_256;

architecture struct of divider_256 is
    signal int_divide : std_logic_vector(7 downto 0) := (others => '0'); -- Start low

    component t_FF_ASR is 
        port( 
            i_set, i_reset : IN STD_LOGIC;
            i_t : IN STD_LOGIC;
            i_clock : IN STD_LOGIC;
            o_q, o_qBar : OUT STD_LOGIC
        );
    end component;
begin

    -- T-FF for LSB
    tff_0: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => clock,   -- Directly driven by the input clock
        o_q => int_divide(0), 
        o_qBar => open
    );

    -- T-FFs for the remaining bits with inverted clock
    tff_1: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(0), -- Invert to match clock edge
        o_q => int_divide(1), 
        o_qBar => open
    );

    tff_2: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(1), -- Invert to match clock edge
        o_q => int_divide(2), 
        o_qBar => open
    );

    tff_3: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(2), -- Invert to match clock edge
        o_q => int_divide(3), 
        o_qBar => open
    );

    tff_4: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(3), -- Invert to match clock edge
        o_q => int_divide(4), 
        o_qBar => open
    );

    tff_5: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(4), -- Invert to match clock edge
        o_q => int_divide(5), 
        o_qBar => open
    );

    tff_6: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(5), -- Invert to match clock edge
        o_q => int_divide(6), 
        o_qBar => open
    );

    tff_7: t_FF_ASR
    port map(
        i_set => '1', 
        i_reset => reset,
        i_t => '1',
        i_clock => NOT int_divide(6), -- Invert to match clock edge
        o_q => int_divide(7), 
        o_qBar => open
    );

    -- Assign outputs
    divide(7) <= int_divide(7); -- /256
    divide(6) <= int_divide(6); -- /128
    divide(5) <= int_divide(5); -- /64
    divide(4) <= int_divide(4); -- /32
    divide(3) <= int_divide(3); -- /16
    divide(2) <= int_divide(2); -- /8
    divide(1) <= int_divide(1); -- /4
    divide(0) <= int_divide(0); -- /2

end architecture struct;
