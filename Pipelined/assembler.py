#need to get the file name, either by command line or as a request
import sys, getopt
inputFile = ''

if(len(sys.argv) == 2):
	inputFile = sys.argv[1]
else:
	inputFile = raw_input('Please enter the assembly file name: ')

#first we open the asm file and we remove all the comments which starts withs '#'
removeComments = ""
removeTag = ""
tagDict = {}
with open(inputFile, "r+") as f:
	for line in f:
		line = line.partition('#')[0]
		line = "".join([s for s in line.strip().splitlines(True) if s.strip()])
		if (line.strip() and line != ''):
			removeComments = removeComments + line + '\n'
#for each line in the file we check in there is a tag before the instructions and we store them in a dictionarry with their line number multiplied by 4
for lineNum,line in enumerate(removeComments.splitlines(),0):
	temp = line.split(':', 1)
	if (len(temp) == 2):
		tag = temp[0]
		tagDict[tag] = (lineNum * 4)
		line = temp[1]
		line = line.strip()
#finaly we remove the tags and we do a final "cleanup" to only have the instructions left in the file
	removeTag = removeTag + line + '\n'

# We make a big dictionary containing all the instructions with their formats, opcodes and function if R type
NCODE ={ 'addi': {'format': 'I', 'op':'001000'}, 'slti': {'format': 'I', 'op': '001010'}, 'bne': {'format': 'I', 'op': '000101'}, 'mult': {'format': 'R', 'op':'000000'
,'funct':'011000'}, 'mflo': {'format': 'R', 'op': '000000','funct':'010010'}, 'j': {'format': 'J', 'op': '000010'}, 'jr': {'format': 'R', 'op': '000000','funct'
:'001000'},'mfhi': {'format': 'R', 'op': '000000','funct':'010000'}, 'add': {'format': 'R', 'op': '000000','funct':'100000'},'sub': {'format': 'R', 'op': '000000',
'funct':'100010'},'and': {'format': 'R', 'op': '000000','funct':'100100'}, 'sw': {'format': 'I', 'op': '101011'},'beq': {'format': 'I', 'op': '000100'},
'div': {'format': 'R', 'op':'000000','funct':'011010'}, 'slt': {'format': 'R', 'op':'000000','funct':'101010'}, 'or': {'format': 'R', 'op':'000000','funct':'100101'}
,'nor': {'format': 'R', 'op':'000000','funct':'100111'},'xor': {'format': 'R', 'op':'000000','funct':'101000'},  'lw': {'format': 'I', 'op': '100011'},
 'lb': {'format': 'I', 'op': '100000'},'sb': {'format': 'I', 'op': '101000'},'lui': {'format': 'I', 'op': '001111'},'jal': {'format': 'J', 'op': '000011'},
'andi': {'format': 'I', 'op': '001100'}, 'ori': {'format': 'I', 'op': '001101'},'xori': {'format': 'I', 'op': '001110'},'sra': {'format': 'R', 'op': '000000',
'funct':'000011'}, 'srl': {'format': 'R', 'op': '000000','funct':'000010'}, 'sll': {'format': 'R', 'op': '000000','funct':'000000'}}

#Here we make a dictionary for each type of instruction to define what the structure of each will contain
R={'op': 0, 'rs': 0, 'rt': 0,'rd': 0,'shamt': 0, 'funct': 0}
I={'op': 0, 'rs': 0, 'rt': 0, 'immediate': 0}
J={'op': 0, 'address': 0}

#function to check if int
def isInt(value):
  try:
    int(value)
    return True
  except ValueError:
    return False

#function that will extract what is contained inside brackets. This is used for the offset in the load and store instructions
def extract(string, start='(', stop=')'):
	return string[string.index(start)+1:string.index(stop)]
m = open("Init.dat", "w")

for lineNum,line in enumerate(removeTag.splitlines()):
# for each line the file we remove the brackets and replace them with a space and we then split the line and place each element in an array position
	line = line.replace(',',' ')
	words = line.split()
#	print words
	W0=words[0]
#for each line we will verify what is the instruction type
	instructionType=NCODE[words[0]]['format']
#we now enter this statement if the insruction type is I
	if (instructionType == 'I'):
#we get the opcode from the dictionary for that particular instruction
		I['op']= NCODE[W0]['op']
#we now loop through to fill in the values of our registers 
		for i in range (0,32):
			dollarsign= '$'
#if the first word after the instruction is a load or store then it will go here and first remove the brackets to get the offset and the value of the rs register			
			if (words[0] == 'lw' or words[0]== 'sw' or words[0] == 'lb' or words[0]== 'sb'):
				offset = words[2].split('(')
				inside = offset[1].split(')')
				of = offset[0]+inside[0]
				if (words [1]== dollarsign + `i`):
					I['rt']='{0:05b}'.format(i)
				if (inside [0]== dollarsign + `i`):
					I['rs']='{0:05b}'.format(i)
				
				if( isInt(offset[0]) ):
					j = int(offset[0])
					if (offset[0]== `j`):
						if (len(words) >= 4 and words [3]== `j`):
							if( j < 0) :
								j = 65536+j
						I['immediate']='{0:016b}'.format(j)
