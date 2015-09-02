import sys

def dataprocess(filename):
  send = {}
  ecn = {}
  receive = {}
  rtt = {}
  rttRatio = {}
  lines = open(filename).readlines()
  sendf = open('send.txt','w')
  ecnf = open('ecn.txt','w')
  receivef = open('receive.txt', 'w')
  rttf = open('rtt.txt', 'w')
  rttRatiof = open('rttRatio.txit', 'w')
  temp = []
  minimum = 100
  for line in lines:
    data = line.split(' ')
    if (data[0] == '+') and (data[2] == '0') and (data[3] == '20'):
      send[data[10]] = data[1];
    if ('E' in data[6]) and (data[8] == '0.0') and (data[9] == '1.0') and (data[0] == '-'):
      temp.append(data[10])
    if (data[0] == 'r') and (data[3] == '0') and (data[4] == 'ack'):
      if data[10] in temp:
        ecn[data[10]] = 1
        receive[data[10]] = data[1]
      else:
        ecn[data[10]] = 0
        receive[data[10]] = data[1] 
      rtt[data[10]] = float(receive[data[10]]) - float(send[data[10]])
      if rtt[data[10]] < minimum:
        minimum = rtt[data[10]]
      rttRatio[data[10]] = float(rtt[data[10]])/minimum

  sendf.write(str(send))
  receivef.write(str(receive))
  ecnf.write(str(ecn))
  rttf.write(str(rtt))
  rttRatiof.write(str(rttRatio))
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



