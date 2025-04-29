library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
    Port (
        clk : in  STD_LOGIC;
        btn : in  STD_LOGIC_VECTOR (3 downto 0);
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an  : out STD_LOGIC_VECTOR (3 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0);
        dp  : out STD_LOGIC
    );
end top;

architecture Behavioral of top is


component mpg
    Port ( btn : in STD_LOGIC; clk : in STD_LOGIC; enable : out STD_LOGIC );
end component;

component IFE
    Port (
        clk    : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        branch : in  STD_LOGIC_VECTOR(15 downto 0);
        jmpa   : in  STD_LOGIC_VECTOR(15 downto 0);
        jump   : in  STD_LOGIC;
        pcs    : in  STD_LOGIC;
        PC     : out STD_LOGIC_VECTOR(15 downto 0);
        Instr  : out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

component ID
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
end component;

component EX
    Port (
        PCOut         : out STD_LOGIC_VECTOR(15 downto 0);
        RD1           : in  STD_LOGIC_VECTOR(15 downto 0);
        RD2           : in  STD_LOGIC_VECTOR(15 downto 0);
        Ext_Imm       : in  STD_LOGIC_VECTOR(15 downto 0);
        Func          : in  STD_LOGIC_VECTOR(2 downto 0);
        SA            : in  STD_LOGIC;
        ALUSrc        : in  STD_LOGIC;
        ALUOp         : in  STD_LOGIC_VECTOR(2 downto 0);
        BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
        ALURes        : out STD_LOGIC_VECTOR(15 downto 0);
        ZeroSignal    : out STD_LOGIC
    );
end component;

component MEM
    Port (
        clk          : in  STD_LOGIC;
        ALURes       : in  STD_LOGIC_VECTOR(15 downto 0);
        WriteData    : in  STD_LOGIC_VECTOR(15 downto 0);
        MemWrite     : in  STD_LOGIC;
        MemWriteCtrl : in  STD_LOGIC;
        MemData      : out STD_LOGIC_VECTOR(15 downto 0);
        ALURes2      : out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

component ControlUnit
    Port (
        Instr     : in  STD_LOGIC_VECTOR(2 downto 0);
        RegDst    : out STD_LOGIC;
        ExtOp     : out STD_LOGIC;
        ALUSrc    : out STD_LOGIC;
        Branch    : out STD_LOGIC;
        Jump      : out STD_LOGIC;
        ALUOp     : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite  : out STD_LOGIC;
        MemtoReg  : out STD_LOGIC;
        RegWrite  : out STD_LOGIC
    );
end component;

component SSD
    Port (
        clk    : in  STD_LOGIC;
        digits : in  STD_LOGIC_VECTOR(15 downto 0);
        an     : out STD_LOGIC_VECTOR(3 downto 0);
        cat    : out STD_LOGIC_VECTOR(6 downto 0)
    );
end component;


signal enable, reset_enable : STD_LOGIC;
signal instruction          : STD_LOGIC_VECTOR(15 downto 0);
signal pc_out               : STD_LOGIC_VECTOR(15 downto 0);
signal branch_addr          : STD_LOGIC_VECTOR(15 downto 0);
signal jump_addr            : STD_LOGIC_VECTOR(15 downto 0);
signal pcsrc                : STD_LOGIC;
signal alu_res, alu_res2    : STD_LOGIC_VECTOR(15 downto 0);
signal mem_data             : STD_LOGIC_VECTOR(15 downto 0);
signal rd1, rd2             : STD_LOGIC_VECTOR(15 downto 0);
signal ext_imm              : STD_LOGIC_VECTOR(15 downto 0);
signal funct                : STD_LOGIC_VECTOR(2 downto 0);
signal sa                   : STD_LOGIC;
signal reg_dst, ext_op, alu_src, branch, jump, mem_write, mem_to_reg, reg_write : STD_LOGIC;
signal alu_op               : STD_LOGIC_VECTOR(2 downto 0);
signal write_data           : STD_LOGIC_VECTOR(15 downto 0);
signal zero                 : STD_LOGIC;
signal ssdout               : STD_LOGIC_VECTOR(15 downto 0);


begin

dp <= '0';


debouncer1 : mpg port map(btn(0), clk, enable);
debouncer2 : mpg port map(btn(1), clk, reset_enable);


fetch_unit : IFE port map(clk, reset_enable, branch_addr, jump_addr, jump, pcsrc, pc_out, instruction);


decode_unit : ID port map(clk, instruction, write_data, reg_write, reg_dst, ext_op, rd1, rd2, ext_imm, funct, sa);


execute_unit : EX port map(pc_out, rd1, rd2, ext_imm, funct, sa, alu_src, alu_op, branch_addr, alu_res, zero);


memory_unit : MEM port map(clk, alu_res, rd2, mem_write, enable, mem_data, alu_res2);


control_unit : ControlUnit port map(instruction(15 downto 13), reg_dst, ext_op, alu_src, branch, jump, alu_op, mem_write, mem_to_reg, reg_write);


display_unit : SSD port map(clk, ssdout, an, cat);


process(mem_to_reg, alu_res2, mem_data)
begin
    case mem_to_reg is
        when '0' => write_data <= alu_res2;
        when '1' => write_data <= mem_data;
        when others => write_data <= (others => 'X');
    end case;
end process;


pcsrc <= branch and zero;


jump_addr <= pc_out(15 downto 14) & instruction(13 downto 0);


process(sw(15 downto 13), instruction, pc_out, rd1, rd2, ext_imm, alu_res, mem_data, write_data)
begin
    case sw(15 downto 13) is
        when "000" => ssdout <= instruction;
        when "001" => ssdout <= pc_out;
        when "010" => ssdout <= rd1;
        when "011" => ssdout <= rd2;
        when "100" => ssdout <= ext_imm;
        when "101" => ssdout <= alu_res;
        when "110" => ssdout <= mem_data;
        when "111" => ssdout <= write_data;
        when others => ssdout <= X"AAAA";
    end case;
end process;


process(sw(0), reg_dst, ext_op, alu_src, branch, jump, mem_write, mem_to_reg, reg_write, alu_op)
begin
    if sw(0) = '0' then
        led(15 downto 8) <= (others => '0');
        led(7) <= reg_dst;
        led(6) <= ext_op;
        led(5) <= alu_src;
        led(4) <= branch;
        led(3) <= jump;
        led(2) <= mem_write;
        led(1) <= mem_to_reg;
        led(0) <= reg_write;
    else
        led(2 downto 0) <= alu_op;
        led(15 downto 3) <= (others => '0');
    end if;
end process;

end Behavioral;
