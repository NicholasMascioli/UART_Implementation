
library ieee;
use ieee.std_logic_1164.all;

-- MCU controller sets the control signals to load the correct sequence of bytes into the UART transmitter
-- this is part of the parent UARTController module
entity mcuFSM is 
    port( 
		clock, reset : in std_logic;
        IRQ, changeDetected, endMsg : in std_logic;
        selUART, R_Wbar, clearCIC, incCIC, ackChanged : out std_logic;
        address : out std_logic_vector(1 downto 0)
    );
end mcuFSM;

architecture structural of mcuFSM is

    signal ta, tb, a, aBar, b, bBar, w2, w1, w0 : std_logic;

    component t_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_t, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    begin

    w2 <= IRQ;
    w1 <= changeDetected;
    w0 <= endMsg;

    ta <= (aBar and b and (not w2) and (not w0)) or (a and bBar and w2);
    tb <= (aBar and bBar and w2 and w1) or (aBar and b and w0) or (a and b) or (a and bBar and w2);

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

    clearCIC <= aBar and bBar;
    selUART <= aBar and b;
    address <= "00";
    R_Wbar <= '0';
    incCIC <= a and b;
    ackChanged <= aBar and b;

end structural;