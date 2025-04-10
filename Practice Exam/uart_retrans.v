module uart_retrans (
    input clk,
    input reset,
    input signal,
    input ack,
    output error,
    output [4:0] resend_count,
    output request_resend,
    output valid
);

wire timeout_to_trigger;
wire error_to_parity_error;
wire valid_to_framevalid;
wire request_resend_to_valid;

uart_parity_even upe(
    .clk(clk),
    .reset(reset),
    .signal(signal),
    .valid(valid_to_framevalid),      // internal wire
    .error(error_to_parity_error)       // internal wire
);

uart_retrans_fsm urf(
    .reset(reset),
    .clk(clk),
    .ack(ack),
    .frame_valid(valid_to_framevalid),
    .parity_error(error_to_parity_error),
    .timeout(timeout_to_trigger),
    .error(error),              // drives top-level output
    .request_resend(request_resend_to_valid),
    .valid(valid)               // drives top-level output
);

timer t(
    .clk(clk),
    .enable(1),
    .reset(reset),
    .valid(request_resend_to_valid),
    .value(5'h8),
    .count(resend_count),
    .trigger(timeout_to_trigger)
);

assign request_resend = request_resend_to_valid;
endmodule
