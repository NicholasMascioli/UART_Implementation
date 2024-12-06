LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


-- 4 bit tally counter with increment, clear, and asynchronous set/reset
entity tally4b is
    port ( 
                clock, reset : in std_logic;
                inc, clear : in std_logic;
                z : out std_logic_vector(3 downto 0)
        );
end tally4b;

architecture structural of tally4b is

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

    component adder4bit is
        port(
            x, y : in std_logic_vector(3 downto 0);
            addbar_sub : in std_logic;
            s : out std_logic_vector(3 downto 0); 
            cOut : out std_logic
        );
    end component;

    signal d, q, s : std_logic_vector(3 downto 0);

    begin

    -- generate MUXes
    gen_mux4to1 : for i in 3 downto 0 generate
    mux_B : m4to1
    port map(
        d0 => q(i),
        d1 => s(i),
        d2 => '0',
        d3 => '0',
        s0 => inc,
        s1 => clear,
        q0 => d(i)
    );
    end generate;

    -- generate the dFFs
    gen_dFF : for i in 3 downto 0 generate
    dFFB : d_FF_ASR
    port map (
        i_clock => clock,
        i_set => '1', -- disable active low set
        i_reset => reset,
        i_d => d(i),
        o_q => q(i),
        o_qBar => open
    );
    end generate;

    incAdder : adder4bit
    port map(
        x => "0001", -- always increment by 1
        y => q,
        addbar_sub => '0', -- always add
        s => s, 
        cOut => open -- don't care about carry
    );

    z <= q;

end architecture structural;

            
            