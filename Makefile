all: gateware
gateware: build/c10lprefkit/gateware/c10lprefkit.sof

.PHONY: all gateware

*.sof: soc/c10lp-refkit-soc-demo
	python3 $< --build
