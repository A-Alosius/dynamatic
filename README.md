# Dynamatic
Dynamatic is an academic, open-source high-level synthesis compiler that produces synchronous dynamically-scheduled circuits from C/C++ code. Dynamatic generates synthesizable RTL which currently targets Xilinx FPGAs and delivers significant performance improvements compared to state-of-the-art commercial HLS tools in specific situations (e.g., applications with irregular memory accesses or control-dominated code). The fully automated compilation flow of Dynamatic is based on MLIR. It is customizable and extensible to target different hardware platforms and easy to use with commercial tools such as Vivado (Xilinx) and Modelsim (Mentor Graphics).

## Performance
Dynamatic typically has a better or similar performance to state-of-the-art HLS tools like Vitis HLS in the area of dataflow circuits. Dynamatic also yields a better performance for an acceptable increase in physical resources used. Different flags are available to allow the user to optimize the circuits generated by Dynamatic to suit their specific needs.

## Installation & Documentation
For more information:
- [Dynamatic Installation](docs/GettingStarted/InstallDynamatic.md)
- [Documentation](docs/)

## Contribution  
We welcome contributions and feedback from the community. If you would like to participate, please check out our [contribution guidelines](docs/DeveloperGuide/IntroductoryMaterial/Contributing.md)

## License
See the [LICENSE](LICENSE) file
