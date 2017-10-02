----------------------------------------------------------------------------------
-- VGA Colour Cycle
-- Michelle, 2015
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity VGATop is
  port(clk50  : in std_logic;
       rst   : in std_logic;
		left, up 	: in std_logic;
		right, down 	: in std_logic;
       r      : out std_logic;
       g      : out std_logic;
       b      : out std_logic;
       hSync  : out std_logic;
       vSync  : out std_logic);
end VGATop;

architecture RTL of VGATop is
-- Signals
signal clk25  : std_logic;
signal vidOn  : std_logic;
signal colour : std_logic_vector(2 downto 0);
signal rgb    : std_logic_vector(2 downto 0);
signal row    : std_logic_vector(9 downto 0);
signal col    : std_logic_vector(9 downto 0);
signal clkCnt : std_logic_vector(24 downto 0);
signal clkTick : std_logic;
signal ballX  : integer range 0 to 640;
signal ballY  : integer range 0 to 480;
signal rowInt : integer range 0 to 525;
signal colInt : integer range 0 to 800;
signal box2X  : integer range 0 to 640;
signal box2Y  : integer range 0 to 480;

signal wall1_on, wall2_on, wall3_on, wall4_on: std_logic;
signal box_on, box1_on,
 box2_on, box3_on, box4_on, box5_on,
 box6_on, box7_on, box8_on,
 box9_on, box10_on, box11_on: std_logic;
signal wall_rgb, box_rgb,
 box1_rgb,box2_rgb, box3_rgb,box4_rgb, 
 box5_rgb, box6_rgb, box7_rgb, box8_rgb,
 box9_rgb, box10_rgb, box11_rgb: std_logic_vector(2 downto 0);

constant MAX_X: integer := 640;
constant MAX_Y: integer := 480;

--left n right boarder
constant WALL_X1_L: integer := 20;
constant WALL_X1_R: integer := 35;
constant WALL_X2_L: integer := 605;
constant WALL_X2_R: integer := 620;
--top n bottom
constant WALL_Y1_T: integer := 20;
constant WALL_Y1_B: integer := 35;
constant WALL_Y2_T: integer := 445;
constant WALL_Y2_B: integer := 460;

--square ball

constant BALL_SIZE: integer :=8;
constant BALL_X_L: integer :=550;
constant BALL_X_R: integer:=BALL_X_L+BALL_SIZE-1;
constant BALL_Y_T: integer:=238;
constant BALL_Y_B: integer:=BALL_Y_T+BALL_SIZE-1;


constant BOX_X_L: integer := 310;
constant BOX_X_R: integer := 330;
constant BOX_Y_T: integer := 230;
constant BOX_Y_B: integer := 250;

constant BOX1_X_L: integer := 290;
constant BOX1_X_R: integer := 350;
constant BOX1_Y_T: integer := 210;
constant BOX1_Y_B: integer := 270;

constant BOX2_X_L: integer := 270;
constant BOX2_X_R: integer := 370;
constant BOX2_Y_T: integer := 190;
constant BOX2_Y_B: integer := 290;

constant BOX3_X_L: integer := 250;
constant BOX3_X_R: integer := 390;
constant BOX3_Y_T: integer := 170;
constant BOX3_Y_B: integer := 310;

constant BOX4_X_L: integer := 230;
constant BOX4_X_R: integer := 410;
constant BOX4_Y_T: integer := 150;
constant BOX4_Y_B: integer := 330;

constant BOX5_X_L: integer := 210;
constant BOX5_X_R: integer := 430;
constant BOX5_Y_T: integer := 130;
constant BOX5_Y_B: integer := 350;

constant BOX6_X_L: integer := 190;
constant BOX6_X_R: integer := 450;
constant BOX6_Y_T: integer := 110;
constant BOX6_Y_B: integer := 370;

constant BOX7_X_L: integer := 170;
constant BOX7_X_R: integer := 470;
constant BOX7_Y_T: integer := 90;
constant BOX7_Y_B: integer := 390;

constant BOX8_X_L: integer := 150;
constant BOX8_X_R: integer := 490;
constant BOX8_Y_T: integer := 70;
constant BOX8_Y_B: integer := 410;

constant BOX9_X_L: integer := 130;
constant BOX9_X_R: integer := 510;
constant BOX9_Y_T: integer := 50;
constant BOX9_Y_B: integer := 430;

constant BOX10_X_L: integer := 110;
constant BOX10_X_R: integer := 530;
constant BOX10_Y_T: integer := 30;
constant BOX10_Y_B: integer := 450;

