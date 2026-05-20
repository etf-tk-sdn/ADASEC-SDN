from scapy.all import *
import sys
import pandas as pd

def comparePackets(paketi1, paketi2): #compare payloads of packets for 2 pcap files 
     lost_index = []
     i = 0;
     for paket in paketi1:
        # i = i+1
         if paket not in paketi2:
            print("Detected difference between packet payloads for packets with index " + str(i))
            lost_index.append(1)
         else:
            lost_index.append(0)
         i = i+1
     return lost_index


if __name__ == "__main__":
     pcap= rdpcap(sys.argv[1])     #original file with generated packets
     pcap2 = rdpcap(sys.argv[2])   #recorded file with pcap writer
     pcap = [pkt for pkt in pcap if UDP in pkt]

     comparePackets(pcap,pcap2)