`timescale 1ps/1ps

module counter_axi 
#(
    parameter NUM_REGS = 2,
    parameter ADDR_WIDTH = $clog2(NUM_REGS) + 2,
    parameter DATA_WIDTH = 32
)(
    // AXI4-Lite interface signals
    // Global
    input  s_aclk,
    input  s_aresetn,

    // Write address channel
    input  s_awvalid,
    output s_awready,
    input  [ADDR_WIDTH-1 : 0] s_awaddr,
    input  [2 : 0] s_awprot,
    // Write data channel
    input  s_wvalid,
    output s_wready,
    input  [DATA_WIDTH-1 : 0] s_wdata,
    input  [(DATA_WIDTH/8)-1 : 0] s_wstrb,
    // Write response channel
    output s_bvalid,
    input  s_bready,
    output [1 : 0] s_bresp,

    // Read address channel
    input  s_arvalid,
    output s_arready,
    input  [ADDR_WIDTH-1 : 0] s_araddr,
    input  [2 : 0] s_arprot,
    // Read data channel
    output s_rvalid,
    input  s_rready,
    output [DATA_WIDTH-1 : 0] s_rdata,
    output [1 : 0] s_rresp,
    output [3:0] leds
);

reg [DATA_WIDTH-1 : 0] registers_r [0 : NUM_REGS-1];
reg [DATA_WIDTH-1 : 0] registers_nxt [0 : NUM_REGS-1];

reg write, write_r, write_r2, write_nxt, write_nxt2;
reg read_r, read_r2, read_nxt, read_nxt2;
reg [DATA_WIDTH-1 : 0] readdata_r, readdata_r2, readdata_nxt, readdata_nxt2;
reg wvalid_r, wvalid_nxt, awvalid_r, awvalid_nxt;

integer i;

always @(posedge s_aclk) begin
    if (s_aresetn) begin
        for (i=0; i<NUM_REGS; i=i+1) begin
            registers_r[i] <= registers_nxt[i];
        end
        write_r <= write_nxt;
        write_r2 <= write_nxt2;
        read_r <= read_nxt;
        read_r2 <= read_nxt2;
        readdata_r <= readdata_nxt;
        readdata_r2 <= readdata_nxt2;
        wvalid_r <= wvalid_nxt;
        awvalid_r <= awvalid_nxt;
    end else begin
        for (i=0; i<NUM_REGS; i=i+1) begin
            registers_r[i] <= {DATA_WIDTH{1'b0}};
        end
        write_r <= 1'b0;
        write_r2 <= 1'b0;
        read_r <= 1'b0;
        read_r2 <= 1'b0;
        readdata_r <= {DATA_WIDTH{1'b0}};
        readdata_r2 <= {DATA_WIDTH{1'b0}};
        wvalid_r <= 1'b0;
        awvalid_r <= 1'b0;
    end
end

// **********
// Add wires, registers and module instantiations here


wire [31:0] count;
reg enable;

counter c2(
    .clk(s_aclk),
    .resetn(s_aresetn),
    .enable(enable),
    .count(count)
);

assign leds = count[28:25];

// **********


always @(*) begin
    for (i=0; i<NUM_REGS; i=i+1) begin
        registers_nxt[i] = registers_r[i];
    end
    write = (s_awvalid & s_awready & s_wvalid & s_wready)
          | (s_awvalid & s_awready & wvalid_r)
          |             (awvalid_r & s_wvalid & s_wready);
    write_nxt = write_r;
    write_nxt2 = write_r2;
    wvalid_nxt = wvalid_r | (s_wvalid & s_wready);
    awvalid_nxt = awvalid_r | (s_awvalid & s_awready);

    if (write) begin
        wvalid_nxt = 1'b0;
        awvalid_nxt = 1'b0;
    end

    // **********
    // Assign to registers here if a write on the bus should overwrite the register value
    enable = registers_r[1][0];
    // **********

    if (write_r2) begin
        write_nxt2 = ~s_bready;
    end else begin
        write_nxt = ~s_bready & write_r;
        if (write) begin
                for (i=0; i<(DATA_WIDTH/8); i=i+1) begin
                    if (s_wstrb[i]) begin
                        registers_nxt[s_awaddr[ADDR_WIDTH-1 : 2]][i*8 +: 8] = s_wdata[i*8 +: 8];
                    end
                end
                write_nxt2 = write_nxt;
                write_nxt = 1'b1;
        end
    end

    // **********
    // Assign to registers here if the assignment should overwrite the bus write value
    registers_nxt[0] = count;
    // **********
end

always @(*) begin
    read_nxt = read_r;
    read_nxt2 = read_r2;
    readdata_nxt = readdata_r;
    readdata_nxt2 = readdata_r2;

    if (read_r2) begin
        if (s_rready) begin
            read_nxt2 = 1'b0;
            readdata_nxt = readdata_r2;
        end
    end else begin
        read_nxt = ~s_rready & read_r;
        if (s_arvalid) begin
            if (read_nxt) begin
                read_nxt2 = 1'b1;
                readdata_nxt2 = registers_r[s_araddr[ADDR_WIDTH-1:2]];
            end else begin
                readdata_nxt = registers_r[s_araddr[ADDR_WIDTH-1:2]];
            end
            read_nxt = 1'b1;
        end
    end
end

assign s_awready = ~(write_r2 | awvalid_r);
assign s_wready = ~(write_r2 | wvalid_r);
assign s_bvalid = write_r;
assign s_bresp = 2'b0;

assign s_arready = ~read_r2;
assign s_rvalid = read_r;
assign s_rdata = readdata_r;
assign s_rresp = 2'b0;

wire _unused_ok = &{1'b0,
                    s_awaddr[1:0],
                    s_awprot,
                    s_araddr[1:0],
                    s_arprot,
                    1'b0};

endmodule
