import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load the CSV files
df1 = pd.read_csv('amina1.csv')
df2 = pd.read_csv('amina2.csv')
df3 = pd.read_csv('amina3.csv')
df4 = pd.read_csv('amina4.csv')
x = df1.index.values

#--------------------------------------------------------------------------------------------------------------

# 1) Karakteristike ulaznog file-a:

#Raspodjela velicine paketa
sns.histplot(df1['size'], kde=True, bins=50, color='purple') #
plt.xlabel('Packet size')
plt.ylabel('Count/frequency')
plt.title('Packet size distribution')
plt.savefig('packet_size.pdf', bbox_inches='tight')
plt.show()

#Raspodjela interarrival time-a:
sns.histplot(df1['snd_delta_times'], kde=True, bins=50, color='blue') #
plt.xlabel('Interarrival time')
plt.ylabel('Count/frequency')
plt.title('Interarrival time distribution')
plt.savefig('int_time.pdf', bbox_inches='tight')
plt.show()

#2) Rezultati: delay i throughput

plt.plot(x, df1['delays'], label = "KR = 100 Gbps")
plt.plot(x, df2['delays'], label = "KR = 50 Gbps")
plt.plot(x, df3['delays'], label = "KR = 25 Gbps")
plt.plot(x, df4['delays'], label = "KR = 20 Gbps")
plt.legend(loc='best')
plt.grid(color='0.85', linestyle='--', linewidth=0.5, alpha=0.5)
plt.xlabel('Packet index')
plt.ylabel('Delay [seconds]')
plt.savefig('delay.pdf', bbox_inches='tight')
plt.show()

plt.plot(x, df1['throughput2'], label = "KR = 100 Gbps")
plt.plot(x, df2['throughput2'], label = "KR = 50 Gbps")
plt.plot(x, df3['throughput2'], label = "KR = 25 Gbps")
plt.plot(x, df4['throughput2'], label = "KR = 20 Gbps")
plt.legend(loc='best')
plt.grid(color='0.85', linestyle='--', linewidth=0.5, alpha=0.5)
plt.xlabel('Packet index')
plt.ylabel('Troughput [bps]')
plt.savefig('throughput.pdf', bbox_inches='tight')
plt.show()

#3) Raspodjele

#Timestamps
fig, axs = plt.subplots(nrows=4, ncols=1, figsize=(5, 7))
axs[0].hist(df1['rcv_timestamp'], bins=50, density=True, alpha=0.7, color='blue')
axs[0].set_xlabel('Number/Index of packet')
axs[0].set_ylabel('Delay [s]')
axs[0].set_title('Plot 1')
axs[1].hist(df2['rcv_timestamp'], bins=50, density=True, alpha=0.7, color='blue')
axs[1].set_xlabel('Number/Index of packet')
axs[1].set_ylabel('Delay [s]')
axs[1].set_title('Plot 2')
axs[2].hist(df3['rcv_timestamp'], bins=50, density=True, alpha=0.7, color='blue')
axs[2].set_xlabel('Number/Index of packet')
axs[2].set_ylabel('Delay [s]')
axs[2].set_title('Plot 3')
axs[3].hist(df4['rcv_timestamp'], bins=50, density=True, alpha=0.7, color='blue')
axs[3].set_xlabel('Number/Index of packet')
axs[3].set_ylabel('Delay [s]')
axs[3].set_title('Plot 4')
fig.subplots_adjust(hspace=1.0) 
plt.show()

#Delays
fig, axs = plt.subplots(nrows=4, ncols=1, figsize=(5, 7))
axs[0].hist(df1['rcv_delta_times'], bins=50, density=True, alpha=0.7, color='blue')
axs[0].set_xlabel('Number/Index of packet')
axs[0].set_ylabel('Delay [s]')
axs[0].set_title('Plot 1')
axs[1].hist(df2['rcv_delta_times'], bins=50, density=True, alpha=0.7, color='blue')
axs[1].set_xlabel('Number/Index of packet')
axs[1].set_ylabel('Delay [s]')
axs[1].set_title('Plot 2')
axs[2].hist(df3['rcv_delta_times'], bins=50, density=True, alpha=0.7, color='blue')
axs[2].set_xlabel('Number/Index of packet')
axs[2].set_ylabel('Delay [s]')
axs[2].set_title('Plot 3')
axs[3].hist(df4['rcv_delta_times'], bins=50, density=True, alpha=0.7, color='blue')
axs[3].set_xlabel('Number/Index of packet')
axs[3].set_ylabel('Delay [s]')
axs[3].set_title('Plot 4')
fig.subplots_adjust(hspace=1.0) 
plt.savefig('histograms.pdf', bbox_inches='tight')
plt.show()