"""Submodule for controlling the 7-Segment display"""

from litex.soc.interconnect.csr import AutoCSR, CSRStorage
from migen import Array, If, Module, Signal


class SegmentDisplay(Module, AutoCSR):
    def __init__(self, an_pads, c_pads, sys_clk_freq, rate):
        self._d = CSRStorage(3, description="Dot segments")
        self._s0 = CSRStorage(8, description="Segments of first digit")
        self._s1 = CSRStorage(8, description="Segments of second digit")
        self._s2 = CSRStorage(8, description="Segments of third digit")
        self._s3 = CSRStorage(8, description="Segments of fourth digit")

        # Counter resets at specified rate
        cnt_steps = int(sys_clk_freq / rate)
        scan_cnt = Signal(max=cnt_steps)
        self.sync += If(scan_cnt == 0, scan_cnt.eq(cnt_steps - 1)).Else(
            scan_cnt.eq(scan_cnt - 1)
        )

        # Rotate through digits
        scan_sel = Signal(max=5)
        self.sync += If(
            scan_cnt == 1,
            If(scan_sel == 0, scan_sel.eq(4)).Else(scan_sel.eq(scan_sel - 1)),
        )
        self.comb += an_pads.eq(~(1 << scan_sel))

        # Assign segments by selecting correct register
        digits = Array(
            [
                self._d.storage,
                self._s0.storage,
                self._s1.storage,
                self._s2.storage,
                self._s3.storage,
            ]
        )
        self.comb += c_pads.eq(~digits[scan_sel])
