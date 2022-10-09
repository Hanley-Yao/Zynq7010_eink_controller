using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Reflection;

/************************************************************************/
/*									                                    */
/*	TCPEchoServer                                                       */
/*									                                    */
/*	A chipKIT DNETcK TCP Echo Server application to 	                */
/*	work with the example DNETck TcpClient TcpEchoClient sketch.	    */
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
/*	12/19/2011(KeithV): Created					                        */
/*									                                    */
/************************************************************************/

namespace TCPEcho
{
    class TCPEchoServer
    {
        const int listeningPort = 44300;

        /***	static void Main(string[] args)
         *
         *	Parameters:
         *          args - command line argumets, unused
         *              
         *	Return Values:
         *          None
         *
         *	Description: 
         *	
         *      For use with TcpEchoClient sketch
         *      
         *      Listens on a 11000 for a connection
         *      Echo's whatever comes in back on the connection
         *      After 5 seconds of no input, it drops the client and starts listening again
         *      Hit ^C to kill the application
         * ------------------------------------------------------------ */
        static void Main(string[] args)
        {
            AssemblyName asmName = Assembly.GetExecutingAssembly().GetName();
            Console.WriteLine("{0} Version {1}", asmName.Name, asmName.Version.ToString());
            Console.WriteLine("Digilent, Copyright 2011");
            Console.WriteLine("");
 
            try
            {
                IPAddress[] ipList = Dns.GetHostEntry("").AddressList;
                IPAddress ipHost = null;
                IPEndPoint listeningEndPoint = null;
                TcpListener tcpListener = null;

                // find an IPv4 address.
                foreach (IPAddress ip in ipList)
                {
                    if (ip.AddressFamily == AddressFamily.InterNetwork)
                    {
                        ipHost = ip;
                        break;
                    }
                }
                listeningEndPoint = new IPEndPoint(ipHost, listeningPort);
                tcpListener = new TcpListener(listeningEndPoint);

                byte[] rgbMsg = new byte[1024];
                TcpClient tcpClient = null;
                NetworkStream tcpStream = null;

                tcpListener.Start();
                do
                {
                    Console.WriteLine("Listening on port {0}", listeningPort.ToString());

                    // block until we get a client
                    tcpClient = tcpListener.AcceptTcpClient();
                    tcpStream = tcpClient.GetStream();
                    tcpStream.ReadTimeout = 5000;

                    Console.WriteLine("Detected Client");

                    while (tcpClient.Connected)
                    {
                        int cbRead = 0;

                        try
                        {
                            if ((cbRead = tcpStream.Read(rgbMsg, 0, rgbMsg.Length)) > 0)
                            {
                                Encoding ascii = Encoding.ASCII;
                                string sz = ascii.GetString(rgbMsg, 0, cbRead);

                                // Console.WriteLine("Writing string:");
                                Console.Write(sz);
                                tcpStream.Write(rgbMsg, 0, cbRead);
                            }
                            else
                            {
                                break;
                            }
                        }
                        catch
                        {
                            break;
                        }
                    }
                    tcpStream.Close();
                    tcpClient.Close();

                } while (true);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }
    }
}
