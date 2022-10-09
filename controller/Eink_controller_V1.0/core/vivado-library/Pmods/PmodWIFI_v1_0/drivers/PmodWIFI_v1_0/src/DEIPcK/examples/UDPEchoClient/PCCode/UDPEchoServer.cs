/************************************************************************/
/*									                                    */
/*	UDPEchoServer                                                     */
/*									                                    */
/*	A chipKIT DNETcK UDP Server application to 	                        */
/*	demonstrate how to use the UdpClient Class.	                        */
/*	This can be used in conjuction  with UDPEchoClient		            */
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
/*	12/21/2011(KeithV): Created					                        */
/*									                                    */
/************************************************************************/
using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Sockets;
using System.Net;
using System.Threading;
using System.Reflection;


namespace UDPEchoServer
{
    class UDPEchoServer
    {
        const int listeningPort = 44400;

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
         *      For use with UDPEchoClient sketch
         *      
         *      Listens on a 12000 for a UDP Datagram
         *      Echo's whatever comes in back
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
                UdpClient udpListener = null;


                // find my IPv4 address; remember the computer can support many IP address depending
                // the network card, WiFi used. We want an IPv4 local IP address
                foreach (IPAddress ip in ipList)
                {
                    if (ip.AddressFamily == AddressFamily.InterNetwork)
                    {
                        ipHost = ip;
                        break;
                    }
                }
                listeningEndPoint = new IPEndPoint(ipHost, listeningPort);
                udpListener = new UdpClient(listeningEndPoint);
                udpListener.Client.ReceiveTimeout = -1;     // wait for every

                // here is our listening loop
                do
                {
                    IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
                    Byte[] rgbIn = null;

                    Console.WriteLine("Listening on port: {0}.", listeningPort.ToString());

                    // now listen for an incoming datagram
                    if ((rgbIn = udpListener.Receive(ref remoteEP)) != null)
                    {
                        try
                        {
                            Encoding ascii = Encoding.ASCII;
                            string sz = ascii.GetString(rgbIn, 0, rgbIn.Length);
                            Console.WriteLine("Datagram detected:");
                            Console.Write(sz);
                        }

                        // something went wrong, probably not ascii data
                        catch
                        {
                            Console.WriteLine("Error in decoding string");
                        }
    
                        // always attempt to write back the data
                        finally
                        {
                            udpListener.Send(rgbIn, rgbIn.Length, remoteEP);
                        }
                    }

                } while (true);
            }

            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
        }
    }
}
