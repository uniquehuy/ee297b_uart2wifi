//////////////////////////////////////////////////////////////////////////////////
//      ENVIRONMENTAL PARAMETERS
//////////////////////////////////////////////////////////////////////////////////
`ifndef ENV_PARAMS
`define ENV_PARAMS


`define CLK_FREQ 100.0 // Need to pick a clock frequency

// =========
// FSM PARAMS
// =========
typedef enum int {IDLE = 0, SEND_DATA = 1, READ_DATA = 2, BUSY = 3} fsm_state;

// =========
// LED PARAMS
// =========

`endif
