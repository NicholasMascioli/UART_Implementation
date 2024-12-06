library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider_41 is
    port (
        clk_in   : in  std_logic;  -- Input clock signal
        reset    : in  std_logic;  -- Asynchronous reset
        clk_out  : out std_logic   -- Divided clock output
    );
end divider_41;

architecture behavior of divider_41 is
    signal counter : unsigned(5 downto 0) := (others => '0'); -- 6-bit counter (to count up to 41)
    signal clk_out_int : std_logic := '0'; -- Internal clock output
begin
    -- Process for clock division
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');  -- Reset counter to 0
            clk_out_int <= '0';         -- Reset output clock
        elsif rising_edge(clk_in) then
            if counter = 20 then        -- Count reaches 41 (40 + 1 because count starts at 0)
                counter <= (others => '0');  -- Reset counter
                clk_out_int <= not clk_out_int; -- Toggle output clock
            else
                counter <= counter + 1; -- Increment counter
            end if;
        end if;
    end process;

    clk_out <= clk_out_int; -- Assign internal signal to output

end architecture behavior;
