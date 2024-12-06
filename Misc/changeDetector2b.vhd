LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 2-bit change detector. Outputs 1 when either of the bits change
-- Output must be "acknowledged" (cleared) after a change was detected
entity changeDetector2b is
    port ( 
            clock, reset, ack : in std_logic;
            w : in std_logic_vector(1 downto 0);
            q : out std_logic
        );
end changeDetector2b;

architecture struct of changeDetector2b is

    component d_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_d, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    signal presentB, changedB : std_logic_vector(1 downto 0);
    signal presentQ, nextQ : std_logic;

begin

    -- set output if change was detected in either bit
    -- clear output if ack received
    nextQ <= (presentQ and (not ack)) or ((not presentQ) and (changedB(0) or changedB(1)));

    -- change occurs if present bits != input
    changedB <= presentB xor w;
    q <= presentQ;

    dFF_q: d_FF_ASR
    port map (
        i_clock => clock,
        i_set => '1', -- disable active low set
        i_reset => reset,
        i_d => nextQ,
        o_q => presentQ,
        o_qBar => open
    );

    dFF1 : d_FF_ASR
    port map (
        i_clock => clock,
        i_set => '1', -- disable active low set
        i_reset => reset,
        i_d => w(1),
        o_q => presentB(1),
        o_qBar => open
    );

    dFF0 : d_FF_ASR
    port map (
        i_clock => clock,
        i_set => '1', -- disable active low set
        i_reset => reset,
        i_d => w(0),
        o_q => presentB(0),
        o_qBar => open
    );

    

end architecture struct;
            
            