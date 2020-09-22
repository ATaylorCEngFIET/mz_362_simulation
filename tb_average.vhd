library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb is 
end entity; 

architecture test_bench of tb is

file file_stim : text;
file file_res : text;

constant clk_period : time := 3.33ns;

signal clk : std_logic := '0';
signal ip : std_logic_vector(7 downto 0):= (others =>'0');
signal op : std_logic_vector(7 downto 0):= (others =>'0'); 

component average is port(
    clk : in std_logic;
    ip : in std_logic_vector(7 downto 0);
    op : out std_logic_vector(7 downto 0));
end component; 

begin

clk_gen: clk <= not clk after (clk_period/2);

uut : average port map (
    clk => clk,
    ip => ip,
    op => op);
    
stimulus : process 

    variable in_line     : line;
    variable input       : integer;

begin
    file_open(file_stim, "stimulus.txt",  read_mode);

    while not endfile(file_stim) loop
      readline(file_stim, in_line);
      read(in_line, input); 
      wait until rising_edge(clk);
      ip  <= std_logic_vector(to_unsigned(input,8));
    end loop;
    ip <=(others =>'0');
    wait;
end process;

check : process 

    variable in_line     : line;
    variable result      : integer;

begin
    file_open(file_res, "result.txt",  read_mode);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    while not endfile(file_res) loop
      readline(file_res, in_line);
      read(in_line, result); 
     -- wait until rising_edge(clk);
     -- ip  <= std_logic_vector(to_unsigned(result,8));
      wait until rising_edge(clk);
      if op /= std_logic_vector(to_unsigned(result,8)) then
        report "output mismatch" severity note; 
      else report "test passed" severity note;
      end if;
    end loop;
 
    file_close(file_res);
    file_close(file_stim);
    report "simulation complete not a failure!" severity failure;
end process;



end architecture;