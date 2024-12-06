
library ieee;
use ieee.std_logic_1164.all;

-- receiver controller FSM sets the control signals to serially receive a byte from the RxD line
entity receiverFSM is 
    port( 
	    clockd8, clock, reset : in std_logic;
        RxD, RRDR, P : in std_logic;
        LRDR, RDRFR, RDRFS, LRSR, OE, FE: out std_logic;
        count : out std_logic_vector(3 downto 0)
    );
end receiverFSM;

architecture struct of receiverFSM is
    signal c_out : std_logic_vector(3 downto 0);
    signal ta, tb, a, aBar, b, bBar, i_Do, i_L3BC : std_logic;
    signal f : std_logic;

    component t_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_t, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    component counter_4bit is
        port ( 
                    w, clock, reset : in std_logic;
                    z : out std_logic_vector(3 downto 0)
            );
    end component;

    begin
    
    -- Counter value (11)
    i_Do <= (c_out(3) and not(c_out(2)) and not(c_out(1)) and (c_out(0)));
    
    -- State toggle inputs
    ta <= (aBar and b and i_Do) or (a and bBar and RRDR);
    tb <= (aBar and bBar and not(Rxd)) or (a and b);


    tFFa : t_FF_ASR
    port map(
        i_set => '1', -- disabled active low set
        i_reset => reset,
        i_t => ta,
        i_clock => clock,
        o_q => a,
        o_qbar => aBar
    );

    tFFb : t_FF_ASR
    port map(
        i_set => '1', -- disabled active low set
        i_reset => reset,
        i_t => tb,
        i_clock => clock,
        o_q => b,
        o_qbar => bBar
    );
    
    -- Counter counts how many bits have arrived
    counter : counter_4bit
    port map(
        w => i_L3BC, 
        clock => clockd8, 
        reset => reset,
        z => c_out
    );
    

    -- Set outputs
    RDRFR <= aBar and bBar;
    RDRFS <= a and b;
    i_L3BC <= aBar and b;
    LRSR <= aBar and b;
    LRDR <= a and b;

    -- No error catching functionality (No information in Project doc on how to implement)
    OE <= '0';
    FE <= '0';

end struct;