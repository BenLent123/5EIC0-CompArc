/*
 *  OffCourse::Verilog
 *		- Aegir's Brewery brew_fsm
 *
 *  Copyright: Sybe Feitsma && e.t.s.v Thor
 *  License: GPLv3 or later
 */
module brew_fsm(
    input clk,
    input reset,
    input [7:0] temp,level,
    output reg heat,agitate,chute,
    output reg [2:0] pump,
    output reg [7:0] state
);

parameter  IDLE = 0,
  DISPOSAL = 1,
  STERILISE = 2,
  COOL = 3,
  PROCESS = 4,
  FULL = 5,
  HOT = 6,
  MASH = 7,
  SPARGE = 8,
  SPARGE_B = 9,
  DONE = 10;
  
  reg [7:0] next_state;
  reg p_heat,p_agitate,p_chute;
  reg [2:0] p_pump;
  
  always @(posedge clk)begin
    if(reset)begin
    state <= IDLE;
    p_heat <=0;
    p_agitate <=0;
    p_chute <=0;
    p_pump <=0;
    end
    else begin
    state<=next_state;
    p_heat <= heat;
    p_agitate <= agitate;
    p_chute <= chute;
    p_pump <= pump;
    end
  end
  
  always @(*)begin
  next_state = state;
  chute = p_chute;
  heat = p_heat;
  pump = p_pump;
  agitate = p_agitate;
  
  case(state)
    IDLE: begin
        if(level == 0) begin next_state = PROCESS; heat = 1; pump = 4; end
        else begin next_state = DISPOSAL; pump = 2; end
    end
    PROCESS: begin
        if(temp >= 60 && level < 125) begin next_state = HOT; end
        else if(level >= 125) begin next_state = FULL; pump = 0; end
        else next_state = PROCESS;
    end
    DISPOSAL: begin
        if(level == 0) begin next_state = STERILISE; heat = 1; pump = 0; end
    end
    HOT: begin
        if(level >= 125) begin next_state = MASH; agitate = 1; chute = 1; pump = 0; end
        
    end
    FULL: begin
        if(temp >= 60) begin next_state = MASH; agitate = 1; chute = 1; end
    end
    STERILISE: begin
        if(temp == 80) begin next_state = COOL; heat = 0; end
    end
    MASH:begin
        if(temp>=65) begin next_state = SPARGE; chute = 0; heat = 0; pump = 3; end
        else begin next_state = MASH; chute = 0; end
    end
    COOL:begin
        if(temp == 30) begin next_state = IDLE; end
    end
    SPARGE:begin
				if (level < 70) begin
					next_state = SPARGE_B;
				end
				if (pump == 3 && level < 20) begin 
					next_state = DONE;
				end
			end
    SPARGE_B: begin
        if(level<40) begin next_state = SPARGE; pump = 3; end
        else begin next_state = SPARGE_B; pump = 7; end
    end
    DONE: begin
        begin next_state = IDLE; end
        end
        default:;
    endcase
  end
 
 endmodule
 
