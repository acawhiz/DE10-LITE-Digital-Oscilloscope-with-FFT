using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Diagnostics;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;

using MathNet.Numerics.IntegralTransforms;
using System.Numerics;

using System.Windows.Forms.DataVisualization.Charting;
//using GetMaximumFrequenciesClasses;
using MathNet.Numerics;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TaskbarClock;


namespace DE10_LITE_DSO_CS
{
    public partial class frmMainForm : Form
    {

        static float VREF = 2.5f;
        static float GAIN_ADC_INPUT = 2.0f;
        static float GAIN_DDS = 3.0f;
        static int ADC_OFFSET = 0x00;// 0x94;
        static int DATA_LENGTH = 601;//length of data coming from hardware


        static int[] array_adc_data = new int[DATA_LENGTH];//last byte used to notify data read
        static float[] array_adc_volts = new float[DATA_LENGTH];//last byte used to notify data read
        static byte tdiv = 18;
        static int tdiv_device_response = 18;// 1s/div
        static JtagUart jtag;

        static int byte_count = 1;
        static byte msb = 0, medb = 0, lsb = 0;
        static int data_counter;// = (msb & 0x0f) << 4 | (medb & 0xf0) >> 4;
        static int adc_data;// = (medb & 0x0f) << 8 | lsb;
        static long data_error_count, frame_counter = 0;
        static float adc_trigger_value;
        static bool TriggerEnable=false;
        static bool DDS_source = false;

        //const int ADC_DATA_LENTGH = 60;
        const int ADC_DATA_SOP = 1;
        //const int ADC_DATA_EOP = 60;
        static Thread Data_transactionThread; 
        static bool data_rx_in_progress = false;
        static bool connect_device = false;

        public frmMainForm()
        {
            InitializeComponent();
            pictureBoxScreen.Image = new Bitmap(pictureBoxScreen.Width, pictureBoxScreen.Height);
        }

        private void Timer_Refresh_Screen_Tick(object sender, EventArgs e)
        {
            //Console.WriteLine("paintnum:{0}", paint_counter++.ToString());
            //https://www.youtube.com/watch?v=XAt_tjSJbjU
            //https://stackoverflow.com/questions/29956709/draw-color-to-every-pixel-in-picturebox
            //https://www.youtube.com/watch?v=XAt_tjSJbjU
            Trigger_Txt_value.Text = String.Format("{0:0.00}", Convert.ToString(Convert.ToSingle(adc_trigger_value)  ));

            if (connect_device)
            {
                toolStripStatusLabelConnected.Text = "De10-LITE:Connected";

                if (DDS_source)
                    toolStripStatusLabelDDS.Text = "Source:DDS";
                else
                    toolStripStatusLabelDDS.Text = "Source:ADC";

                if (TriggerEnable)
                    toolStripStatusLabelTrigger.Text = "Trigger:ON";
                else
                    toolStripStatusLabelTrigger.Text = "Trigger:OFF";


                if ( tdiv>10)
                {
                    pictureBoxScreen.Refresh();
                    PlotFFT(chartFFT, ref array_adc_volts);
                }
                else if (!data_rx_in_progress )
                {
                    pictureBoxScreen.Refresh();
                    PlotFFT(chartFFT, ref array_adc_volts);
                }

            }
            else
            {
                toolStripStatusLabelConnected.Text = "De10-LITE:Disconnected";
                toolStripStatusLabelDDS.Text = "";
                toolStripStatusLabelTrigger.Text = "";
            }

        }

        private void frmMainForm_Load(object sender, EventArgs e)
        {

            Timer_Refresh_Screen.Enabled = true;
            cmdVdiv.SelectedIndex = 0;

        }

