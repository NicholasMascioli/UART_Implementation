library IEEE;
USE IEEE.std_logic_1164.all;

entity uart_total is
    port ( 
        clock, reset, RxD : in std_logic;
        state : in std_logic_vector(1 downto 0);
        TxD : out std_logic;
        RDR : out std_logic_vector(7 downto 0)

    );
end uart_total;

architecture struct of uart_total is
    signal  selectE, R_W, irq_sig: std_logic;
    signal dMtoU, dUtoM  : std_logic_vector(7 downto 0);
    signal addy  : std_logic_vector(1 downto 0);

    

    component uart_fsm is 
    port( 
        -- inputs
		clock, reset : in std_logic;
        state : in std_logic_vector(1 downto 0);
        IRQ : in std_logic;
        dataUtoM : in std_logic_vector(7 downto 0);

        -- outputs
        address : out std_logic_vector(1 downto 0);
        selUART, R_Wbar : out std_logic;
        dataMtoU : out std_logic_vector(7 downto 0);

        -- debug
        CICcount_d : out std_logic_vector(3 downto 0);
        clearCIC_d, incCIC_d, ackChanged_d, changeDetected_d, endMSG_d: out std_logic
    );
    end component;

    component uart_module is
        port ( 
            clock, select_en, R_Wbar, RxD, reset : in std_logic;
            addr : in std_logic_vector(1 downto 0);
            dataMtoU : in std_logic_vector(7 downto 0);
            dataUtoM, RDR : out std_logic_vector(7 downto 0);
            irq, TxD : out std_logic
        );
    end component;

    begin

    module :uart_module
    port map(
        clock => clock,
        select_en => selectE, 
        R_Wbar => R_W,
        RxD => RxD,
        reset => reset,
        addr => addy,
        dataMtoU => dMtoU,
        dataUtoM => dUtoM, 
        RDR => RDR,
        irq => irq_sig, 
        TxD => TxD
    );

    fsm : uart_fsm
    port map(
        -- inputs
		clock => clock,
        reset => reset,
        state => state,
        IRQ => irq_sig,
        dataUtoM => dUtoM,
        -- outputs
        address => addy,
        selUART => selectE, 
        R_Wbar => R_W,
        dataMtoU => dMtoU,

        -- debug
        CICcount_d => open,
        clearCIC_d => open,
        incCIC_d => open,
        ackChanged_d => open, 
        changeDetected_d => open, 
        endMSG_d => open
    );


end struct;