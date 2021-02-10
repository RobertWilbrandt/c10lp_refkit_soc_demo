"""Demo SoC definition for the Cyclone 10LP RefKit"""
from litex.build.generic_platform import IOStandard, Pins
from litex.soc.cores.gpio import GPIOIn, GPIOOut
from litex_boards.targets.c10lprefkit import BaseSoC

from .segment_display import SegmentDisplay

segment_ios = [
    (
        "segments_c",
        0,
        Pins("J17 H17 G17 G18 K18 F19 J18 H19"),
        IOStandard("3.3-V LVTTL"),
    ),
    ("segments_an", 0, Pins("H20 K17 J20 H16 F20"), IOStandard("3.3-V LVTTL")),
]


class DemoSoC(BaseSoC):
    def __init__(self, sys_clk_freq, *args, **kwargs):

        super().__init__(*args, **kwargs)

        self.platform.add_extension(segment_ios)

        self.submodules.segment_display = SegmentDisplay(
            self.platform.request("segments_an"),
            self.platform.request("segments_c"),
            sys_clk_freq=sys_clk_freq,
            rate=1000,
        )
        self.add_csr("segment_display")

        self.submodules.gpio_leds = GPIOOut(self.platform.request("gpio_leds"))
        self.add_csr("gpio_leds")

        self.submodules.switches = GPIOIn(self.platform.request_all("sw"))
        self.add_csr("switches")
