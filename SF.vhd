library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ID is
    Port (
        clk         : in  STD_LOGIC;
        instruction : in  STD_LOGIC_VECTOR(15 downto 0);
        WriteD      : in  STD_LOGIC_VECTOR(15 downto 0);
        RegW        : in  STD_LOGIC;
        RegDst      : in  STD_LOGIC;
        ExtOp       : in  STD_LOGIC;
        RD1         : out STD_LOGIC_VECTOR(15 downto 0);
        RD2         : out STD_LOGIC_VECTOR(15 downto 0);
        Ext_Imm     : out STD_LOGIC_VECTOR(15 downto 0);
        funct       : out STD_LOGIC_VECTOR(2 downto 0);
        sa          : out STD_LOGIC
    );
end ID;

architecture Behavioral of ID is

    component RegisterFile is
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
    end component;

    signal WriteR   : STD_LOGIC_VECTOR(2 downto 0);
    signal imd      : STD_LOGIC_VECTOR(6 downto 0);
    signal signbit  : STD_LOGIC;

begin

    WriteR <= instruction(6 downto 4) when RegDst = '1' else instruction(9 downto 7);

    imd <= instruction(6 downto 0);
    signbit <= instruction(6);

    Ext_Imm <= (others => signbit) when ExtOp = '1' else (others => '0');
    Ext_Imm(6 downto 0) <= imd;

    funct <= instruction(2 downto 0);
    sa    <= instruction(3); 


    RF: RegisterFile port map (
        clk    => clk,
        RR1    => instruction(12 downto 10),
        RR2    => instruction(9 downto 7),
        WriteR => WriteR,
        WriteD => WriteD,
        RegW   => RegW,
        RD1    => RD1,
        RD2    => RD2,
        enable => RegW
    );

end Behavioral;
