
library IEEE;
USE IEEE.std_logic_1164.all;

-- 1 bit register, with reset input
entity reg1reset is
    port ( 
            d0, clk, reset, load : in STD_LOGIC;   -- d0 is input bit, clk is the clock signal, load is the command to load DFF with new data, and reset sets DFF value to 0
            q0 : out STD_LOGIC              -- q0 is  output bit
        );
end reg1reset;

architecture rtl of reg1reset is
    signal int_d0 : std_logic;  -- Mux output signal
    signal int_q0 : std_logic;  -- DFF output signal

    component m4to1 
    port(
        d0, d1, d2, d3, s0, s1 : in std_logic;  
        q0 : out std_logic    
    );
    end component;

    component d_FF 
	port(
                i_d, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;
begin
    m0: m4to1 -- 4 to 1 Mux to control load and reset. No load signal causes DFF to store previous state (no change)
    port map(
        d0 => int_q0,   -- Previous state
        d1 => d0,       -- New state
        d2 => '0',      -- Reset 
        d3 => 'X',
        s0 => load,
        s1 => reset,
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
            
            