        static void Data_transaction( )
        {
            while (true)
            {
                    data_rx_in_progress = true;
                    jtag.WriteByte(0x1e);//Console.WriteLine("WriteByte(0x1e)");
                    //Thread.Sleep(10);

                    if (jtag.GetAvailableBytes( ) == 0)
                    {
                        jtag.WriteByte(0x1f); //Console.WriteLine("WriteByte(0x1f)");

                        

                        for (int rx_counter = 0; rx_counter <= DATA_LENGTH; rx_counter++ )
                        {

                            //Console.WriteLine("rx_counter br:{0}", rx_counter);
                            byte[] data_from_board = jtag.Read(3);

                            msb = data_from_board[0];
                            medb = data_from_board[1];
                            lsb = data_from_board[2];
                            //Console.WriteLine("{0}.{1}.{2}  ", msb.ToString("X2"), medb.ToString("X2"), lsb.ToString("X2"));

                            //if (msb == 0xff & medb == 0xaa & lsb == 0x55)
                            if ((msb & 0xf0) == 0xf0 )
                            {
                                //Trigger_Txt_value.Text = String.Format("{0:0.00}",Convert.ToString(Convert.ToSingle(Trigger_Txt_value.Text) + 0.1f));
                                if (rx_counter == 0)
                                {
                                
                                    DDS_source = ( (medb & 0x20)>>5==0x01);//bit 6 indicate iff signal is from DDS or ADC 0:ADC  1:DDS. SW[0] on hardware selects the source.
                                    TriggerEnable = ((medb & 0x10) >> 4 == 0x01);//bit 5 indicate if trigger is set 0:not set 1:set. This is driven by the C# software only
                                    tdiv_device_response = (((msb & 0x07) << 2) | ((medb & 0xC0) >> 7 ));// reads the 5 bits containing the time/division index.When recconecting this updates the indicators
                                if (DDS_source)
                                        adc_trigger_value = GAIN_DDS*((float)((medb & 0x0f) << 8 | lsb) / (float)0xfff) ;
                                    else
                                        adc_trigger_value = GAIN_ADC_INPUT * ((float)((medb & 0x0f) << 8 | lsb) / (float)0xfff) * VREF;

                                }
                            //Console.WriteLine("{0} {1} {2}", msb.ToString("X2"), medb.ToString("X2"), lsb.ToString("X2"));
                            }//if (msb == 0xff )
                            else
                            {
                                //data_counter = (msb & 0x0f) << 4 | (medb & 0xf0) >> 4;//60 DATAPOINT
                                data_counter = (msb & 0x3f) << 4 | (medb & 0xf0) >> 4;//600 DATAPOINTS

                                if (data_counter > 0 & data_counter <= DATA_LENGTH - 1)
                                {
                                    adc_data = (medb & 0x0f) << 8 | lsb;
                                    array_adc_data[data_counter - 1] = adc_data - ADC_OFFSET;
                                }
                                else
                                {//handling an unknow bad data counter until resolved.
                                    adc_data = (medb & 0x0f) << 8 | msb;
                                    array_adc_data[rx_counter - 1] = adc_data - ADC_OFFSET;
                                    Console.WriteLine("rx_counter: {0}, data error {1}, GetAvailableBytes() :{2} : {3}.{4}.{5}", rx_counter, ++data_error_count, jtag.GetAvailableBytes(), msb.ToString("X2"), medb.ToString("X2"), lsb.ToString("X2"));
                                }
                            }//else
                            //rx_counter++;
                        }//for (rx_counter <= DATA_LENGTH)

                    }//if
                    else
                    {
                        Console.WriteLine("jtag.GetAvailableBytes()==0 failed dumping data and sending 0x1e");
                        jtag.Read(jtag.GetAvailableBytes());
                        jtag.WriteByte(0x1e); 
                        Console.WriteLine("WriteByte(0x1e) cleanup");

                    }//else

                //jtag.WriteByte(0x1e); Console.WriteLine("WriteByte(0x1e)  Sleep(250)");
                data_rx_in_progress = false;
                Thread.Sleep(250);//Refresh timer
            }//while(true)
        }//Data_transaction( )



        static void rx_jtag(ref JtagUart jtag, ref int[] array_adc_data)
        {
            int byte_count = 1;
            byte msb = 0, medb = 0, lsb = 0;
            byte msb2 = 0;
            int data_counter;// = (msb & 0x0f) << 4 | (medb & 0xf0) >> 4;
            int adc_data;// = (medb & 0x0f) << 8 | lsb;

            while (true)
            {

                if (jtag.GetAvailableBytes() >0)
                {
                    // | msb | medb | lsb |
                    byte[] data_from_board = jtag.Read(3);

                    msb = data_from_board[0];
                    medb = data_from_board[1];
                    lsb = data_from_board[2];

                    Console.WriteLine("{0}.{1}.{2}  {3}", msb.ToString("X2"), medb.ToString("X2"), lsb.ToString("X2"), DateTime.Now);

                    if (msb == 0xff & medb == 0xaa & lsb == 0x55)
                    {
                        //Console.WriteLine("{0} {1} {2}", msb.ToString("X2"), medb.ToString("X2"), lsb.ToString("X2"));
                    }
                    else
                    {
                        data_counter = (msb & 0x0f) << 4 | (medb & 0xf0) >> 4;
                        adc_data = (medb & 0x0f) << 8 | lsb;

                    }

                }

            }


        }

