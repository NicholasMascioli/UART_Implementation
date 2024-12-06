
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity baud is
    port ( 
            input_clk, reset : in std_logic;
            sel : in std_logic_vector(2 downto 0);
            BClkx8, BClk : out std_logic
        );
end baud;

architecture struct of baud is
    signal i_41, muxOut : std_logic;
    signal divided : std_logic_vector(7 downto 0);
    signal divided_8 : std_logic_vector(7 downto 0);


    component divider_41 is
        port (
            clk_in   : in  std_logic;  -- Input clock signal
            reset    : in  std_logic;  -- Asynchronous reset
            clk_out  : out std_logic   -- Divided clock output
        );
    end component;

    component divider_256 is
        port ( 
                clock, reset : in std_logic;
                divide : out std_logic_vector(7 downto 0)
            );
    end component;

    component m8to1 is
        port(
                d : in std_logic_vector(7 downto 0); -- Data inputs
                s: in std_logic_vector(2 downto 0); --Select inputs
                q : out std_logic -- Data outputs
        );
    end component;

begin

    d_by_41 :divider_41
    port map(
        clk_in => input_clk, 
        reset => not reset,
        clk_out => i_41
    );

    divider : divider_256
    port map(
        clock => i_41,
        reset => reset,
        divide => divided
    );

    mux : m8to1
    port map(
        d => divided,
        s => sel,
        q => muxOut
    );

    divider_8 : divider_256
    port map(
        clock => muxOut,
        reset => reset,
        divide => divided_8
    );

    BClkx8 <= muxOut;
    BClk <= divided_8(2);

end architecture struct;
            
            
