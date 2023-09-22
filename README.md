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

![System](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/System.jpg)

Applciation Screenshot:

ADC acquisitions:
![App screenshot](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/squarewave%20screenshot2.jpg)
![sawtooth screenshot](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/sawtooth%20screenshot.jpg)

DDS acquisition:
![App screenshot DDS](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/App%20screenshot%20DDS.jpg)


Signal Tap: Data acquisition and upload
![signal tap](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/signal%20tap.jpg)

Signal Tap: Data acquisition ending
![signal tap end of frame](https://github.com/acawhiz/DE10-LITE-Digital-Oscilloscope-with-FFT/blob/main/signal%20tap%20end%20of%20frame.jpg)

