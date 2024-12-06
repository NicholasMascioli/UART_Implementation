
library ieee;
use ieee.std_logic_1164.all;

entity uart_fsm is 
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
end uart_fsm;

architecture structural of uart_fsm is

    component mcuFSM is 
    port( 
		clock, reset : in std_logic;
        IRQ, changeDetected, endMsg : in std_logic;
        selUART, R_Wbar, clearCIC, incCIC, ackChanged : out std_logic;
        address : out std_logic_vector(1 downto 0)
    );
    end component;

    -- counts the index of the current character to be sent in the message
    component tally4b is
        port ( 
            clock, reset : in std_logic;
            inc, clear : in std_logic;
            z : out std_logic_vector(3 downto 0)
        );
    end component;

    component changeDetector2b is
        port ( 
                clock, reset, ack : in std_logic;
                w : in std_logic_vector(1 downto 0);
                q : out std_logic
            );
    end component;

    component charDecoder is 
    port( 
        state : in std_logic_vector(1 downto 0); -- current traffic light controller state
        index : in std_logic_vector(2 downto 0); -- index of character in debug message
        q : out std_logic_vector(7 downto 0) -- output UART character byte
    );
    end component;

    signal clearCIC, incCIC, ackChanged, endMSG, changeDetected : std_logic;
    signal CICcount : std_logic_vector(3 downto 0);
    signal slice3bCICcount : std_logic_vector(2 downto 0);

    begin

    endMSG <= CICcount(2) and CICcount(0); -- endMSG on "0101" (5th index)
    slice3bCICcount <= CICcount(2 downto 0);

    -- debug
    CICcount_d <= CICcount;
    clearCIC_d <= clearCIC;
    incCIC_d <= incCIC;
    ackChanged_d <= ackChanged;
    changeDetected_d <= changeDetected;
    endMSG_d <= endMSG;

    mcu : mcuFSM
    port map (
        clock => clock, 
        reset => reset,
        IRQ => IRQ, 
        changeDetected => changeDetected,
        endMsg => endMSG, 
        selUART => selUART,
        R_Wbar => R_Wbar,
        clearCIC => clearCIC,
        incCIC => incCIC,
        ackChanged => ackChanged,
        address => address
    );

    CIC : tally4b
    port map(
        clock => clock,
        reset => reset,
        inc => incCIC,
        clear => clearCIC,
        z => CICcount
    );

    changeDetector : changeDetector2b
    port map ( 
            clock => clock, 
            reset => reset, 
            ack => ackChanged,
            w => state,
            q => changeDetected
    );

    charDec : charDecoder
    port map( 
        state => state,
        index => slice3bCICcount,
        q => dataMtoU -- directly outputting char data, as this is the only purpose of the uart fsm currently
    );

end structural;