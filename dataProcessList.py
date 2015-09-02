import sys

def dataprocess(filename):
  send = []
  ecn = []
  receive = []
  rtt = []
  rttRatio = []
  lines = open(filename).readlines()
  sendf = open('send.txt','w')
  ecnf = open('ecn.txt','w')
  receivef = open('receive.txt', 'w')
  rttf = open('rtt.txt', 'w')
  rttRatiof = open('rttRatio.txt', 'w')
  temp = []
  minimum = 100
  for line in lines:
    data = line.split(' ')
    if (data[0] == '+') and (data[2] == '0') and (data[3] == '20'):
      send.append(data[1] + "\n")
    if ('E' in data[6]) and (data[8] == '0.0') and (data[9] == '1.0') and (data[0] == '-'):
      temp.append(data[10])
    if (data[0] == 'r') and (data[3] == '0') and (data[4] == 'ack'):
      if data[10] in temp:
        ecn.append('1' + '\n')
        receive.append(data[1] + '\n')
      else:
        ecn.append('0 '+ '\n')
        receive.append(data[1] + '\n') 
      rtt.append(str(float(receive[int(data[10])]) - float(send[int(data[10])])) + '\n')
      if float(rtt[int(data[10])]) < minimum:
        minimum = float(rtt[int(data[10])])
      rttRatio.append(str(float(rtt[int(data[10])])/minimum) + '\n')

  sendf.writelines(send)
  receivef.writelines(receive)
  ecnf.writelines(ecn)
  rttf.writelines(rtt)
  rttRatiof.writelines(rttRatio)
  sendf.close()
  receivef.close()
  ecnf.close()
  rttf.close()
  rttRatiof.close()

filename = "outNewReno.tr"
try:
  f = open(filename)
except:
  print "File not existed"
dataprocess(filename)