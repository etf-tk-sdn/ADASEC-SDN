from scapy.all import *
from scapy.utils import PcapWriter
import time
from random import randint
import argparse
import numpy as np
import math

#-----------------------------------------------------------------------

#Definition of distributions which can be used for changes in packet size and interarrival time:

def getExponentialValue(scale):   #scale parameter - represents expected average time between consecutive packets; low for high-speed and high-frequency traffic
    return np.random.exponential(scale)

def getWeibullValue(scale_param, shape_param):
    return scale_param * np.random.weibull(shape_param)

def getParetoValue(alpha, min_size):
   return int((np.random.pareto(alpha)+1)*min_size)

def getLogNormalValue(mu, sigma):
    return np.random.lognormal(mean=mu, sigma=sigma)

def getUniformValue(lower_bound, upper_bound):
    return random.uniform(lower_bound, upper_bound)

def getNormalValue(mean, std_dev):
    return np.random.normal(loc = mean, scale = std_dev)

def getConstantValue(constant):
    return constant

#-----------------------------------------------------------------------

#Function for obtaining random value for a given distribution and its parameters. This value will be used to define packet size and changes in timestamps

def getRandomValue(distribution, parameters):
    if (distribution == "Exponential"):
        size = getExponentialValue(parameters[0])
    elif(distribution == "Weibull"):
        size = getWeibullValue(parameters[0], parameters[1])
    elif(distribution == "Pareto"):
        size = getParetoValue(parameters[0], parameters[1])
    elif(distribution == "LogNormal"):
        size = getLogNormalValue(parameters[0], parameters[1])
    elif(distribution == "Uniform"):
        size = getUniformValue(parameters[0], parameters[1])
    elif(distribution == "Normal"):
        size = getNormalValue(parameters[0], parameters[1])
    elif(distribution == "Constant"):
        size = getConstantValue(parameters[0])

    return size

#-------------------------------------------------------------------------

def make_udp_stream(client_ip, server_ip, client_mac, server_mac, client_port, server_port, duration, ts_first_packet, pkt_time_distribution, itd_parameters, pkt_size_distribution, ps_parameters, content = ""):
    
    stream = []
    ts = ts_first_packet 
    br = 0
    vrijeme = 0
    header_size = 14 + 20 + 8 #ether + ipv4 + udp
    
    while ts<=duration:
        packet_len = 0
        while (packet_len <64 or packet_len>1500):    #Generate packet size within desired range (min packet size and MTU)    
            packet_len = int(getRandomValue(pkt_size_distribution, ps_parameters))

        udp_payload_len = packet_len - header_size
       # print(udp_payload_len)
        if content=="":
            payload = RandString(size = udp_payload_len)
        else:
            if udp_payload_len==len(content):
                payload = content
            elif udp_payload_len>len(content):
                #payload = content.zfill(int(udp_payload_len))    #dopuni sadrzaj nulama na duzinu udp_payload_len-a ako je kraci
                payload = content.ljust(int(udp_payload_len),'0') #dopunjavanje nulama s desne strane
            else: 
                payload = content[:udp_payload_len]       #skrati string na duzinu udp_payload_len-a
        p = { 'EtherDst' : client_mac,
              'EtherSrc' : server_mac,
              'IpSrc'    : server_ip,
              'IpDst'    : client_ip,
              'UdpSrc'   : server_port,
              'UdpDst'   : client_port,
              'UdpData'  : payload }
        stream.append((ts, p,))

        ts1 = getRandomValue(pkt_time_distribution, itd_parameters)
     #   print(ts1)
        if(ts1 < (packet_len*8)/(100*1e9)+0.00000000096):
           ts = ts+(packet_len*8)/(100*1e9)+0.00000000096
        else:
            ts = ts + ts1
            br = br+1
            print(br)
    return stream

#----------------------------------------------------------------------

def main():
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', required = True,
                        metavar = '<output pcap file name>')

    args = parser.parse_args()

    s = make_udp_stream(server_ip = "1.1.1.11", 
                        client_ip = "1.1.1.14",  
                        server_mac = "00:00:0c:01:01:11", 
                        client_mac = "00:00:0c:01:01:14", 
                        client_port = 80,        
                        server_port = 1050,             
                        duration = 0.00005,              
                        ts_first_packet = 0,       
                        pkt_time_distribution = "Exponential",
                        itd_parameters = [0.00000002036], 
                        pkt_size_distribution = "Pareto",
                        ps_parameters = [1.2,64],            
                        content=""
                      )           
           
        
    pcap = PcapWriter(args.out, append = True, sync = False, nano = True)

    for ts, pkt in s:
            scapy_pkt = Ether(dst = pkt['EtherDst'], src = pkt['EtherSrc'])/ \
                        IP(dst = pkt['IpSrc'], src = pkt['IpDst'])/ \
                        UDP(sport = pkt['UdpSrc'], dport = pkt['UdpDst'])/ \
                        Raw(load = '')
            if 'UdpData' in pkt:
                scapy_pkt[Raw].load = pkt['UdpData']

            # Write the scapy packet to the pcap
            scapy_pkt.time = ts
            pcap.write(scapy_pkt)
#----------------------------------------------------------------------

if __name__ == '__main__':
    main()
    
    
