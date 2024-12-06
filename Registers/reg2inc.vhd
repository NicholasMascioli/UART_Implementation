
library IEEE;
USE IEEE.std_logic_1164.all;

-- 2 bit register with increment function
entity reg2inc is
    port ( 
            d1, d0, clk, load, inc : in STD_LOGIC; 
            q1, q0 : out STD_LOGIC            
        );
end reg2inc;

architecture rtl of reg2inc is
    signal int_d1, int_d0 : std_logic;  -- mux outputs
    signal int_q1, int_q0 : std_logic;  -- dFF outputs

    component m4to1 
    port(
            d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
            q0 : out std_logic                      -- q0 is data output
    );
    end component;

    component d_FF 
	port(
                i_d, i_clock : IN STD_LOGIC;
                o_q, o_qBar : OUT STD_LOGIC
        );
    end component;
begin
    
    m1: m4to1 
    port map(
        d0 => int_q1, 
        d1 => d1, 
        d2 => int_q1 xor int_q0, -- if 01 we want msb to be 1 and if 10 we want msb to stay 1
        d3 => 'X', -- never occur
        s0 => load, 
        s1 => inc, 
        q0 => int_d1    
    );

    m0: m4to1 
    port map(
        d0 => int_q0, 
        d1 => d0, 
        d2 => not(int_q0), -- lsb is always alternating when incrementing
        d3 => 'X', -- never occur
        s0 => load, 
        s1 => inc, 
        q0 => int_d0 
    );


    r1: d_FF
    port map(
        i_d => int_d1,
        i_clock => clk,
        o_q => int_q1,
        o_qBar => open
    );
    
    r0: d_FF
    port map(
        i_d => int_d0,
        i_clock => clk,
        o_q => int_q0,
        o_qBar => open
    );
    
    q1 <= int_q1; 
    q0 <= int_q0; 
end architecture rtl;
            
            