#if the instruction is lui then we automatically set the value of rs to be zeros  and then we loop to verify what is the value of rt and Immediate
			elif (words[0] == 'lui'):
				I['rs']='{0:05b}'.format(0)
				if (words [1]== dollarsign + `i`):
					I['rt']='{0:05b}'.format(i)

				if( isInt(offset[0]) ):
					j = int(offset[0])
					if (len(words) >= 3 and words [2]== `j`):
						if (len(words) >= 4 and words [3]== `j`):
							if( j < 0) :
								j = 65536+j
						I['immediate']='{0:016b}'.format(j)
#now if the instruction is a branch, we need to check the tag that we previously set in the dictionary and we set the value of immediate and then loop to get register values
			elif (words[0] == 'beq' or words[0] == 'bne'):
				offset = tagDict.get(words[3])
				offset = ((offset/4) - lineNum - 1)
				if(offset < 0) :
					offset = 65536+offset
				I['immediate']= '{0:016b}'.format(offset)
				if (words [1]== dollarsign + `i`):
					I['rs']='{0:05b}'.format(i)
				if (words [2]== dollarsign + `i`):
					I['rt']='{0:05b}'.format(i)
#if the instruction type is neither of the above and follows normal I type convention then it will simply loop and add the values for rs rt and immediate
			elif (words[0] != 'lw' or words[0]!= 'sw' or words[0] != 'lb' or words[0]!= 'sb'or words[0]!= 'lui'or words[0]!= 'beq'or words[0]!= 'bne' ):
				if (words [1]== dollarsign + `i`): 
					I['rt']='{0:05b}'.format(i)
				if (words [2]== dollarsign + `i`):
					I['rs']='{0:05b}'.format(i)

				if (len(words) >= 4):
					if( isInt(words [3]) ):
						j = int(words [3])
						if( j < 0) :
							j = 65536+j
						I['immediate']='{0:016b}'.format(j)
			else: print 'error'
		Iout = str(I['op'])+ str(I['rs']) + str(I['rt']) + str(I['immediate'])
#		rint str(I['op'])+ str(I['rs']) + str(I['rt']) + str(I['immediate'])
		print Iout
#we write this to the output dat file
		m.write(Iout+ '\n')
# if the instruction is of type R we enter here
	elif (instructionType == 'R'):
#we look into the dictionary and set the opcode value, function and shamt value for that particular instruction
		R['op']=NCODE[W0]['op']
		R['funct'] = NCODE[W0]['funct']
#		R['shamt'] = '{0:05b}'.format(0)
		for i in range (0,32):
			dollarsign= '$'
# if the instruction is a mult or a dic then we set shamt and rd to zero and we loop the find what is value of register
			if ((words[0] == 'mult' or words[0]== 'div' )):
				R['rd']= '{0:05b}'.format(0)
				R['shamt'] = '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rs']='{0:05b}'.format(i)
				if  ((words [2]== dollarsign + `i`)):
					R['rt']='{0:05b}'.format(i)
# if the instruction is a move then we set the shamt, rt and rs to zero
			elif ((words[0] == 'mflo' or words[0]== 'mfhi' )):
				R['shamt'] = '{0:05b}'.format(0)
				R['rt']= '{0:05b}'.format(0)
				R['rs']= '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rd']='{0:05b}'.format(i)
#if the instruction is a jump register then we set shamt rt and rd to zero and loop to get value of source register rs
			elif ((words[0] == 'jr')):
				R['shamt'] = '{0:05b}'.format(0)
				R['rt']= '{0:05b}'.format(0)
				R['rd']= '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rs']='{0:05b}'.format(i)
#if the instruction is a shift then the we need to get to value ofthe shamt as it is not zero in this case. we then loop to get value of rd and rt
			elif ((words[0] == 'sll') or (words[0] == 'srl') or (words[0] == 'sra')):
				R['rs']= '{0:05b}'.format(0)
				if  ((words [1]== dollarsign + `i`)):
					R['rd']='{0:05b}'.format(i)
				if  ((words [2]== dollarsign + `i`)):
					R['rt']='{0:05b}'.format(i)
				if  ((words [3]== `i`)):
					R['shamt'] = '{0:05b}'.format(i)
# if the instruction is not any of the above then we set simply loop and set the values for the registers rd, rs and rt
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
#write this to the ouput dat file
		m.write(str(R['op'])+ str(R['rs']) + str(R['rt']) + str(R['rd']) + str(R['shamt'])+ str(R['funct'])+ '\n')
#if the instruction is of type J, then we enter here. We set the opcode value as found in the dictionary
	elif instructionType == 'J':
		J['op']=NCODE[W0]['op']
		# we set the jump address by looking into the dictionary of tags 
		jaddress = tagDict.get(words[1])
		J['address']= '{0:026b}'.format(jaddress/4)
		print str(J['op'])+ str(J['address'])
#write this to the output dat file
		m.write(str(J['op'])+ str(J['address'])+ '\n')
	else:
		print 'false'
