library IEEE;
USE IEEE.std_logic_1164.all;

entity receiver is
    port ( 
        RRDR, RxD, RDRF, OE, FE: in std_logic; -- serial and load in signal
        BClk, BClkx8, reset : in std_logic; -- clock, async active-low set/reset
        RDRFS, RDRFR, OE_out, FE_out : out std_logic; 
        bus_out : out std_logic_vector(7 downto 0) -- register output
    );
end receiver;

architecture struct of receiver is
    signal RSR_out : std_logic_vector(7 downto 0);
    signal i_LRSR, i_LRDR, i_L3BC, p_out : std_logic;
    signal c_out : std_logic_vector(2 downto 0);

    component rShiftReg8_SerPar_ASR is
        port ( 
            par_in : in std_logic_vector(7 downto 0); -- parallel load inputs
            ser_in, par_load, rShift : in std_logic; -- serial load input, parallel load, right shift control signals
            -- note that parallel load takes precendence over rShift signals if both are active
            clock, set, reset : in std_logic; -- clock, async active-low set/reset
            par_out : out std_logic_vector(7 downto 0) -- register output
        );
    end component;

    component receiverFSM is 
    port( 
		clockd8, clock, reset : in std_logic;
      RxD, RRDR, P : in std_logic;
      LRDR, RDRFR, RDRFS, LRSR, OE, FE: out std_logic;
      count : out std_logic_vector(3 downto 0)
    );
    end component;

    component parity is
        port ( 
                w, reset, clock : in std_logic;
                P : out std_logic
            );
    end component;

    component counter_3bit is
        port ( 
                    w, clock, reset : in std_logic;
                    z : out std_logic_vector(2 downto 0)
            );
    end component;

begin

    RDR: rShiftReg8_SerPar_ASR
    port map(
        par_in => RSR_out,
        ser_in => '0',
        par_load => i_LRDR, 
        rShift => '0',
        clock => BClkx8, 
        set => '1', 
        reset => reset,
        par_out => bus_out
    );

    RSR: rShiftReg8_SerPar_ASR
    port map(
        par_in => "00000000",
        ser_in => RxD,
        par_load => '0', 
        rShift => i_LRSR,
        clock => BClk, 
        set => '1', 
        reset => reset,
        par_out => RSR_out
    );

    par : parity
    port map(
        w => RxD, 
        reset => reset, 
        clock => BClkx8,
        P => p_out
    );

    fsm : receiverFSM
    port map(
		clockd8 => BClk,
		clock => BClkx8, 
        reset => reset,
        RxD => RxD, 
        RRDR => RRDR, 
        P => p_out,

        LRDR => i_LRDR, 
        RDRFS => RDRFS, 
        RDRFR => RDRFR, 
        LRSR => i_LRSR, 
        OE => OE_out, 
        FE => FE_out
    );

end struct;