        private void pictureBoxScreen_Click(object sender, EventArgs e)
        {

        }

        private void cmb_TDIV_SelectedIndexChanged(object sender, EventArgs e)
        {
            tdiv = (byte)(cmb_TDIV.SelectedIndex);
            if (connect_device)
            {
                jtag.WriteByte(tdiv);
                jtag.WriteByte(0X00);

            }
            Console.WriteLine("TDIV={0}, {1}", tdiv,getTDIV_string(tdiv));
  

        }
        static int paint_counter = 0;
        private void pictureBoxScreen_Paint(object sender, PaintEventArgs e)
        {

            
            int y = 0;
            int y_trigger;

            Pen pen = new Pen(Color.Blue, 2);
            Point p;
            Point p_1 = new Point(0, 0);

            Pen pen_trigger = new Pen(Color.HotPink, 2);

            int v_per_div = 1;
            float v = 0.0f;

            //timebase x
            int i = 0;

            for (int x = 0; x < pictureBoxScreen.Width; x++)
                {

                if (DDS_source)
                {
                    v = GAIN_DDS * ((float)(array_adc_data[i++]) / (float)0xfff);
                    array_adc_volts[i - 1] = v;//used for fft
                }
                else
                {
                    v = GAIN_ADC_INPUT * ((float)(array_adc_data[i++]) / (float)0xfff) * VREF;
                    array_adc_volts[i - 1] = v;//used for fft
                }
                y = (pictureBoxScreen.Height / 2) - (int)(v * ((pictureBoxScreen.Height / 2) / (4 * v_per_div)));//currentyl 1v/div
                
                y_trigger = (pictureBoxScreen.Height / 2) - (int)(adc_trigger_value * ((pictureBoxScreen.Height / 2) / (4 * v_per_div)));

                Graphics gra = this.pictureBoxScreen.CreateGraphics();

                e.Graphics.DrawLine(pen_trigger, new Point(0, y_trigger), new Point(10, y_trigger));
                
                if (x >= 1)//
                {
                    p = new Point(x, y);
                    e.Graphics.DrawLine(pen, p, p_1);
                 }

                p_1.X = x; p_1.Y = y;
            }
        }



        private void trigger_btn_plus_Click(object sender, EventArgs e)
        {
            if (connect_device)
            {
                jtag.WriteByte(0x1d);
                //Thread.Sleep(1);
                jtag.WriteByte(0x00);
                jtag.WriteByte(0X1e);
            }

        }

        private void trigger_btn_minus_Click(object sender, EventArgs e)
        {
            //Trigger_Txt_value.Text = String.Format("{0:0.00}", Convert.ToString(Convert.ToSingle(Trigger_Txt_value.Text) - 0.1f));
            if (connect_device)
            {
                jtag.WriteByte(0x1c);
                //Thread.Sleep(1);
                jtag.WriteByte(0x00);
                jtag.WriteByte(0X1e);
            }
        }

        static int getFs(int TDIV)
        {
            switch (TDIV)
            {
                
                case 1: return 10000000;
                case 2: return 5000000;
                case 3: return 2500000;
                case 4: return 1666667;//1666666.667
                case 5: return 1000000;
                case 6: return 500000;
                case 7: return 200000;
                case 8: return 100000;
                case 9: return 50000;
                case 10: return 20000;
                case 11: return 10000;
                case 12: return 5000;
                case 13: return 2000;
                case 14: return 1000;
                case 15: return 500;
                case 16: return 200;
                case 17: return 100;
                case 18: return 50;
                case 19: return 20;
                case 20: return 10;
                case 21: return 5;
                case 22: return 2;
                case 23: return 1;
                default: return 0;
            }
        }


