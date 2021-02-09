"""Demo SoC definition for the Cyclone 10LP RefKit"""
from litex.soc.cores.gpio import GPIOIn, GPIOOut
from litex_boards.targets.c10lprefkit import BaseSoC


class DemoSoC(BaseSoC):
    def __init__(self, *args, **kwargs):

        super().__init__(*args, **kwargs)

        self.submodules.gpio_leds = GPIOOut(self.platform.request("gpio_leds"))
        self.add_csr("gpio_leds")

        self.submodules.switches = GPIOIn(self.platform.request_all("sw"))
        self.add_csr("switches")
