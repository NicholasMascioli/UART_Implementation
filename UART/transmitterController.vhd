
library ieee;
use ieee.std_logic_1164.all;

-- transmitter controller sets the control signals to serially transmit a byte placed in the TDR register
-- of the parent transmitter module
entity transmitterController is 
    port( 
		clock, reset : in std_logic;
        txCE, TDRE : in std_logic;
        enTxCount, loadTSR, setTDRE, resetParity : out std_logic
    );
end transmitterController;

architecture structural of transmitterController is

    signal ta, tb, a, aBar, b, bBar, w1, w0 : std_logic;

    component t_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_t, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    begin

    w1 <= TxCE;
    w0 <= TDRE;

    ta <= (aBar and b) or (a and b and w1);
    tb <= (aBar and bBar and (not w0)) or (a and b and w1);

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

    enTxCount <= a and b;
    loadTSR <= aBar and b;
	setTDRE <= aBar and b;
    resetParity <= aBar and b;

end structural;