        static string getTDIV_string(int tdiv_device_response)
        {
            switch (tdiv_device_response)
            {
                case 1: return "5[us]/div";
                case 2: return "10[us]/div";
                case 3: return "20[us]/div";
                case 4: return "30[us]/div";
                case 5: return "50[us]/div";
                case 6: return "100[us]/div";
                case 7: return "250[us]/div";
                case 8: return "500[us]/div";
                case 9: return "1[ms]/div";
                case 10: return "2.5[ms]/div";
                case 11: return "5[ms]/div";
                case 12: return "10[ms]/div";
                case 13: return "25[ms]/div";
                case 14: return "50[ms]/div";
                case 15: return "100[ms]/div";
                case 16: return "250[ms]/div";
                case 17: return "500[ms]/div";
                case 18: return "1[s]/div";
                case 19: return "2.5[s]/div";
                case 20: return "5[s]/div";
                case 21: return "10[s]/div";
                case 22: return "25[s]/div";
                case 23: return "50[s]/div";
                default: return "1[s]/div";
            }
        }


        static void PlotFFT(Chart chartFFT,ref float[] array_adc_volts)
        {
            //https://www.youtube.com/watch?v=DqQlNoQW00w
            
            int numSamples = DATA_LENGTH - 1;
            double Fs = getFs(tdiv);

            Complex[] sig_cmplx = new Complex[array_adc_volts.Length-1];

            for (int i = 0; i < array_adc_volts.Length-1; i++)
                sig_cmplx[i] = new Complex(array_adc_volts[i]-1, 0);


            //hz per sample
            chartFFT.Series["Frequency"].Points.Clear();
            Fourier.Forward(sig_cmplx, FourierOptions.NoScaling);

            double hxPerSample = Fs / numSamples;

            chartFFT.ChartAreas["ChartArea1"].AxisX.Title = " F sampling = " + getFs(tdiv) + "Hz";
            chartFFT.ChartAreas["ChartArea1"].AxisX.TitleFont = new Font("Arial", 14.0f);
            chartFFT.ChartAreas["ChartArea1"].AxisX.MinorTickMark.Enabled = true;
            chartFFT.Series[0].ToolTip = "#SERIESNAME : Frequency:#VALX{F2} , Amplitude:#VALY{F2}";//https://stackoverflow.com/questions/17962754/show-tooltip-in-lineseries-winforms-chart

            for (int i = 1; i < sig_cmplx.Length / 10; i++)
            {
                //get magnitude of each FFT sample
                //abs[sqrt(r^2+i^2)]
                double mag = (2.0 / numSamples) * (Math.Abs(Math.Sqrt(Math.Pow(sig_cmplx[i].Real, 2) + Math.Pow(sig_cmplx[i].Imaginary, 2))));



                chartFFT.Series["Frequency"].Points.AddXY(hxPerSample * i, mag);
            }

        }

        private void button1_Click(object sender, EventArgs e)
        {

          

        }

        private void connectToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (jtag == null)
            {
                jtag = new JtagUart();
                jtag.WriteByte(tdiv); jtag.WriteByte(0x00);
                cmb_TDIV.SelectedIndex = tdiv;
                Data_transactionThread = new Thread(new ThreadStart(Data_transaction));
                Thread.Sleep(1000);//just to see the DE10lite configuration changeo on display
                Data_transactionThread.Start();//https://www.c-sharpcorner.com/article/Threads-in-CSharp/
                connect_device = true;
            }
            else
                MessageBox.Show("Device already connected", "Device Message");
        }

        private void disconnectToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }

        private void toolStripStatusLabelConnected_Click(object sender, EventArgs e)
        {

        }

        private void chartFFT_Click(object sender, EventArgs e)
        {

        }

        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {

        }

        private void chkTriggerEnable_CheckedChanged(object sender, EventArgs e)
        {
            if (connect_device)
            {
                if (chkTriggerEnable.Checked)
                    jtag.WriteByte(0x1a);
                else
                    jtag.WriteByte(0x1b);

                jtag.WriteByte(0x00);
            }
        }

        private void frmMainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            connect_device = false;
            Timer_Refresh_Screen.Enabled = false;
            Data_transactionThread.Abort();

        }

        


        
    }
}
