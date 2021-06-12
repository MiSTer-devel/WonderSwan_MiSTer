derive_pll_clocks
derive_clock_uncertainty

set clk_ram {*|pll|pll_inst|altera_pll_i|*[0].*|divclk}
set clk_sys {*|pll|pll_inst|altera_pll_i|*[1].*|divclk}