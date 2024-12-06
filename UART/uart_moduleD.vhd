library IEEE;
USE IEEE.std_logic_1164.all;

entity uart_moduleD is
    port ( 
        clock, BClk, BClkx8, select_en, R_Wbar, RxD, reset : in std_logic;
        addr : in std_logic_vector(1 downto 0);
        dataMtoU : in std_logic_vector(7 downto 0);
        dataUtoM : out std_logic_vector(7 downto 0);
        irq, TxD : out std_logic;
        i_readRDRD, i_writeTDRD, i_readSCSRD, i_readSCCRD, i_writeSCCRD, TDRES_OUT : out std_logic;
        SCCR_outD, SCSR_outD, RDR : out std_logic_vector(7 downto 0)
    );
end uart_moduleD;

architecture struct of uart_moduleD is
    signal i_readRDR, i_writeTDR, i_readSCSR, i_readSCCR, i_writeSCCR : std_logic;
    signal SCCR_out, SCSR_out, RDR_out, SCSR_Set, SCSR_Reset : std_logic_vector(7 downto 0);
    -- signal BClk, BClkx8 : std_logic;
    signal RDRFS, RDRFR, TDRES : std_logic;

    component addressDecoder is 
        port( 
            en, R_Wbar : in std_logic;
            addr : in std_logic_vector(1 downto 0); -- address of selected register
            readRDR, writeTDR, readSCSR, readSCCR, writeSCCR : out std_logic
        );
    end component;

    component transmitter is 
    port( 
		clock, reset : in std_logic;
        tdrDataIn : in std_logic_vector(7 downto 0);
        loadTDR, TDRE : in std_logic;
        TxD, setTDRE: out std_logic
    );
    end component;

    component receiver is
        port ( 
            RRDR, RxD, RDRF, OE, FE: in std_logic; -- serial and load in signal
            BClk, BClkx8, reset : in std_logic; -- clock, async active-low set/reset
            RDRFS, RDRFR, OE_out, FE_out : out std_logic; 
            bus_out : out std_logic_vector(7 downto 0) -- register output
        );
    end component;

    component baud is
        port ( 
                input_clk, reset : in std_logic;
                sel : in std_logic_vector(2 downto 0);
                BClkx8, BClk : out std_logic
            );
    end component;

    component reg8_ba is
        port ( 
                i_clock, i_load, i_set, i_reset : in std_logic;
                i_d, i_setB, i_resetB : in std_logic_vector(7 downto 0);
                o_q : out std_logic_vector(7 downto 0)
            );
    end component;

    component m8x4to1 is
        port (
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output         
        );
    end component;

    component m4to1 is
        port(
                d0, d1, d2, d3, s0, s1 : in std_logic;  -- d0, d1, d2, d3 are data inputs, s0, s1 are select inputs
                q0 : out std_logic                      -- q0 is data output
        );
    end component;

begin

    transmitter_mod : transmitter
    port map(
        clock => BClk, 
        reset => reset,
        tdrDataIn => dataMtoU,
        loadTDR => i_writeTDR, 
        TDRE => (SCSR_out(7)),
        TxD => TxD, 
        setTDRE => TDRES
    );
    TDRES_OUT <= TDRES;

    receiver_mod : receiver
    port map(
        RRDR => i_readRDR, 
        RxD => RxD, 
        RDRF => SCSR_out(6), 
        OE => SCSR_out(1), 
        FE => SCSR_out(0),
        BClk => BClk, 
        BClkx8 => BClkx8, 
        reset => reset,
        RDRFS => RDRFS,
        RDRFR => RDRFR, 
        OE_out => open, 
        FE_out => open,
        bus_out => RDR_out
    );
    RDR <= RDR_out;

    add_decoder : addressDecoder
    port map(
        en => select_en, 
        R_Wbar => R_Wbar,
        addr => addr,
        readRDR => i_readRDR, 
        writeTDR => i_writeTDR, 
        readSCSR => i_readSCSR, 
        readSCCR => i_readSCCR, 
        writeSCCR => i_writeSCCR
    );
    i_readRDRD <= i_readRDR;
    i_writeTDRD <= i_writeTDR;
    i_readSCSRD <= i_readSCSR;
    i_readSCCRD <= i_readSCCR;
    i_writeSCCRD  <= i_writeSCCR;


    SCCR : reg8_ba
    port map(
        i_clock => clock, 
        i_load => i_writeSCCR, 
        i_set => '1', 
        i_reset => reset,
        i_d => dataMtoU, 
        i_setB => "11000000", 
        i_resetB => "00000000", 
        o_q => SCCR_out
    );
    SCCR_outD <= SCCR_out; 
    SCSR_outD <= SCSR_out;

    SCSR : reg8_ba
    port map(
        i_clock => clock, 
        i_load => not(reset), 
        i_set => '1', 
        i_reset => '1',
        i_d => "10000000", 
        i_setB => SCSR_Set, 
        i_resetB => SCSR_Reset, 
        o_q => SCSR_out
    );
    SCSR_Set(0) <= '0';
    SCSR_Set(1) <= '0';
    SCSR_Set(2) <= '0';
    SCSR_Set(3) <= '0';
    SCSR_Set(4) <= '0';
    SCSR_Set(5) <= '0';
    SCSR_Set(6) <= RDRFS;
    SCSR_Set(7) <= TDRES;
    
    SCSR_Reset(0) <= '0';
    SCSR_Reset(1) <= '0';
    SCSR_Reset(2) <= '0';
    SCSR_Reset(3) <= '0';
    SCSR_Reset(4) <= '0';
    SCSR_Reset(5) <= '0';
    SCSR_Reset(6) <= RDRFR; -- or i_readRDR;
    SCSR_Reset(7) <= i_writeTDR;

    mux_8x4to1 : m8x4to1
    port map(
        d0 =>RDR_out, 
        d1 => SCSR_out, 
        d2 => SCCR_out, 
        d3 => SCCR_out,
        s0 => i_readSCSR, 
        s1 => i_readSCCR,
        q => dataUtoM
    );

    mux_4to1 : m4to1
    port map(
        d0 => '0', 
        d1 => SCSR_out(6) or SCSR_out(0), 
        d2 => SCSR_out(7), 
        d3 => SCSR_out(6) or SCSR_out(0) or SCSR_out(7), 
        s0 => SCCR_out(6), 
        s1 => SCCR_out(7),
        q0 => irq
    );

    -- baud_gen : baud
    -- port map(
    --     input_clk => clock, 
    --     reset => reset, 
    --     sel => SCCR_out(2 downto 0),
    --     BClkx8 => BClkx8, 
    --     BClk => BClk
    -- );

end struct;