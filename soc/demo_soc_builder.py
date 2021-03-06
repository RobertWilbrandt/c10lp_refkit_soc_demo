"""Build demo SoC gateware"""

import argparse
import os

from litex.soc.integration.builder import (Builder, builder_argdict,
                                           builder_args)
from litex.soc.integration.soc_sdram import soc_sdram_argdict, soc_sdram_args

from .demo_soc import DemoSoC

SYS_CLK_FREQ = 50 * 10 ** 6


def parse_args():
    """Parse CLI arguments"""
    parser = argparse.ArgumentParser(
        description="Demo SoC and application for the Cyclone 10 LP RefKit"
    )
    parser.add_argument("--build", action="store_true", help="Build bitstream")
    parser.add_argument("--load", action="store_true", help="Load bitstream")

    builder_args(parser)
    soc_sdram_args(parser)

    return parser.parse_args()


def main():
    """Entry point"""
    args = parse_args()

    soc = DemoSoC(sys_clk_freq=SYS_CLK_FREQ, **soc_sdram_argdict(args))
    builder = Builder(soc, **builder_argdict(args))

    builder.build(run=args.build)
    if args.load:
        prog = soc.platform.create_programmer()
        prog.cable_name = "Arrow-USB-Blaster"  # Programmer used on board
        prog.load_bitstream(os.path.join(builder.gateware_dir, soc.build_name + ".sof"))


if __name__ == "__main__":
    main()
