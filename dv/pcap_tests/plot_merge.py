from scapy.all import *
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load the CSV file
df1 = pd.read_csv('nestonovo_merge1_prvi.csv')
df2 = pd.read_csv('nestonovo_merge1_drugi.csv') 
x1 = df1.index.values
x2 = df2.index.values

#--------------------------------------------------------------------------------------------------------------


def getTimestamps(paketi):
    timestamps = []
    for paket in paketi: 
        #print (paket.time) 
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

def extractData(paketi,name):   #Extract relevant data from pcap files (first original, second recorded) and save it in csv format
     timestamp = getTimestamps(paketi)
     delays = getDeltaTimes(paketi)
     size = getSize(paketi)
     df = pd.DataFrame({'snd_timestamp': timestamp, 'snd_delta_times': delays, 'size': size})
     df.to_csv(name, index=True)

# 1) Karakteristike ulaznog file-a:

pcap= rdpcap('nestonovo1.pcap')
extractData(pcap,'nestonovo1.csv')

pcap2= rdpcap('nestonovo2.pcap')
extractData(pcap2,'nestonovo2.csv')

dfa = pd.read_csv('nestonovo1.csv')
dfb = pd.read_csv('nestonovo2.csv')

#Raspodjela velicine paketa

fig, axs = plt.subplots(2, 1, figsize=(6.4, 11)) #
sns.histplot(dfa['size'], kde=True, bins=50, color='purple', ax=axs[0]) #
sns.histplot(dfa['snd_delta_times'], kde=True,bins=50, color='blue', ax=axs[1])
axs[0].set_title('Packet size distribution',fontsize=12)
axs[1].set_title('Interarrival time distribution',fontsize=12)
axs[0].set_xlabel('Packet size',fontsize=10)
axs[0].set_ylabel('Count/Frequency',fontsize=10)
axs[1].set_xlabel('Interarrival time',fontsize=10)
axs[1].set_ylabel('Count/Frequency',fontsize=10)
plt.subplots_adjust(hspace=0.4)
#plt.title('First flow')
plt.savefig('first_flow_distributions.pdf', bbox_inches='tight')
plt.show()

fig, axs = plt.subplots(2, 1, figsize=(6.4, 11)) #
sns.histplot(dfb['size'], kde=True, bins=50, color='purple', ax=axs[0]) #
sns.histplot(dfb['snd_delta_times'], kde=True,bins=50, color='blue', ax=axs[1])
axs[0].set_title('Packet size distribution',fontsize=12)
axs[1].set_title('Interarrival time distribution',fontsize=12)
axs[0].set_xlabel('Packet size',fontsize=10)
axs[0].set_ylabel('Count/Frequency',fontsize=10)
axs[1].set_xlabel('Interarrival time',fontsize=10)
axs[1].set_ylabel('Count/Frequency',fontsize=10)
plt.subplots_adjust(hspace=0.4)
plt.savefig('second_flow_distributions.pdf', bbox_inches='tight')
plt.show()


#2) Rezultati: delay i throughput

plt.plot(x1, df1['delays'], label = "First flow")
plt.plot(x2, df2['delays'], label = "Second flow")
plt.legend(loc='best')
plt.grid(color='0.85', linestyle='--', linewidth=0.5, alpha=0.5)
plt.ticklabel_format(axis='y', style='sci', scilimits=(0, 0)) 
plt.xlabel('Packet index')
plt.ylabel('Delay [seconds]')
plt.savefig('delay_merged.pdf', bbox_inches='tight')
plt.show()

plt.plot(x1, df1['throughput2'], label = "First flow")
plt.plot(x2, df2['throughput2'], label = "Second flow")
plt.legend(loc='best')
plt.grid(color='0.85', linestyle='--', linewidth=0.5, alpha=0.5)
plt.xlabel('Packet index')
plt.ylabel('Troughput [bps]')
plt.savefig('throughput_merged.pdf', bbox_inches='tight')
plt.show()





