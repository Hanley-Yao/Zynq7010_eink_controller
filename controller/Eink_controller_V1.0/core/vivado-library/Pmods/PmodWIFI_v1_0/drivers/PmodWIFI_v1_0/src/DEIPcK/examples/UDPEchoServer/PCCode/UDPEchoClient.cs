/************************************************************************/
/*									                                    */
/*	UDPEchoClient                                                       */
/*									                                    */
/*	A chipKIT DNETcK UDP Echo Client application to 	                */
/*	work with the example DNETck UdpClient UDPEchoServer sketch.	    */
/*									                                    */
/************************************************************************/
/*	Author: 	Keith Vogel 					                        */
/*	Copyright 2011, Digilent Inc.					                    */
/************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*									                                    */
/*									                                    */
/************************************************************************/
/*  Revision History:							                        */
/*									                                    */
/*	12/20/2011(KeithV): Created					                        */
/*									                                    */
/************************************************************************/

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Reflection;


namespace UDPEchoClient
{
    public partial class UDPEchoClient : Form
    {
        private const string szError = "Error: ";
        private const string szNone = "";
        private const string szInfo = "Info: ";
        private const string szSend = "TX: ";
        private const string szReceived = "RX: ";

        private delegate void PrintTextDelegate(string szText, Color color);
        private PrintTextDelegate DPrintText = null;

        private UdpClient udpClient = null;
        private IPEndPoint remoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);
        private Thread thrd = null;

        /***	public UDPEchoClient()
         *
         *	Constructor:
         *	
         *      Puts up the UDPEchoClient Windows Form
         *      
         *      Put the selection at the end of the text to send and have echo'ed
         *      
         *      By default this is set to go to 192.168.1.190:1200 for the echo server
         *      Hitting a return in the form defaults to hitting the Send button
         * ------------------------------------------------------------ */
        public UDPEchoClient()
        {
            DPrintText = PrintText;
            AssemblyName asmName = Assembly.GetExecutingAssembly().GetName();
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine("");

            InitializeComponent();
            AcceptButton = Send;

            SendText.Select();
            SendText.SelectionStart = SendText.Text.Length;
            SendText.SelectionLength = 0;

            PrintText(asmName.Name + " Version " + asmName.Version.ToString(), Color.Black);
            PrintText("Digilent, Copyright 2011", Color.Black);
        }

        /***	void Send_Click(object sender, EventArgs e)
         *
         *	Parameters:
         *          sender - the sending control; unused
         *          e       - the event data; unused.      
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This is what is called when the Send button is clicked
         *      
         *      If a UdpClient is not resolved, it attempts to resolve one using
         *      the hostname and port
         *      Once resolved, the text is sent to the remote server
         *      
         * ------------------------------------------------------------ */
        private void Send_Click(object sender, EventArgs e)
        {

            // see if we need to get a new udpClient pointing to the server
            if (udpClient == null)
            {
                PrintText("Please wait, attempting to resolve remote endpoint: " + Hostname.Text + ":" + Port.Text, Color.Orange);
                Update();
                try
                {
                    thrd = new Thread(ListenForResponse);
                    int portNbr = Convert.ToInt32(Port.Text);
                    udpClient = new UdpClient(Hostname.Text, portNbr);
                    thrd.Start(this);
                }
                catch
                {
                    if (udpClient != null)
                    {
                        udpClient.Close();
                        udpClient = null;
                    }
                    PrintText("Unable to resolve remote endpoint " + Hostname.Text + ":" + Port.Text, Color.Red);
                    return;
                }
            }

            // we resolved our endpoint to the server
            // go ahead and send the string.
            try
            {
                Encoding ascii = Encoding.ASCII;
                Byte[] encodedBytes = ascii.GetBytes(SendText.Text);

                udpClient.Send(encodedBytes, encodedBytes.Length);
                PrintText(SendText.Text, Color.Green);
            }
            catch
            {
                PrintText("Unable to send string " + SendText.Text, Color.Red);
                return;
            }
        }

