-- -----------------------------------------------------------------------------
--
--  Title      :  FSMD implementation of GCD
--             :
--  Developers :  Jens Sparsø, Rasmus Bo Sørensen and Mathias Møller Bruhn
--           :
--  Purpose    :  This is a FSMD (finite state machine with datapath) 
--             :  implementation the GCD circuit
--             :
--  Revision   :  02203 fall 2019 v.5.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (clk : in std_logic;             -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    req   : in  std_logic;              -- Input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- The two operands.
    ack   : out std_logic;              -- Computation is complete.
    C     : out unsigned(15 downto 0)); -- The result.
end gcd;

architecture fsmd of gcd is

  type state_type is ( IDLE_s, LOAD_A_s, WAIT_s, LOAD_B_s, COMPARE_s, A_GREATER_s, B_GREATER_s, ANSWER_s); -- Input your own state names

  signal reg_a, next_reg_a, next_reg_b, reg_b : unsigned(15 downto 0);

  signal state, next_state : state_type;
 

begin

  -- Combinatoriel logic

  cl : process (all)
  begin
    
    C <= (others=>'0');
    ack <= '0';
    next_state<=state;
    next_reg_a <= reg_a;
    next_reg_b <= reg_b;
    
    case (state) is
      when IDLE_s =>

        if req = '1' then
            next_state <= LOAD_A_s;
          else
            next_state <= IDLE_s;
        end if;

      when LOAD_A_s =>

        next_reg_a <=AB;
        ack<='1';

        if req = '0' then
          next_state <= WAIT_s;
        else
          next_state <= LOAD_A_s;
        end if;

      when WAIT_s =>

        ack <= '0';

        if req = '1' then
          next_state <= LOAD_B_s;
        else
          next_state <= WAIT_s;
        end if;

      when LOAD_B_s =>

        next_reg_b <= AB;
        next_state <= COMPARE_s;

      when COMPARE_s =>
        
        if reg_a > reg_b then

          next_state <= A_GREATER_s;

        elsif reg_a < reg_b then

          next_state <= B_GREATER_s;

        elsif reg_a = reg_b then
        
          next_state <= ANSWER_s;

        end if;

      when A_GREATER_s =>

        next_reg_a<= reg_a - reg_b;
        next_state <= COMPARE_s;

      when B_GREATER_s =>

        next_reg_b<=reg_b - reg_a;
        next_state <= COMPARE_s;

      when ANSWER_s =>

        C <= reg_a;
        ack <= '1';

        if req = '0' then
          next_state <= IDLE_s;
        else
          next_state <= ANSWER_s;
        end if;

    end case;

  end process cl;

  -- Registers

  seq : process (clk, reset)
  begin
    
    if rising_edge(clk) then
      
      if reset = '1' then

        state <= IDLE_s;
        reg_a <= (others => '0');
        reg_b <= (others => '0');

      else

        reg_a <= next_reg_a;
        reg_b <= next_reg_b;
        state <= next_state;
        
      end if;

    end if; 

  end process seq;


end fsmd;
