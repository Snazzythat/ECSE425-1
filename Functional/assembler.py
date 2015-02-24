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
