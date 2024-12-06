
library IEEE;
USE IEEE.std_logic_1164.all;

-- 1 bit register
entity reg1 is
    port ( 
            d0, clk, load : in STD_LOGIC;   -- d0 is input bit, clk is the clock signal, load is the command to load DFF with new data 
            q0 : out STD_LOGIC              -- q0 is the output bit
        );
end reg1;

architecture rtl of reg1 is
    signal int_d0 : std_logic;  -- Mux output signal
    signal int_q0 : std_logic;  -- DFF output signal

    component m2to1 
    port(
            d0, d1, s0 : in std_logic;
            q0 : out std_logic
    );
    end component;

    component d_FF 
	port(
                i_d, i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
    end component;
begin
    m0: m2to1 -- 2 to 1 Mux to control load. No load signal causes DFF to store previous state (no change)
    port map(
        d0 => int_q0,   -- Previous state
        d1 => d0,       -- New state
        s0 => load,
        q0 => int_d0
    );

    r0: d_FF
    port map(
        i_d => int_d0,
        i_clock => clk,
        o_q => int_q0,
        o_qBar => open
    );
        
    q0 <= int_q0; -- Load output with DFF output
end architecture rtl;
            
            
