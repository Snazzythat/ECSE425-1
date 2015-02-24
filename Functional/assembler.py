removeComments = ""
removeTag = ""
tagDict = {}
with open("bitwise.asm", "r+") as f:
  for line in f:
    line = line.partition('#')[0]
    line = "".join([s for s in line.strip().splitlines(True) if s.strip()])
    if (line.strip() and line != ''):
      removeComments = removeComments + line + '\n'

for lineNum,line in enumerate(removeComments.splitlines(),0):
  temp = line.split(':', 1)
  if (len(temp) == 2):
    tag = temp[0]
    tagDict[tag] = (lineNum * 4)
    line = temp[1]
    line = line.strip()
  removeTag = removeTag + line + '\n'

f = open("bitwise.dat", "w")
f.write(removeTag)
#print tagDict

NCODE ={ 'addi': {'format': 'I', 'op':'001000'}, 'slti': {'format': 'I', 'op': '001010'}, 'bne': {'format': 'I', 'op': '000101'}, 'mult': {'format': 'R', 'op':'000000'
,'funct':'011000'}, 'mflo': {'format': 'R', 'op': '000000','funct':'010010'}, 'j': {'format': 'J', 'op': '000010'}, 'jr': {'format': 'R', 'op': '000000','funct'
:'001000'},'mfhi': {'format': 'R', 'op': '000000','funct':'010000'}, 'add': {'format': 'R', 'op': '000000','funct':'100000'},'sub': {'format': 'R', 'op': '000000',
'funct':'100010'},'and': {'format': 'R', 'op': '000000','funct':'100100'}, 'sw': {'format': 'I', 'op': '101011'},'beq': {'format': 'I', 'op': '000100'},
'div': {'format': 'R', 'op':'000000','funct':'011010'}, 'slt': {'format': 'R', 'op':'000000','funct':'101010'}, 'or': {'format': 'R', 'op':'000000','funct':'100101'}
,'nor': {'format': 'R', 'op':'000000','funct':'100111'},'xor': {'format': 'R', 'op':'000000','funct':'101000'},  'lw': {'format': 'I', 'op': '100011'},
 'lb': {'format': 'I', 'op': '100000'},'sb': {'format': 'I', 'op': '101000'},'lui': {'format': 'I', 'op': '001111'},'jal': {'format': 'J', 'op': '000011'},
'andi': {'format': 'I', 'op': '001100'}, 'ori': {'format': 'I', 'op': '001101'},'xori': {'format': 'I', 'op': '001110'},'sra': {'format': 'R', 'op': '000000',
'funct':'000011'}, 'srl': {'format': 'R', 'op': '000000','funct':'000010'}, 'sll': {'format': 'R', 'op': '000000','funct':'000000'}}
#print NCODE['addi']['format']
R={'op': 0, 'rs': 0, 'rt': 0,'rd': 0,'shamt': 0, 'funct': 0}
I={'op': 0, 'rs': 0, 'rt': 0, 'immediate': 0}
J={'op': 0, 'address': 0}

def extract(string, start='(', stop=')'):
        return string[string.index(start)+1:string.index(stop)]
m = open("bin.dat", "w")


with open('bitwise.dat', 'r') as f:
    data = f.readlines()
    for line in data:
        line = line.replace(',','')
	words = line.split()
#	print words
	W0=words[0]
	instructionType=NCODE[words[0]]['format']
	if (instructionType == 'I'):
		I['op']= NCODE[W0]['op']
		for i in range (0,31):
			dollarsign= '$'
			if (words[0] == 'lw' or words[0]== 'sw' or words[0] == 'lb' or words[0]== 'sb'):
				offset = words[2].split('(')
				inside = offset[1].split(')')
				of = offset[0]+inside[0]
				if (words [1]== dollarsign + `i`):
                                	I['rt']='{0:05b}'.format(i)
				if (inside [0]== dollarsign + `i`):
                                        I['rs']='{0:05b}'.format(i)
				for j in range (0, 32767):
                                        if (offset[0]== `j`):
                                                 I['immediate']='{0:016b}'.format(j)
			elif (words[0] == 'lui'):
				I['rs']='{0:05b}'.format(0)
                                if (words [1]== dollarsign + `i`):
                                        I['rt']='{0:05b}'.format(i)
                                for j in range (0, 32767):
                                        if (len(words) >= 3 and words [2]== `j`):
                                                 I['immediate']='{0:016b}'.format(j)
			elif (words[0] == 'beq' or words[0] == 'bne'):
				offset = tagDict.get(words[3])
                                I['immediate']= '{0:016b}'.format(offset)
				if (words [1]== dollarsign + `i`):
                                	I['rs']='{0:05b}'.format(i)
                                if (words [2]== dollarsign + `i`):
                                        I['rt']='{0:05b}'.format(i)
			elif (words[0] != 'lw' or words[0]!= 'sw' or words[0] != 'lb' or words[0]!= 'sb'or words[0]!= 'lui'or words[0]!= 'beq'or words[0]!= 'bne' ):
				if (words [1]== dollarsign + `i`): 
					I['rt']='{0:05b}'.format(i)
				if (words [2]== dollarsign + `i`):
					I['rs']='{0:05b}'.format(i)
				for j in range (0, 32767):				
					if (len(words) >= 4 and words [3]== `j`):
                               			 I['immediate']='{0:016b}'.format(j)
			else: print 'error'
		Iout = str(I['op'])+ str(I['rs']) + str(I['rt']) + str(I['immediate'])
