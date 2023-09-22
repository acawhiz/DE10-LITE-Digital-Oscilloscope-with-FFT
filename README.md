# DE10-LITE-Digital-Oscilloscope-with-FFT
DE10-LITE digital oscilloscope implemented in Verilog and C# for user interface

Implementation of a one channel oscilloscope using DE10-LITE MAX10 built in ADC.

This project shows a very basic application to interactwith the ADC & JTAG built into the MAX10.
If you have theoretical backround on these components you can use this project to understand how these components are used together as a digital oscilloscope.

The hardware components are mainly JTAG, ADC , DDS module.

At the computer application level C# was used along the following libraries:

For JTAG Inteface:
JtagUart.cs
NativeMethods.cs

For FFT:
-MathNet.Numerics.IntegralTransforms;
-System.Numerics;
-System.Windows.Forms.DataVisualization.Charting;

![System](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/83f0aaba-7ad9-41fe-a612-3daa33d826dd)

Applciation Screenshot:

ADC acquisitions:
![App screenshot](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/1ed7057c-604f-45b2-8ad0-64e3d28bb49f)
![sawtooth screenshot](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/e4276e30-04a4-4883-944b-3ab284a6f265)

DDS acquisition:
![App screenshot DDS](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/80b43654-8fe6-4cca-bd35-77b3b0ae8b86)


Signal Tap: Data acquisition and upload
![signal tap](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/8b6945a9-32e5-421b-b61e-b09c00eae5c4)

Signal Tap: Data acquisition ending
![signal tap end of frame](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/assets/27901725/a46ab112-76b9-4dae-bb73-ef363d28418b)

