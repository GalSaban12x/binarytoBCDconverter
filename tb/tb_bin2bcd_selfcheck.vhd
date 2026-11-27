-- Self-checking regression for the existing seven-segment output interface.
-- Uses a local reference encoder to check all values 0..255.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_bin2bcd_selfcheck is
end entity;

architecture sim of tb_bin2bcd_selfcheck is
    constant CLK_PERIOD : time := 10 ns;
    signal resetN : std_logic := '0';
    signal clk    : std_logic := '0';
    signal start  : std_logic := '0';
    signal din    : std_logic_vector(7 downto 0) := (others => '0');
    signal ready  : std_logic;
    signal HEX0, HEX1, HEX2 : std_logic_vector(6 downto 0);

    function seven_seg_digit(d : natural) return std_logic_vector is
    begin
        case d is
            when 0 => return "0000001";
            when 1 => return "1001111";
            when 2 => return "0010010";
            when 3 => return "0000110";
            when 4 => return "1001100";
            when 5 => return "0100100";
            when 6 => return "0100000";
            when 7 => return "0001111";
            when 8 => return "0000000";
            when 9 => return "0000100";
            when others =>
                assert false report "Invalid decimal digit" severity failure;
                return "1111111";
        end case;
    end function;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.bin2bcd
        port map (
            resetN => resetN,
            clk    => clk,
            start  => start,
            din    => din,
            ready  => ready,
            HEX0   => HEX0,
            HEX1   => HEX1,
            HEX2   => HEX2
        );

    stimulus : process
        procedure check_value(value : natural) is
        begin
            -- Drive control/data away from the active edge.
            wait until falling_edge(clk);
            start <= '1';
            din <= std_logic_vector(to_unsigned(value, 8));
            wait until rising_edge(clk);
            wait for 1 ns;  -- settle nonblocking/signal updates

            if value > 0 then
                assert ready = '0'
                    report "ready did not deassert for input " & integer'image(value)
                    severity failure;
            else
                assert ready = '1'
                    report "Zero input should complete immediately"
                    severity failure;
            end if;

            wait until falling_edge(clk);
            start <= '0';

            -- Count for up to value subsequent rising edges.
            -- The down-counter asserts ready once it reaches zero.
            for cycle in 1 to value loop
                wait until rising_edge(clk);
                wait for 1 ns;
                if cycle < value then
                    assert ready = '0'
                        report "ready asserted early for " & integer'image(value)
                        severity failure;
                end if;
            end loop;

            assert ready = '1'
                report "ready did not assert for " & integer'image(value)
                severity failure;
            assert HEX0 = seven_seg_digit(value mod 10)
                report "Units mismatch for " & integer'image(value)
                severity failure;
            assert HEX1 = seven_seg_digit((value / 10) mod 10)
                report "Tens mismatch for " & integer'image(value)
                severity failure;
            assert HEX2 = seven_seg_digit(value / 100)
                report "Hundreds mismatch for " & integer'image(value)
                severity failure;
        end procedure;
    begin
        wait for CLK_PERIOD * 2;
        wait until falling_edge(clk);
        resetN <= '1';

        for value in 0 to 255 loop
            check_value(value);
        end loop;

        -- Restart partway through a conversion; new data should win.
        wait until falling_edge(clk);
        start <= '1';
        din <= std_logic_vector(to_unsigned(200, 8));
        wait until rising_edge(clk);
        wait for 1 ns;
        wait until falling_edge(clk);
        start <= '0';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        check_value(42);

        report "PASS: all 256 input values and mid-conversion restart verified" severity note;
        finish;
    end process;
end architecture;
