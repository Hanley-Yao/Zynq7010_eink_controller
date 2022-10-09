/************************************************************************/
/*                                                                      */
/*	DHCP.h  This implements the DHCP code per RFC 2131                  */
/*          as part of the application Layer                            */
/*                                                                      */
/************************************************************************/
/*  Author:     Keith Vogel                                             */
/*  Copyright 2013, Digilent Inc.                                       */
/************************************************************************/
/* deIP core network library
*
* Copyright (c) 2013-2014, Digilent <www.digilentinc.com>
* Contact Digilent for the latest version.
*
* This program is free software; distributed under the terms of 
* BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/************************************************************************/
/*  Module Description:                                                 */
/*                                                                      */
/*	Technecally DHCP is implemented at the application layer            */
/*	with hooks into the link layer                                      */
/************************************************************************/
/*  Revision History:                                                   */
/*                                                                      */
/*	4/11/2013(KeithV): Created                                          */
/*                                                                      */
/************************************************************************/

#ifndef DHCP_H
#define	DHCP_H

#ifdef	__cplusplus
extern "C" {
#endif

#define MAXDISCOVETRIES   3
// 1 === DHCPDISCOVER, 2== DHCPOFFER, 3 == DHCPREQUEST, 4== DHCPDECLINE, 5==DHCPACK, 6== DHCPNAK, 7== DHCPRELEASE

// do this as #defines instead of enum to define the size as a uint8_t
#define DHCPSTATE uint8_t
// these states are defined by the RFC
#define     dhcpDISABLED        0   // Nothing is setup
            
// all states after dhcpDISABLE to dhcpSTARTConnected dhcp states of getting an IP

// these particular states are given the same numeric value as defined in the RFC
#define     dhcpSTARTPending    1   // start of the pending states
#define     dhcpDISCOVER        1   // client sends a discover request
#define     dhcpOFFER           2   // server overs client an IP
#define     dhcpREQUEST         3   // client requests an IP
#define     dhcpDECLINE         4   // client declines an offer
#define     dhcpACK             5   // server ack clients request
#define     dhcpNAK             6   // server declines clients request
#define     dhcpRELEASE         7   // client released its IP
#define     dhcpINFORM          8   // client ask for information, there is an assigned number.. I don't know what it is

// extra states to use in the state machine
#define    dhcpRetryDISCOVER    50
#define    dhcpStartDISCOVER    51
#define    dhcpARPWait          52
#define    dhcpACCEPT           53
            
// These are all active states where we have our IP and masks and stuff
#define    dhcpSTARTConnected   100 // this is the start of the connected states
#define    dhcpBOUND            100 // client is bound and got an IP
#define    dhcpRENEW            101 // still active, but renewing
#define    dhcpSTATICIP         102 // client is not using DHCP, uses statically assigned IP
#define    dhcpENDStates        103 // the end of all states

// END OF STATE MACHINE STATES

// options have the form op, len, x,x,x,x...
// the byte count given is all inclusive of the op, len, and value
#define dhcpOpPad               0           // 1b padding for alignment
#define dhcpOpSubMask           1           // 6b Submask
#define dhcpOpTimeOffset        2           // 6b UTC offset value
#define dhcpOpRouter            3           // 2 + 4x. List of IPs for routers.
#define dhcpOpTimeServer        4           // 2 + 4x. List of time server IPs
#define dhcpOpNameServer        5           // 2 + 4x. List of name server IPs
#define dhcpOpDomainNameServer  6           // 2 + 4x. List of domain name server (DNS) IPs
#define dhcpOpLogServer         7           // 2 + 4x. List of log servers
#define dhcpOpCookieServer      8           // 2 + 4x. List of cookie servers
#define dhcpOpPrintServer       9           // 2 + 4x. List of print (LPR) servers
#define dhcpOpImpressServer     10          // 2 + 4x. List of Impress servers ???
#define dhcpOpResourceLocServer 11          // 2 + 4x. List of resources location servers
#define dhcpOpHostName          12          // 2 + x. A string containing the host name.
#define dhcpOpBootFileSize      13          // 4b, boot files length.
#define dhcpOpMeritDumpFile     14          // 2 + x. path to dump core on crash
#define dhcpOpDomainName        15          // 2 + x. A string containing the domain name
#define dhcpOpSwapServer        16          // 6b IP of the clients swap server ???
#define dhcpOpRootPath          17          //2 + x. The cleints root path disk name string
#define dhcpOpExtensionsPath    18          // TFTP filepath for vendor extensions
#define dhcpOpIPForwarding      19          // 3b 0=disable IP fowarding, 1 == enable IP forwarding
#define dhcpOpNonLocalRouting   20          // 3b, 0=diable routing, 1 == enable.
#define dhcpOpPolicyFilter      21          // 2 + 8x IP/Mask pairs
#define dhcpOpMxDGReassmblySize 22          // 4b, how big a datagram should the clilent be able to reassemble
#define dhcpOpTimeToLive        23          // 3b, The Time to Live to use for packets on the net
#define dhcpOpMTUAgingTimeout   24          // 6b, timeout in sec as per RFC 1191
#define dhcpOpMTUPlateauTable   25          // 2 + 2x. MTU Discovery RFC 1191
#define dhcpOpInterfaceMTU      26          // 4b, MUT size on the IP network
#define dhcpOpSubnetsAreLocal   27          // 3b, 0==not all subnet share same MTU, 1 == all subnets share same MTU
#define dhcpOpBroadcastAddr     28          // 6b, broadcast addresses on the subent are in use
#define dhcpOpICMPMaskDiscovery 29          // 3b, 0==no ICMP mask discovery, 1== do ICMP mask discovery
#define dhcpOpMaskSupplier      30          // 3b, 0===don't respond to ICMP mask request, 1==respond to ICMP mask request
#define dhcpOpRouterDiscovery   31          // 3b, 0==do not do RFC 1256 router discovery, 1== do router discovery
#define dhcpOpRouterSolicit     32          // 6b, Address for client to transmit router solicitaiton requests
#define dhcpOpStaticRouters     33          // 2 + 8x, destination router IP pairs. The destination IP and the router to forward to.
#define dhcpOpARPTrailers       34          // 0==do not use trailers, 1 == use trailers
#define dhcpOpARPTimeout        35          // 6b, time in seconds for an ARP entry to timeout.
#define dhcpOpEthernetEncap     36          // 3b, use RFC 894 or IEEE 802.3 (RFC 1042) encapsulation. 0== 894, 1== 1042
#define dhcpOpTCPTimeToLive     37          // 3b, TTL value to use for TCP
#define dhcpOpTCPKeepAlive      38          // 6b, how long in seconds before sending a keep alive probe on the TCP connection
#define dhcpOpTCPGarbage        39          // 3b, 0== do not send garbage byte, 1== send garbage byte
#define dhcpOpNetInfoService    40          // 2 + x, stringof clients NIS domain in NVT ascii
#define dhcpOpNetInfoIPs        41          // 2 + 4x, list of net info servers IPs
#define dhcpOpNetTimeServer     42          // 2 + 4x. List of NTP time servers IPs
#define dhcpOpVenderSpecficInfo 43          // 2+ x. vendor specific
#define dhcpOpNetBIOSoverTCP    44          // 2+4x. List of NBNS Name servers IPs
#define dhcpOpNetBIOSDGServers  45          // 2+4x, List of NBDD servers
#define dhcpOpNetBIOSNode       46          // 3b, 0x1 == B-node, 0x2 == P-node, 0x4 == M-node, 0x8 == H-node
#define dhcpOpNetBIOSScope      47          // 2+x, see RFC 1001/1002
#define dhcpOpXWindowFont       48          // 2 + 4x IP list of font servers
#define dhcpOpXWindowDisplay    49          // 2+ 4x, IP list of Display managers

// DHCP options!!!
#define dhcpOpRequstIP          50          // 6b, client request a specific IP on discover
#define dhcpOpIPLeaseTime       51          // 6b time in seconds the clent requests for a lease discover, request or server offer
#define dhcpOpOptionOverload    52          // 3b, Using sname or file fields to put DHCP options in them instead. 1==file, 2 == sanme, 3 == both
#define dhcpOpMessageType       53          // 3b, 1 === DHCPDISCOVER, 2== DHCPOFFER, 3 == DHCPREQUEST, 4== DHCPDECLINE, 5==DHCPACK, 6== DHCPNAK, 7== DHCPRELEASE
#define dhcpOpServerIdent       54          // 6b, DHCPOFFER, DHCPREQUEST, DHCPACK, DHCPNAK; accepting lease offer in client request sent by server offer
#define dhcpOpParamRequestList  55          //2 + x. Client request the sever return options (like submask), this is a list of 1 byte options the client is requesting
#define dhcpOpMessage           56          // 2+x. Used by server to return an error message to client, NVT ascii error string. request error
#define dhcpOpMaxMessageSize    57          // 4b, max DHCP in client discover, request but not in decline. Limits how big the server can send a DHCP message back. Min value 576
#define dhcpOpRenewalTime       58          // 6b, how long until the IP address can be used before renewal in seconds
#define dhcpOpReBindTime        59          // 6b, how long until the client need to enter rebinding of the IP in seconds
#define dhcpOpClassIdent        60          // 2+x, Client class identifiers, sort of vendor specific
#define dhcpOpClientIdent       61          //2b + 1b-type + xb-addr. Clients unique ID for communcicaitons. Typically hardware type and address

#define dhcpOpEnd               255         // 1b end of options


/*
 Hardware types...... RFC 1340

1 Ethernet (10Mb) [JBP]
2 Experimental Ethernet (3Mb) [JBP]
3 Amateur Radio AX.25 [PXK]
4 Proteon ProNET Token Ring [JBP]
5 Chaos [GXP]
6 IEEE 802 Networks [JBP]
7 ARCNET [JBP]
8 Hyperchannel [JBP]
9 Lanstar [TU]
10 Autonet Short Address [MXB1]
11 LocalTalk [JKR1]
12 LocalNet (IBM PCNet or SYTEK LocalNET) [JXM]
13 Ultra link [RXD2]
14 SMDS [GXC1]
15 Frame Relay [AGM]
16 Asynchronous Transmission Mode (ATM) [JXB2]
*/

// since we don't have a network mask yet, require the DHCP to use a full 255.255.255.255 board cast IP
// this is in network order already as we don't deal with switching for DHCP packets
#define DHCPREQUIREBROADCAST    0x0080
#define DHCPMINRENEWTIME        60

#define BOOTREQUEST 1
#define BOOTREPLY   2

// MagicCookie 99.130.83.99  or 0x63 0x82 0x53 0x63
#define MAGICCOOKIE 0x63538263

#pragma pack(push,1)
typedef struct DHCPDG_T
{
    uint8_t     op;             // BOOTREQUEST == 1, BOOTREPLY == 2
    uint8_t     htype;          // always hwtypeEthernet == 1
    uint8_t     hlen;           // length of the mac == 6
    uint8_t     hops;           // usually 0
    uint32_t    xid;            // random number
    uint16_t    secs;           // sec sense start of BootP process, or 0
    uint16_t    flags;          // broadcast flag, we arn't using, set to 0
    IPv4        ciaddr;         // client internet address
    IPv4        yiaddr;         // your internet address
    IPv4        siaddr;         // server internet address
    IPv4        giaddr;         // relay agent internet address, usually 0
    uint8_t     chaddr[16];     // hardware address... MAC
    uint8_t     sname[64];      // server name, almost always 0s
    uint8_t     file[128];      // file name, bootp record, almost always 0s
    IPv4        MagicCookie;    // always 99.130.83.99; not really an IP, but it is easy to make it as such (I think 0x63538263).
    uint8_t     options[0];      // variable lenght options ends with the end opiton of 0xFF
} DHCPDG;
#pragma pack(pop)

#define cbDHCPOptions       32  // this is how much DHCP option space we need to do a dicovery and request; mult of 4 bytes
#define cbMinDHCPDGSize     576
#define dhcpInfiniteLease   0xFFFFFFFF  // the value for an infinite lease time
#define dhcpMaxRetryTime    60          // only return for 60 seconds
#define dhcpInitRetryTime   4           // required, 4 + 8 + 16 + 32 = 60
typedef struct DHCPMEM_T
{
    uint32_t            tsStart;
    uint32_t            tsLease;
    uint32_t            tsRenew;        // unicast REQUEST for new lease, default .5 lease; set ciaddr, do not send server ident
    union
    {
        uint32_t        tsReBind;       // broadcast REQUEST for new lease, default .875 lease time; set ciaddr, do not send server ident
        uint32_t        cTryDiscovery;  // The number of times to retry before giving up
    };
    IPSTACK             ipStack;
    ETHERNETII_FRAME    frameII;        // maybe we can share the ARP frame, but only if we ALWAYS broadcast to the server.
    IPv4HDR             ipv4Hdr;
    UDPHDR              udpHdr;
    DHCPDG              dgDHCP;
    uint8_t             rgbOptions[cbDHCPOptions];
    UDPSOCKET           socket;
} DHCPMEM;

void DHCPPeriodicTasks(void);

#ifdef	__cplusplus
}
#endif  // __cplusplus

#endif	// DHCP_H

