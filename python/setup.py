#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from distutils.core import setup
import sys

sys.stderr.write("Sorry, under construction. Check back later!\n")
sys.exit(0)

if sys.version_info.major < 3:
    sys.stderr.write("Error: This package requires python3\n")
    sys.exit(1)

setup(name="REDCapRITS",
      version="0.0",
      author="Paul W. Egeler, M.S., GStat",
      author_email="paul.egeler@spectrumhealth.org",
      description="REDCap Repeating Instrument Table Splitter",
      url="https://github.com/SpectrumHealthResearch/REDCapRITS",
      license="GPL-3",
      package_dir={"REDCapRITS": "src"},
      packages=["REDCapRITS"],
      keywords=["REDCap", "Repeating Instruments"])

