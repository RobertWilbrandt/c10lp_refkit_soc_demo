"""Demo SoC and application for the Cyclone 10 LP RefKit"""

import setuptools

with open("README.md", "r", encoding="utf-8") as f:
    readme = f.read()

setuptools.setup(
    name="c10lp_refkit_soc_demo",
    version="0.1",
    author="Robert Wilbrandt",
    author_email="robert@stamm-wilbrandt.de",
    description="Demo SoC and application for the Cyclone 10 LP RefKit",
    long_description=readme,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: BSD License",
    ],
)