        /***	void PrintText(string szText, Color color)
         *
         *	Parameters:
         *          szText - a string of text to display in the log box
         *          color  - the color to print it out
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This will diplay the text in the log box with color
         *      Some colors will automatically be given a prefix string
         *      
         *      See the if - else if code below for color and prefix matching.
         *      If the color is not in the list, no prefix is prepended to the string.
         *      
         * ------------------------------------------------------------ */
        private void PrintText(string szText, Color color)
        {
            string szPrefix = szNone;

            if (color == Color.Red)
            {
                szPrefix = szError;
            }
            else if (color == Color.Orange)
            {
                szPrefix = szInfo;
           }
            else if (color == Color.Blue)
            {
                szPrefix = szReceived;
            }
            else if (color == Color.Green)
            {
                szPrefix = szSend;
            }

            Log.SelectionColor = color;
            Log.SelectedText = szPrefix + szText + '\n';
            Log.SelectionStart = Log.Text.Length;
            Log.ScrollToCaret();
        }

        /***	void PrintTextSafe(string szText, Color color)
         *
         *	Parameters:
         *          szText - a string of text to display in the log box
         *          color  - the color to print it out
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This is a thread safe version of PrintText().
         *      
         *      Apartment model forms must all run under the same thread
         *      The Inoke will cause the forms owning thread to display the string
         *      This only has to be called from threads other than that, that the form
         *      is running on. It is possible for the form to be closed, so we trap exceptions.
         * ------------------------------------------------------------ */
        private void PrintTextSafe(string szText, Color color)
        {
            try
            {
                Invoke(DPrintText, szText, color);
            }
            // if we closed the form we can not Invoke and we may get exception when closing the form
            catch
            {
            }
        }

        /***	void ListenForResponse(Object obj)
         *
         *	Parameters:
         *          obj - a "this" pointer to the instantiated of the form
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This gets invoked to listen for any incoming data from our remote endpoint
         *      And safely prints it to the log. If the udpClient is nulled, the thread closes
         *      as well as closes the udpClient if any.
         * ------------------------------------------------------------ */
        private void ListenForResponse(Object obj)
        {
            UDPEchoClient me = (UDPEchoClient)obj;
            Byte[] rgbIn = null;

            PrintTextSafe("Starting to listen", Color.Black);

            // this will kick us out if we wait too long
            me.udpClient.Client.ReceiveTimeout = 5000;

            try
            {
                while (me.udpClient != null)
                {
                    rgbIn = me.udpClient.Receive(ref remoteIpEndPoint);
                    try
                    {
                        Encoding ascii = Encoding.ASCII;
                        string sz = ascii.GetString(rgbIn, 0, rgbIn.Length);
                        PrintTextSafe(sz, Color.Blue);
                    }
                    catch
                    {
                        PrintTextSafe("Unrecognized string: " + rgbIn.ToString(), Color.Red);
                    }
                }
            }
            catch
            {
            }
            finally
            {
                // kill our stream and connection
                if (me.udpClient != null)
                {
                    me.udpClient.Close();
                    me.udpClient = null;
                }
            }

            PrintTextSafe("Ending listening", Color.Black);
        }

        /***	void UDPEchoClient_Close(object sender, EventArgs e)
         *
         *	Parameters:
         *          sender - the sending control; unused
         *          e       - the event data; unused.      
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This is called when the form is closed. The red X on the form.
         *      
         *      Shuts down the stream and connections, this will cause the 
         *      listening thread to die. The listening thread will try to 
         *      print a message, but the form will already beclosed and the thread
         *      will get an Inovke exception, but that is caught and the thread dies.
         * ------------------------------------------------------------ */
        private void UDPEchoClient_Close(object sender, EventArgs e)
        {

            // Kill our stream and kill the waiting thread
            if (udpClient != null)
            {
                udpClient.Close();
                udpClient = null;
            } 
        }

        /***	void ClearLog_Click(object sender, EventArgs e)
         *
         *	Parameters:
         *          sender - the sending control; unused
         *          e       - the event data; unused.      
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      This is called when the form's clear log button is hit.
         *      
         *      Just clears the log window.
         * ------------------------------------------------------------ */
        private void ClearLog_Click(object sender, EventArgs e)
        {
            Log.Clear();
        }
    }
}
