library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- This is the top level module. The ports on this entity
-- are mapped directly to pins on the FPGA.

-- In this version the design can generate a checker board
-- pattern on the VGA output.

entity comp is
   port (
      clk_i     : in  std_logic;                      -- 25 MHz

      vga_hs_o  : out std_logic;
      vga_vs_o  : out std_logic;
      vga_col_o : out std_logic_vector(7 downto 0)    -- RRRGGGBB
   );
end comp;

architecture Structural of comp is

   -- Define constants used for 640x480 @ 60 Hz.
   -- Requires a clock of 25.175 MHz.
   -- See page 17 in "VESA MONITOR TIMING STANDARD"
   -- http://caxapa.ru/thumbs/361638/DMTv1r11.pdf
   constant H_PIXELS : integer := 640;
   constant V_PIXELS : integer := 480;
   --
   constant H_TOTAL  : integer := 800;
   constant HS_START : integer := 656;
   constant HS_TIME  : integer := 96;
   --
   constant V_TOTAL  : integer := 525;
   constant VS_START : integer := 490;
   constant VS_TIME  : integer := 2;

   -- Define colours
   constant COL_BLACK : std_logic_vector(7 downto 0) := B"000_000_00";
   constant COL_WHITE : std_logic_vector(7 downto 0) := B"111_111_11";
   constant COL_RED   : std_logic_vector(7 downto 0) := B"111_000_00";
   constant COL_GREEN : std_logic_vector(7 downto 0) := B"000_111_00";
   constant COL_BLUE  : std_logic_vector(7 downto 0) := B"000_000_11";

   -- Pixel counters
   signal pix_x : std_logic_vector(9 downto 0) := (others => '0');
   signal pix_y : std_logic_vector(9 downto 0) := (others => '0');

   -- We group together all the VGA signals into a single record.
   -- This will be especially useful in later episodes.
   type t_vga is record
      -- Synchronization
      hs  : std_logic;
      vs  : std_logic;

      -- Pixel colour
      col : std_logic_vector(7 downto 0);
   end record t_vga;

   signal vga : t_vga;

begin
   
   --------------------------------------------------
   -- Generate horizontal and vertical pixel counters
   --------------------------------------------------

   p_pix_x : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x = H_TOTAL-1 then
            pix_x <= (others => '0');
         else
            pix_x <= pix_x + 1;
         end if;
      end if;
   end process p_pix_x;

   p_pix_y : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x = H_TOTAL-1  then
            if pix_y = V_TOTAL-1 then
               pix_y <= (others => '0');
            else
               pix_y <= pix_y + 1;
            end if;
         end if;
      end if;
   end process p_pix_y;

   
   --------------------------------------------------
   -- Generate horizontal sync signal
   --------------------------------------------------

   p_vga_hs : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x >= HS_START and pix_x < HS_START+HS_TIME then
            vga.hs <= '0';
         else
            vga.hs <= '1';
         end if;
      end if;
   end process p_vga_hs;


   --------------------------------------------------
   -- Generate vertical sync signal
   --------------------------------------------------

   p_vga_vs : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_y >= VS_START and pix_y < VS_START+VS_TIME then
            vga.vs <= '0';
         else
            vga.vs <= '1';
         end if;
      end if;
   end process p_vga_vs;

   
   --------------------------------------------------
   -- Generate pixel colour
   --------------------------------------------------

   p_vga_col : process (clk_i)
   begin
      if rising_edge(clk_i) then

         -- Generate checker board pattern
         if (pix_x(4) xor pix_y(4)) = '1' then
            vga.col <= COL_WHITE;
         else
            vga.col <= COL_BLACK;
         end if;

         -- Make sure colour is black outside the visible area.
         if pix_x >= H_PIXELS or pix_y >= V_PIXELS then
            vga.col <= COL_BLACK;
         end if;
      end if;
   end process p_vga_col;


   --------------------------------------------------
   -- Drive output signals
   --------------------------------------------------

   vga_hs_o  <= vga.hs;
   vga_vs_o  <= vga.vs;
   vga_col_o <= vga.col;

end architecture Structural;

