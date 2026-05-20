from scapy.all import *
import sys
import pandas as pd

def filtrirajPoSrcAdresi(paketi, filtered_pcap, src_address):
     filtered_packets = [] 
     timestamps = [] 
     src_add = []
     dst_add = [] 
     src_port = [] 
     dst_port = [] 
     packet_len = [] 
     payload = []
     for paket in paketi:
         if paket[IP].src == src_address:
             filtered_packets.append(paket)
             timestamps.append(str(paket.time))
             src_add.append(str(paket[IP].src))
             dst_add.append(str(paket[IP].dst))
             src_port.append(str(paket[UDP].sport))
             dst_port.append(str(paket[UDP].dport))
             packet_len.append(str(len(paket)))
             payload.append(str(paket[UDP].payload))

     new_list = [{"Timestamp": timestamps[i], "Source address": src_add[i], "Destination address": dst_add[i], "Source port": src_port[i], "Destination port": dst_port[i], "Length": packet_len[i], "Payload": payload[i]} for i in range(len(src_add))]
     wrpcap(filtered_pcap, filtered_packets)

def numberOfPackets(paketi):
    return len(paketi)

def getThroughput(paketi):
    number_of_bytes = 0
    number_of_bytes_list = []
    timestamps = getTimestamps(paketi)
    throughput = []
    throughput.append(0)
    for paket in paketi: 
        number_of_bytes = number_of_bytes + len(paket)
        number_of_bytes_list.append(number_of_bytes)

    for i in range (0,len(timestamps)-1):
         throughput.append((number_of_bytes_list[i]*8)/(timestamps[i+1]))

    return throughput

def getTimestamps(paketi):
    timestamps = []
    for paket in paketi: 
        timestamps.append(paket.time)
    return timestamps

def getDeltaTimes(paketi):
    deltatimes = []
    timestamps = getTimestamps(paketi) 
    deltatimes.append(0)
    for i in range(1, len(timestamps)):
        delta = timestamps[i] - timestamps[i-1]
        deltatimes.append(delta)
    return deltatimes

def getSize(paketi):
    size = []
    for paket in paketi: 
        size.append(len(paket))
    return size

def getDelays(paketi1, paketi2):
    timestamps1 = getTimestamps(paketi1)
    timestamps2 = getTimestamps(paketi2)
    delays = [x - y for x, y in zip(timestamps2, timestamps1)]
    return delays

def extractData(paketi1, paketi2):   #Extract relevant data from pcap files (first original, second recorded) and save it in csv format
     timestamp1 = getTimestamps(paketi1) 
     timestamp2 = getTimestamps(paketi2)
     size1 = getSize(paketi1)
     delays1 = getDeltaTimes(paketi1)
     delays2 = getDeltaTimes(paketi2)
     delays = getDelays(paketi1, paketi2)
     throughput = getThroughput(paketi1)
     throughput2 = getThroughput(paketi2)
     df = pd.DataFrame({'snd_timestamp': timestamp1, 'rcv_timestamp': timestamp2, 'size': size1, 'snd_delta_times': delays1, 'rcv_delta_times': delays2, 'delays': delays, 'throughput1': throughput, 'throughput2': throughput2})
     df.to_csv('nestonovo_merge1_drugi.csv', index=True)

if __name__ == "__main__":
     pcap= rdpcap(sys.argv[1])     #original file with generated packets
     pcap2 = rdpcap(sys.argv[2])   #recorded file with pcap writer
     extractData(pcap,pcap2)
 

     