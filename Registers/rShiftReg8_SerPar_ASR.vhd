library IEEE;
USE IEEE.std_logic_1164.all;

-- this is a 8-bit right shift register with async set/reset and has serialIn for MSB when right shifting and PIPO
entity rShiftReg8_SerPar_ASR is
    port ( 
        par_in : in std_logic_vector(7 downto 0); -- parallel load inputs
        ser_in, par_load, rShift : in std_logic; -- serial load input, parallel load, right shift control signals
        -- note that parallel load takes precendence over rShift signals if both are active
        clock, set, reset : in std_logic; -- clock, async active-low set/reset
        par_out : out std_logic_vector(7 downto 0) -- register output
    );
end rShiftReg8_SerPar_ASR;

architecture structural of rShiftReg8_SerPar_ASR is

    -- d is dFF inputs, q is dFF outputs
   signal d, q : std_logic_vector(7 downto 0);

   component d_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_d, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    component m4to1 is
        port(
                d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
                q0 : out std_logic                      -- q0 is data output
        );
    end component;

    begin

    -- special logic for MSB
    mux_B7 : m4to1
    port map(
        d0 => q(7),
        d1 => ser_in,
        d2 => par_in(7),
        d3 => par_in(7),
        s0 => rShift,
        s1 => par_load,
        q0 => d(7)
    );

    -- rest of MUXes
    gen_mux4to1 : for i in 6 downto 0 generate
    mux_B : m4to1
    port map(
        d0 => q(i),
        d1 => q(i + 1),
        d2 => par_in(i),
        d3 => par_in(i),
        s0 => rShift,
        s1 => par_load,
        q0 => d(i)
    );
    end generate;

    -- generate the dFFs
    gen_dFF : for i in 7 downto 0 generate
    dFFB : d_FF_ASR
    port map (
        i_clock => clock,
        i_set => set,
        i_reset => reset,
        i_d => d(i),
        o_q => q(i),
        o_qBar => open
    );
    end generate;

    par_out <= q;


end architecture structural;