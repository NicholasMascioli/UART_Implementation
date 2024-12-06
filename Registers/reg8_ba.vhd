library IEEE;
USE IEEE.std_logic_1164.all;

-- 8-bit bit addressable register
entity reg8_ba is
    port ( 
            -- i_load enables parallel load
            -- i_set/i_reset are asyncronous set/reset for all register bits
            -- i_d is parallel load input
            -- i_setB/i_resetB are synchronous bit addressed set and reset
            -- ioq is parellel register output

            i_clock, i_load, i_set, i_reset : in std_logic;
            i_d, i_setB, i_resetB : in std_logic_vector(7 downto 0);
            o_q : out std_logic_vector(7 downto 0)
        );
end reg8_ba;

architecture structural of reg8_ba is

    -- int_d is input to DFFs from multiplexers
    -- q is output of DFFs
    -- b is the "bit" wire which carries the previous state bit or the bitwise set/reset override signals

    signal int_d, int_q, int_b: std_logic_vector(7 downto 0);


    component m2to1 is
        port(
                d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
                q0 : out std_logic          -- q0 is data output
        );
    end component;

    component d_FF_ASR is
    PORT(
                i_set, i_reset : in std_logic;
                i_d : in std_logic;
                i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

begin

    -- bitwise assignment of int_b where 
    -- int_b(i) = (int_q(i) or i_setB(i)) and (not i_resetB(i))
    -- reset(Bi)    setB(i)     q(i)_Next
    --   0            0           q(i)           
    --   0            1           1
    --   1            0           0
    --   1            1           0
    int_b <= (int_q or i_setB) and (not i_resetB);

    gen_m2to1 : for i in 7 downto 0 generate
        MuxD : m2to1
        port map (
            d0 => int_b(i),
            d1 => i_d(i),
            s0 => i_load,
            q0 => int_d(i)
        );
    end generate;

    gen_dFF : for i in 7 downto 0 generate
        dFFB : d_FF_ASR
        port map (
            i_clock => i_clock,
            i_set => i_set,
            i_reset => i_reset,
            i_d => int_d(i),
            o_q => int_q(i),
            o_qBar => open
        );
    end generate;

    -- bitwise assign outputs
    o_q <= int_q;

end architecture structural;
            
            