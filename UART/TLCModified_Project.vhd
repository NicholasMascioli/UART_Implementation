
library ieee;
use ieee.std_logic_1164.all;

entity TLCModified_Project is 
    port( 
        MST, SST, SSCS, CE : in std_logic;
        clock, reset : in std_logic; -- active low reset
        MSTL, SSTL : out std_logic_vector(2 downto 0);
        ST, SC, SLC : out std_logic;
        state : out std_logic_vector(1 downto 0)
    );
end TLCModified_Project;

architecture structural of TLCModified_Project is

    signal ta, tb, a, b : std_logic;
    signal w : std_logic_vector(3 downto 0);

    component t_FF_ASR
	port(       
                i_set, i_reset : in std_logic;
                i_t, i_clock : in std_logic;
                o_q, o_qBar : out std_logic
        );
    end component;

    begin

    w(3) <= MST;
    w(2) <= SST;
    w(1) <= SSCS;
    w(0) <= CE;

    tFFa : t_FF_ASR
    port map(
        i_set => '1', -- disabled active low set
        i_reset => reset,
        i_t => ta,
        i_clock => clock,
        o_q => a,
        o_qbar => open
    );

    tFFb : t_FF_ASR
    port map(
        i_set => '1', -- disabled active low set
        i_reset => reset,
        i_t => tb,
        i_clock => clock,
        o_q => b,
        o_qbar => open
    );

    ta <= ((not A) and b and w(3)) or (a and b and w(2));
    tb <= ((not b) and w(0) and (((not a) and w(1)) or a)) or ta;
    MSTL(2) <= (not a) and (not b);
    MSTL(1) <= (not a) and b;
    MSTL(0) <= a;
    SSTL(2) <= a and (not b);
    SSTL(1) <= a and b;
    SSTL(0) <= not a;
    ST <= b;
    SC <= not b;
    SLC <= a and (not b);
    state <= a & b; -- concatenate state bits for state info output

end structural;