#		rint str(I['op'])+ str(I['rs']) + str(I['rt']) + str(I['immediate'])
		print Iout
		m.write(Iout+ '\n')
	elif (instructionType == 'R' and ((W0 != 'sll') or (W0 != 'srl') or (W0 != 'sra'))): 
                R['op']=NCODE[W0]['op']
		R['funct'] = NCODE[W0]['funct']
#		R['shamt'] = '{0:05b}'.format(0)
                for i in range (0,31):
                        dollarsign= '$'
		        if ((words[0] == 'mult' or words[0]== 'div' )):
				R['rd']= '{0:05b}'.format(0)
				R['shamt'] = '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rs']='{0:05b}'.format(i)
				if  ((words [2]== dollarsign + `i`)):
					R['rt']='{0:05b}'.format(i)
			elif ((words[0] == 'mflo' or words[0]== 'mfhi' )):
				R['shamt'] = '{0:05b}'.format(0)
				R['rt']= '{0:05b}'.format(0)
				R['rd']= '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rd']='{0:05b}'.format(i)
			elif ((words[0] == 'jr')):
				R['shamt'] = '{0:05b}'.format(0)
                                R['rt']= '{0:05b}'.format(0)
                                R['rd']= '{0:05b}'.format(0)
                                if  ((words [1]== dollarsign + `i`)):
                                        R['rs']='{0:05b}'.format(i)
			elif ((words[0] == 'sll') or (words[0] == 'srl') or (words[0] == 'sra')):
                                R['rs']= '{0:05b}'.format(0)
                                if  ((words [1]== dollarsign + `i`)):
                                        R['rd']='{0:05b}'.format(i)
				if  ((words [2]== dollarsign + `i`)):
                                        R['rt']='{0:05b}'.format(i)
				if  ((words [3]== `i`)):
                                        R['shamt'] = '{0:05b}'.format(i)
                        elif ((words[0] != 'mult' or words[0]!= 'div' or words[0]!= 'mflo' or words[0]!= 'mfhi' or words[0]!= 'jr'or words[0] != 'sll' or 
				words[0] != 'srl' or words[0] != 'sra')):
				R['shamt'] = '{0:05b}'.format(0)
				if ((words [1] == dollarsign + `i`)):
                                	R['rd']='{0:05b}'.format(i)
				if ((len(words) >= 3) and (words [2]== dollarsign + `i`)):
					R['rs']='{0:05b}'.format(i)
				if ((len(words) >= 4) and (words [3]== dollarsign + `i`)):
					R['rt']='{0:05b}'.format(i)
			else: print 'error' 
		print str(R['op'])+ str(R['rs']) + str(R['rt']) + str(R['rd']) + str(R['shamt'])+ str(R['funct'])
		m.write(str(R['op'])+ str(R['rs']) + str(R['rt']) + str(R['rd']) + str(R['shamt'])+ str(R['funct'])+ '\n')
	elif instructionType == 'J':
                J['op']=NCODE[W0]['op']
		jaddress = tagDict.get(words[1])
                J['address']= '{0:026b}'.format(jaddress)
		print str(J['op'])+ str(J['address'])
		m.write(str(J['op'])+ str(J['address'])+ '\n')
        else:
	        print 'false'

#binaryInst = open("mcode1.dat", "w")
#binaryInst.write(t)
#{'True': 156, 'End': 160, 'Continue': 88, 'False': 84, 'Bitwise': 8}
#J={'op': 0, 'address': 0}

	
		#for y in range (0,31):
                #	dollarsign2= '$'
               	# 	if words [2]== dollarsign2 + `y`:
                #        	I['rd']=y

#print '%s%s%s' %(instructionType,I['rs'],I['rd'])



#
#		print I;
#       while line:
#       line = data.readline()
#       Print "First Words" line
#f = open("data.txt")
#next = f.read(1)
#while next != "":
#    print(next)
#    next = f.read(1)
