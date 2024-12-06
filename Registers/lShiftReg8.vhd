library IEEE;
USE IEEE.std_logic_1164.all;

-- 8 Bit PIPO register that performs a left shift on the bits when the shiftL signal is high

-- shiftL=0 and load=0 = previous state
-- shiftL=1 and load-0 = shift right
-- shiftL=0 and load=1 = load
-- shiftL=1 and load=1 = NEVER HAPPEN


entity lshiftReg8 is
    Port(
        clk, shiftL, load, d0, d1, d2, d3, d4, d5, d6, d7:in std_logic; -- d0-d7 are input bits
        q0, q1, q2, q3, q4, q5, q6, q7 : out std_logic                  -- q0-q7 are output bits
    );
end entity lshiftReg8;


architecture rtl of lshiftReg8 is
    signal int_d0, int_d1, int_d2, int_d3, int_d4, int_d5, int_d6, int_d7 : std_logic;  -- Mux output signal
    signal int_q0, int_q1, int_q2, int_q3, int_q4, int_q5, int_q6, int_q7 : std_logic;  -- DFF output signal

    component m4to1
    port(
        d0, d1, d2, d3, s0, s1 : in std_logic;
        q0 : out std_logic
    );
    end component;

    component d_FF
	port(
        i_d : IN STD_LOGIC;
        i_clock : IN STD_LOGIC;
        o_q, o_qBar : OUT STD_LOGIC
    );
    end component;
begin 
    mux7: m4to1
    port map(
        d0 => int_q7,   -- Previous state (From DFF)
        d1 => int_q6,   -- Left shift bit 7 <= bit 6
        d2 => d7,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d7
    );

    mux6: m4to1
    port map(
        d0 => int_q6,   -- Previous state (From DFF)
        d1 => int_q5,   -- Left shift bit 6 <= bit 5   
        d2 => d6,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d6
    );

    mux5: m4to1
    port map(
        d0 => int_q5,   --...
        d1 => int_q4,   --...
        d2 => d5,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d5
    );

    mux4: m4to1
    port map(
        d0 => int_q4,
        d1 => int_q3,
        d2 => d4,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d4
    );

    mux3: m4to1
    port map(
        d0 => int_q3,
        d1 => int_q2,
        d2 => d3,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d3
    );

    mux2: m4to1
    port map(
        d0 => int_q2,
        d1 => int_q1,
        d2 => d2,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d2
    );

    mux1: m4to1
    port map(
        d0 => int_q1,
        d1 => int_q0,
        d2 => d1,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d1
    );

    mux0: m4to1
    port map(
        d0 => int_q0,
        d1 => int_q7,
        d2 => d0,
        d3 => '0',
        s0 => shiftL, 
        s1 => load,
        q0 => int_d0
    );

    r7: d_FF
    port map(
        i_d => int_d7,  -- mux7 output
        i_clock => clk,
        o_q => int_q7,
        o_qBar => open
    );

    r6: d_FF
    port map(
        i_d => int_d6, -- mux6 output
        i_clock => clk,
        o_q => int_q6,
        o_qBar => open
    );

    r5: d_FF
    port map(
        i_d => int_d5, --...
        i_clock => clk,
        o_q => int_q5,
        o_qBar => open
    );

    r4: d_FF
    port map(
        i_d => int_d4,
        i_clock => clk,
        o_q => int_q4,
        o_qBar => open
    );

    r3: d_FF
    port map(
        i_d => int_d3,
        i_clock => clk,
        o_q => int_q3,
        o_qBar => open
    );

    r2: d_FF
    port map(
        i_d => int_d2,
        i_clock => clk,
        o_q => int_q2,
        o_qBar => open
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

    -- Load output bits
    q7 <= int_q7;
    q6 <= int_q6;
    q5 <= int_q5;
    q4 <= int_q4;
    q3 <= int_q3;
    q2 <= int_q2;
    q1 <= int_q1;
    q0 <= int_q0;
end architecture rtl;