constant BOX11_X_L: integer := 90;
constant BOX11_X_R: integer := 550;
constant BOX11_Y_T: integer := 10;
constant BOX11_Y_B: integer := 470;
-- Components
component VGASync
    port(   clk   : in std_logic;
            rst   : in std_logic;
            hSync : out std_logic;
            vSync : out std_logic;
            row   : out std_logic_vector(9 downto 0);
            col   : out std_logic_vector(9 downto 0);
            vidOn : out std_logic
    );
end component VGASync;
    
begin

-- Create integer versions of the row and column trackers
rowInt <= to_integer(unsigned(row));
colInt <= to_integer(unsigned(col));

wall1_on <=
'1' when WALL_X1_L <= colInt and colInt <= WALL_X1_R else			
'0';
wall_rgb <= "000";

wall2_on <=
'1' when WALL_X2_L <= colInt and colInt <= WALL_X2_R else			
'0';
wall_rgb <= "000";

wall3_on <=
'1' when WALL_Y1_T <= rowInt and rowInt <= WALL_Y1_B else			
'0';
wall_rgb <= "000";

wall4_on <=
'1' when WALL_Y2_T <= rowInt and rowInt <= WALL_Y2_B else			
'0';
wall_rgb <= "000";

--sq_ball_on <=
--'1' when BALL_X_L <= colInt and colInt <= BALL_X_R and
--			BALL_Y_T <= rowInt and rowInt <= BALL_Y_B else
--'0';
--ball_rgb <= "100";

box_on <=
'1' when BOX_X_L <= colInt and colInt <= BOX_X_R and
			BOX_Y_T <= rowInt and rowInt <= BOX_Y_B else
'0';
box_rgb <= "111";

box1_on <=
'1' when BOX1_X_L <= colInt and colInt <= BOX1_X_R and
			BOX1_Y_T <= rowInt and rowInt <= BOX1_Y_B else
'0';
box1_rgb <= "000";

box2_on <=
'1' when BOX2_X_L <= colInt and colInt <= BOX2_X_R and
			BOX2_Y_T <= rowInt and rowInt <= BOX2_Y_B else
'0';
box2_rgb <= "111";

box3_on <=
'1' when BOX3_X_L <= colInt and colInt <= BOX3_X_R and
			BOX3_Y_T <= rowInt and rowInt <= BOX3_Y_B else
'0';
box3_rgb <= "000";

box4_on <=
'1' when BOX4_X_L <= colInt and colInt <= BOX4_X_R and
			BOX4_Y_T <= rowInt and rowInt <= BOX4_Y_B else
'0';
box4_rgb <= "111";

box5_on <=
'1' when BOX5_X_L <= colInt and colInt <= BOX5_X_R and
			BOX5_Y_T <= rowInt and rowInt <= BOX5_Y_B else
'0';
box5_rgb <= "000";

box6_on <=
'1' when BOX6_X_L <= colInt and colInt <= BOX6_X_R and
			BOX6_Y_T <= rowInt and rowInt <= BOX6_Y_B else
'0';
box6_rgb <= "111";

box7_on <=
'1' when BOX7_X_L <= colInt and colInt <= BOX7_X_R and
			BOX7_Y_T <= rowInt and rowInt <= BOX7_Y_B else
'0';
box7_rgb <= "000";

box8_on <=
'1' when BOX8_X_L <= colInt and colInt <= BOX8_X_R and
			BOX8_Y_T <= rowInt and rowInt <= BOX8_Y_B else
'0';
box8_rgb <= "111";

box9_on <=
'1' when BOX9_X_L <= colInt and colInt <= BOX9_X_R and
			BOX9_Y_T <= rowInt and rowInt <= BOX9_Y_B else
'0';
box9_rgb <= "000";

box10_on <=
'1' when BOX10_X_L <= colInt and colInt <= BOX10_X_R and
			BOX10_Y_T <= rowInt and rowInt <= BOX10_Y_B else
'0';
box10_rgb <= "111";

box11_on <=
'1' when BOX11_X_L <= colInt and colInt <= BOX11_X_R and
			BOX11_Y_T <= rowInt and rowInt <= BOX11_Y_B else
'0';
box11_rgb <= "000";


-- VGA synchronisation block
uVGASync: VGASync
    port map(
        clk   	=> clk25,
        rst   	=> rst,
        hSync 	=> hSync,
        vSync 	=> vSync,
        row		=> row,
        col 	=>  col,
        vidOn  => vidOn
   );
  
