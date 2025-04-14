/*
 *  OffCourse::Verilog
 *		- Aegir's Brewery brew_system
 *
 *  Copyright: Sybe Feitsma && e.t.s.v Thor
 *  License: GPLv3 or later
 */

module brew_system(
input [7:0] level_sensor, 
input nreset,
input valid,
input clock, 
input [7:0] temperature,
output [7:0] level,
output motor,
output grain_feed,
output heater,
output sparge_valve,
output valve,
output [1:0] pump
);
reg [7:0] val;
wire [2:0] pump_fsm_out;

always @(posedge clock) begin
    if(!nreset || valid ) begin
       val <= level_sensor;
    end
end



brew_fsm ins(
    .clk(clock),
    .reset(!nreset),
    .temp(temperature),
    .agitate(motor),
    .chute(grain_feed),
    .heat(heater),
    .pump(pump_fsm_out),
    .level(val)
);


assign valve = pump_fsm_out[0];
assign pump[0] = (pump_fsm_out[0] | pump_fsm_out[1]);
assign pump[1] = (pump_fsm_out[2] );
assign sparge_valve = (pump_fsm_out[2:1] == 2'b11);
assign level =  val;

endmodule
