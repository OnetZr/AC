library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    Port (
        clk     : in  STD_LOGIC;
        RR1     : in  STD_LOGIC_VECTOR(2 downto 0);
        RR2     : in  STD_LOGIC_VECTOR(2 downto 0);
        WriteR  : in  STD_LOGIC_VECTOR(2 downto 0);
        WriteD  : in  STD_LOGIC_VECTOR(15 downto 0);
        RegW    : in  STD_LOGIC;
        RD1     : out STD_LOGIC_VECTOR(15 downto 0);
        RD2     : out STD_LOGIC_VECTOR(15 downto 0);
        enable  : in  STD_LOGIC
    );
end RegisterFile;

architecture Behavioral of RegisterFile is
    type RegArray is array (0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
    signal registers : RegArray := (
        X"0000",
        X"0001",
        X"0002",
        X"0003",
        X"0004",
        X"0005",
        X"0006",
        X"0007"
    );
begin

    RD1 <= registers(to_integer(unsigned(RR1)));

    RD2 <= registers(to_integer(unsigned(RR2)));

    process(clk, enable)
    begin
        if enable = '1' then
            if rising_edge(clk) then
                if RegW = '1' then
                    registers(to_integer(unsigned(WriteR))) <= WriteD;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
