library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IFE is
    Port ( 
        WE : in STD_LOGIC;
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        branch : in STD_LOGIC_VECTOR (15 downto 0);
        jmpa : in STD_LOGIC_VECTOR (15 downto 0);
        jump : in STD_LOGIC;
        pcs : in STD_LOGIC;
        instr : out STD_LOGIC_VECTOR (15 downto 0);
        pc : out STD_LOGIC_VECTOR (15 downto 0)
    );
end IFE;

architecture                                                                                                                                                                                                                                                                        Behavioral of IFE is

    signal pcounter, pc_aux, next_addr, aux_mux : std_logic_vector(15 downto 0) := x"0000";

    type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
    signal ROM : rom_type := (
        0  => B"000_001_000_010_0_000", -- add
        1  => B"000_011_010_010_0_001", -- sub
        2  => B"000_010_000_010_1_010", -- sll
        3  => B"000_010_000_010_1_011", -- srl
        4  => B"000_011_010_100_0_100", -- and
        5  => B"000_101_100_100_0_101", -- or
        6  => B"000_100_100_100_0_110", -- xor
        7  => B"000_010_011_100_0_111", -- slt
        8  => B"001_000_100_0000100",   -- addi
        9  => B"010_001_101_0000000",   -- lw
        10 => B"011_100_101_0000000",   -- sw
        11 => B"100_001_001_0000001",   -- beq
        12 => B"101_100_101_0000100",   -- andi
        13 => B"110_101_110_0000011",   -- ori
        14 => B"111_0000000000011",     -- j
        others => x"0000"
    );

begin

    pc_aux <= std_logic_vector(unsigned(pcounter) + 1);


    process(pcs, pc_aux, branch)
    begin
        if pcs = '0' then
            aux_mux <= pc_aux;
        else
            aux_mux <= branch;
        end if;
    end process;


    process(jump, aux_mux, jmpa)
    begin
        if jump = '0' then
            next_addr <= aux_mux;
        else
            next_addr <= jmpa;
        end if;
    end process;


    process(clk, reset)
    begin
        if reset = '1' then
            pcounter <= x"0000";
        elsif rising_edge(clk) and WE = '1' then
            pcounter <= next_addr;
        end if;
    end process;


    instr <= ROM(to_integer(unsigned(pcounter(7 downto 0))));


    pc <= pc_aux;

end Behavioral;
