
library ieee;
use ieee.std_logic_1164.all;

entity transmitter is 
    port( 
		clock, reset : in std_logic;
        tdrDataIn : in std_logic_vector(7 downto 0);
        loadTDR, TDRE : in std_logic;
        TxD, setTDRE: out std_logic

        -- debug outputs
        -- parity_out_d, enTXCount_d, txCE_d, resetParity_d : out std_logic;
        -- count_d : out std_logic_vector(3 downto 0);
        -- TSR_out_d : out std_logic_vector(7 downto 0)

    );
end transmitter;

architecture structural of transmitter is

    -- sends control signals for all data path related components
    component transmitterController is 
    port( 
		clock, reset : in std_logic;
        txCE, TDRE : in std_logic;
        enTxCount, loadTSR, setTDRE, resetParity : out std_logic
    );
    end component;

    -- counts how many cycles have elapsed, TxCE signal activates when this counter is 0111 (8 cycles)
    component counter_4bit is
        port ( 
                    w, clock, reset : in std_logic;
                    z : out std_logic_vector(3 downto 0)
            );
    end component;

    -- register for TDR and TSR
    component rShiftReg8_SerPar_ASR is
        port ( 
            par_in : in std_logic_vector(7 downto 0); -- parallel load inputs
            ser_in, par_load, rShift : in std_logic; -- serial load input, parallel load, right shift control signals
            -- note that parallel load takes precendence over rShift signals if both are active
            clock, set, reset : in std_logic; -- clock, async active-low set/reset
            par_out : out std_logic_vector(7 downto 0) -- register output
        );
    end component;

    component parity is
        port ( 
                w, reset, clock : in std_logic;
                P : out std_logic
            );
    end component;

    component m2to1 is
        port(
                d0, d1, s0 : in std_logic;  -- d0, d1 are data inputs, s0 is select input
                q0 : out std_logic          -- q0 is data output
        );
    end component;

    signal enTxCount, txCE, loadTSR, txP, resetParity_ctrl, resetParity : std_logic;
    signal TDR_out, TSR_out : std_logic_vector(7 downto 0);
    signal count : std_logic_vector(3 downto 0);

    begin

    -- debug
    -- TSR_out_d <= TSR_out;
    -- parity_out_d <= txP;
    -- enTxCount_d <= enTxCount;
    -- txCE_d <= txCE;
    -- count_d <= count;
    -- resetParity_d <= resetParity;


    -- timer expires after reaching 1000 (dec8) (9 clock cycles)
    txCE <= count(3) and (not count(2)) and (not count(1)) and (not count(0));

    -- global reset active low, but reset parity active high
    resetParity <= reset and (not resetParity_ctrl);

    controller : transmitterController
    port map(
        clock => clock, 
        reset => reset,
        txCE => txCE, 
        TDRE => TDRE,
        enTxCount => enTxCount, 
        loadTSR => loadTSR, 
        setTDRE => setTDRE,
        resetParity => resetParity_ctrl
    );

    counter : counter_4bit
    port map(
        clock => clock,
        reset => reset,
        w => enTxCount,
        z => count
    );

    TDR : rShiftReg8_SerPar_ASR
    port map(
        par_in => TDRDataIn,
        ser_in => '0', -- never right shifting TDR (so never serial loading)
        par_load => loadTDR,
        rShift => '0', -- never right shifting TDR
        clock => clock,
        set => '1',
        reset => reset,
        par_out => TDR_out
    );

    TSR : rShiftReg8_SerPar_ASR
    port map(
        par_in => TDR_out,
        ser_in => '1', -- always loading 1 into MSB when right shifting
        par_load => loadTSR,
        rShift => '1', -- always right shifting TDR
        clock => clock,
        set => reset, -- resetting should set all bits to 1
        reset => '1',
        par_out => TSR_out
    );

    parityGenerator : parity
    port map(
        w => TSR_out(0), -- LSB of TSR is bit being transmitted
        reset => resetParity, 
        clock => clock,
        P => txP
    );

    txMux : m2to1
    port map(
        d0 => TSR_out(0),
        d1 => txP,
        s0 => txCE,
        q0 => TxD --  transmit output
    );

end structural;