-- Generate a 25Mhz clock from a 50MHz clock
ClkGen : process (clk50, rst)
begin
    if(rst = '0') then
        clk25 <= '0';
   elsif(clk50'event and clk50='1') then
    clk25 <= not(clk25);
	 clkCnt <= std_logic_vector(unsigned(clkCnt) + 1);
  end if;
end process;

clkTick <= clkCnt(17);

-- Track the pixel location and trace RGB values to the pixel
-- VGA Display 640 x 480: x is 0 -> 639, y is 0 -> 479
TraceXYPixels : process (clk25, rst, vidOn, colInt, rowInt,ballY,ballX, box2X, box2Y)
variable x: integer :=0; -- Row pixel
variable y: integer :=0; -- Column pixel
begin
    -- Create variables from the input signals
    x := colInt;
    y := rowInt;
    -- If reset, set default RGB values (black)
    if(rst='0') then
        rgb <= "000";		
	elsif(clk25'event and clk25 = '1') then
		if y >= ballY-5 and y <= ballY+5 and 
			x >= ballX-5 and x <= ballX+5 then
				rgb <= "101";
	
		elsif y >= box2Y-5 and y <= box2Y+5 and 
			x >= box2X-5 and x <= box2X+5 then
				rgb <= "101";
			--end if;
		--elsif sq_ball_on = '1' then
			--rgb <= ball_rgb; 
			--end if;
		elsif wall1_on = '1' then
			rgb <= wall_rgb;
--		elsif sq_ball_on = '1' then
--			rgb <= ball_rgb;
		elsif wall2_on = '1' then
			rgb <= wall_rgb;
		elsif wall3_on = '1' then
			rgb <= wall_rgb;
		elsif wall4_on = '1' then
			rgb <= wall_rgb;		
		elsif box_on = '1' then
			rgb <= box_rgb;
		elsif box1_on = '1' then
			rgb <= box1_rgb;
		elsif box2_on = '1' then
			rgb <= box2_rgb;
		elsif box3_on = '1' then
			rgb <= box3_rgb;
		elsif box4_on = '1' then
			rgb <= box4_rgb;
		elsif box5_on = '1' then
			rgb <= box5_rgb;
		elsif box6_on = '1' then
			rgb <= box6_rgb;
		elsif box7_on = '1' then
			rgb <= box7_rgb;
		elsif box8_on = '1' then
			rgb <= box8_rgb;
		elsif box9_on = '1' then
			rgb <= box9_rgb;
		elsif box10_on = '1' then
			rgb <= box10_rgb;
		--elsif box11_on = '1' then
			--rgb <= box11_rgb;
		else
			rgb <= "111";
		end if;

			
	end if;
end process;

Ball:process(clkTick, rst)
variable x: integer :=320;
variable y: integer :=240; 
variable directionX: integer := 0;
variable directionY: integer := 0;
begin
	if(rst = '0') then
		x := 320;
	elsif(clkTick'event and clkTick = '1') then
		if(directionX = 0) then
			x := x+1;
			if(directionY = 0) then
				y := y+1;
			else
				y := y-1;
			end if;
		else
			x := x-1;
			if(directionY = 0) then
				y := y+1;
			else
				y := y-1;
			end if;
		end if;
		if(x > MAX_X-5) then
			directionX := 1;
		elsif(x < 5) then
			directionX := 0;
		end if;
		if(y > MAX_Y+5) then
			directionY := 1;
		elsif(y < 5) then
			directionY := 0;
		end if;
		ballX <= x;
		ballY <= y;
	end if;
end process;

MOVE_box:process(clkTick, rst, right, left,up, down, box2X, box2Y)
variable x: integer :=320; 
variable y: integer :=400; 
begin
	if(rst = '0') then
		x := 320;
		y := 400;
	elsif(clkTick'event and clkTick = '1') then
		if(right = '1') then
			x := x+1;
			if(x >= 630) then
			x := 630;
			end if;
		else
			x := x;
		end if;
		
		if(left = '1') then
			x := x-1;
			if(x <= 40) then
			x := 40;
			end if;
		else
			x := x;
		end if;
		
		
		if(up = '1') then
			y := y-1;
			if(y <= 30) then
			y := 30;
			end if;
		else
			y := y;
		end if;
		
		if(down = '1') then
			y := y+1;
			if(y >= 440) then
			y := 440;
			end if;
		else
			y := y;
		end if;	
		box2X <= x;
		box2Y <= y;
	end if;
end process;

-- Drive outputs
r <= rgb(2) and vidOn;
g <= rgb(1) and vidOn;
b <= rgb(0) and vidOn;

end RTL;