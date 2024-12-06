library IEEE;
USE IEEE.std_logic_1164.all;

-- 4 Bit PIPO register that performs a left shift on the bits when the shiftL signal is high
-- and also has a special set 0 bit command

-- shiftL=0 and load=0 = previous state
-- shiftL=1 and load-0 = shift right
-- shiftL=0 and load=1 = load
-- shiftL=X and load=X and set0 = load bit 0 with d_set0

entity lSReg4_0Bit is
    Port(
        clk, shiftL, load, set0, d_set0, d0, d1, d2, d3:in std_logic; -- d0-d3 are input bits
        q0, q1, q2, q3 : out std_logic                  -- q0-q3 are output bits
    );
end lSReg4_0Bit;


architecture rtl of lSReg4_0Bit is
    signal int_d0, int_d1, int_d2, int_d3 : std_logic;  -- Mux output signal
    signal int_q0, int_q1, int_q2, int_q3 : std_logic;  -- DFF output signal
    signal int_s1, int_s0 : std_logic;                  -- Select signals

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
    int_s1 <= load or set0;     -- Set0 is equivalent 11 input for mux
    int_s0 <= shiftL or set0;

    mux3: m4to1
    port map(
        d0 => int_q3, -- Previous state (From DFF)
        d1 => int_q2, -- Left shift bit 3 <= bit 2
        d2 => d3,
        d3 => int_q3,
        s0 => int_s0, 
        s1 => int_s1,
        q0 => int_d3
    );

    mux2: m4to1
    port map(
        d0 => int_q2, -- Previous state (From DFF)
        d1 => int_q1, -- Left shift bit 2 <= bit 1 
        d2 => d2,
        d3 => int_q2,
        s0 => int_s0, 
        s1 => int_s1,
        q0 => int_d2
    );

    mux1: m4to1
    port map(
        d0 => int_q1,  --...
        d1 => int_q0,  --...
        d2 => d1,
        d3 => int_q1,
        s0 => int_s0, 
        s1 => int_s1,
        q0 => int_d1
    );

    mux0: m4to1
    port map(
        d0 => int_q0,
        d1 => int_q3,
        d2 => d0,
        d3 => d_set0, -- load d0 with d_set0 when set0 is active
        s0 => int_s0, 
        s1 => int_s1,
        q0 => int_d0
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
    q3 <= int_q3;
    q2 <= int_q2;
    q1 <= int_q1;
    q0 <= int_q0;
end architecture rtl;