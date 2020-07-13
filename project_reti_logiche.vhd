-----------------------------------------------------------------------------------
-- Company: 
-- Author: Lorenzo Mainetti
-- 
-- Create Date: 16.02.2020 10:57:05
-- Design Name: 
-- Module Name: project_reti_logiche - 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data: in STD_LOGIC_VECTOR(7 downto 0);
           o_address : out STD_LOGIC_VECTOR(15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR(7 downto 0)
           );
end project_reti_logiche;



architecture Behavioral of project_reti_logiche is
   type state_type is (IDLE, READ, CODE, WRITE, DONE);
   signal current_state, next_state: state_type;
   
   signal current_addr, next_addr : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; 
   signal current_i, next_i : integer range 7 downto 0 := 0;   
     
   signal o_done_next, o_en_next, o_we_next : std_logic := '0';
   signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
   signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";  
  
   
 
begin
--process per gestire gli elementi di memoria
 memory: process(i_clk, i_rst)
     begin
       if (i_clk'event and i_clk = '0') then
         if (i_rst = '1') then                
            current_i <= 0;
            current_addr <= "00000000";

            current_state <= IDLE;
           
         else
            o_done <= o_done_next;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_data <= o_data_next;
            o_address <= o_address_next;

            current_addr <= next_addr;
            current_i <= next_i;
           
            current_state <= next_state;
         end if;
       end if;
        
     end process;
 
 --process per gestire la parte combinatoria
 combin: process(current_state, i_data, i_start, current_addr, current_i)          
    
     variable offset1, offset2, offset3 : STD_LOGIC_VECTOR(7 downto 0); 
     
     begin
        offset1 := "00000000";
        offset2 := "00000000";
        offset3 := "00000000";
    
        o_done_next <= '0';
        o_en_next <= '0';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";

        next_addr <= current_addr;
        next_i <= current_i;
        
        next_state <= current_state;
     
       case current_state is
         when IDLE =>
            o_address_next <= "0000000000001000";
            
            if (i_start = '1') then
               o_en_next <= '1';
               o_we_next <= '0';

               next_state <= READ;
            else           
               next_state <= IDLE;
            end if;
       
         when READ =>
              if (current_i = 0) then 
                next_addr <= i_data;
              end if; 
            
              o_en_next <= '1';
              o_we_next <= '0';
              o_address_next <= STD_LOGIC_VECTOR(to_unsigned(current_i, 16));
              next_state <= CODE;            
            
         when CODE => 
           offset1 := std_logic_vector(to_unsigned(to_integer(unsigned(i_data)) + 1, 8));
           offset2 := std_logic_vector(to_unsigned(to_integer(unsigned(i_data)) + 2, 8));
           offset3 := std_logic_vector(to_unsigned(to_integer(unsigned(i_data)) + 3, 8));     
           
           if (i_data = current_addr) then
              o_address_next <= "0000000000001001";
              o_en_next <= '1';
              o_we_next <= '1'; 
              o_data_next <= '1' & STD_LOGIC_VECTOR(to_unsigned(current_i, 3)) & "0001"; 

              next_state <= WRITE;
           
           elsif (offset1 = current_addr) then
              o_address_next <= "0000000000001001";
              o_en_next <= '1';
              o_we_next <= '1';            
              o_data_next <= '1' & STD_LOGIC_VECTOR(to_unsigned(current_i, 3)) & "0010"; 
          
              next_state <= WRITE;                     
          
           elsif (offset2 = current_addr) then
              o_address_next <= "0000000000001001";
              o_en_next <= '1';
              o_we_next <= '1'; 
              o_data_next <= '1' & STD_LOGIC_VECTOR(to_unsigned(current_i, 3)) & "0100";             

              next_state <= WRITE; 
              
           elsif (offset3 = current_addr) then
              o_address_next <= "0000000000001001";
              o_en_next <= '1';
              o_we_next <= '1';            
              o_data_next <= '1' & STD_LOGIC_VECTOR(to_unsigned(current_i, 3)) & "1000"; 

              next_state <= WRITE;                     
           
           else 
              if (current_i = 7) then
                 o_address_next <= "0000000000001001";
                 o_en_next <= '1';
                 o_we_next <= '1'; 
                 o_data_next <= current_addr;
                               
                 next_state <= WRITE; 
              else
                 next_addr <= current_addr;
                 o_address_next <= STD_LOGIC_VECTOR(to_unsigned(current_i, 16));
                 next_i <= current_i + 1;    
                   
                 next_state <= READ;
              end if;   
             
           end if;
                        
         when WRITE =>
             o_done_next <= '1';
             
             o_address_next <= "0000000000001000";
             next_i <= 0;
             o_en_next <= '0';
             o_we_next <= '0'; 
 
             next_state <= DONE;  
             
         when DONE => 
             o_address_next <= "0000000000001000";
         
             if (i_start = '0') then
                o_done_next <= '0';
                next_state <= IDLE;
             else
                o_done_next <= '1';
                next_state <= DONE;
             end if;    
                                              
       end case;     
     end process;
     
end Behavioral;

