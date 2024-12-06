
library ieee;
use ieee.std_logic_1164.all;

-- Decoder designed to output the correct 
-- debug message character byte at a given index given the current state
-- The 6-character debug message is Mx_Sx where x is a color status 
-- character (g, y, r) and the message is followed by a carriage return
entity charDecoder is 
    port( 
        state : in std_logic_vector(1 downto 0); -- current traffic light controller state
        index : in std_logic_vector(2 downto 0); -- index of character in debug message
        q : out std_logic_vector(7 downto 0) -- output UART character byte
    );
end charDecoder;

architecture structural of charDecoder is

    component m8x4to1 is
        port (
            d0, d1, d2, d3 : in std_logic_vector(7 downto 0);   -- d0, d1, d2, d3 are 8 bit data inputs
            s0, s1 : in std_logic;                              -- s0, s1 are select inputs
            q : out std_logic_vector(7 downto 0)                -- q0 is 8 bit data output         
        );
    end component;

    component m8x8to1 is
        port (
            d0, d1, d2, d3 , d4, d5, d6, d7: in std_logic_vector(7 downto 0);   -- 8x8b data inputs
            s0, s1, s2 : in std_logic;                              -- 3b select input
            q : out std_logic_vector(7 downto 0)                -- 8 bit data output         
        );
    end component;

    -- ASCII character values, left shifted by one with the LSB being '0' for UART stop bit
    signal char_M : std_logic_vector(7 downto 0) := "10011010"; -- 'M' ASCII 0x4D
    signal char_S : std_logic_vector(7 downto 0) := "10100110"; -- 'S' ASCII 0x53
    signal char_g : std_logic_vector(7 downto 0) := "11001110"; -- 'g' ASCII 0x67
    signal char_y : std_logic_vector(7 downto 0) := "11110010"; -- 'y' ASCII 0x79
    signal char_r : std_logic_vector(7 downto 0) := "11100100"; -- 'r' ASCII 0x72
    signal char_un: std_logic_vector(7 downto 0) := "10111110"; -- underscore '_' ASCII 0x5F
    signal char_CR: std_logic_vector(7 downto 0) := "00011010"; -- carriage return ASCII 0x0D
    
    signal MSColor, SSColor : std_logic_vector(7 downto 0);

    begin

    MSColorMux: m8x4to1 
    port map (
        d0 => char_g,
        d1 => char_y,
        d2 => char_r,
        d3 => char_r,
        s0 => state(0),
        s1 => state(1),
        q  => MSColor     
    );

    SSColorMux: m8x4to1 
    port map (
        d0 => char_r,
        d1 => char_r,
        d2 => char_g,
        d3 => char_y,
        s0 => state(0),
        s1 => state(1),
        q  => SSColor     
    );

    CharIndexMux: m8x8to1
    port map (
        d0 => char_M,
        d1 => MSColor,
        d2 => char_un,
        d3 => char_S,
        d4 => SSColor,
        d5 => char_CR,
        d6 => "00000000", --- should never occur
        d7 => "00000000", -- should never occur
        s0 => index(0),
        s1 => index(1),
        s2 => index(2),
        q  => q
    );

end structural;