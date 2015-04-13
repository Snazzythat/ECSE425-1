#include <algorithm>
#include <bitset>
#include <cctype>
#include <fstream>
#include <functional>
#include <iostream>
#include <iterator>
#include <locale>
#include <stdio.h>
#include <string>
#include <sstream>
#include <unordered_map>
#include <vector>

#include "assembler.hpp"

// trim from start
static inline std::string &ltrim(std::string &s) {
	s.erase(s.begin(), std::find_if(s.begin(), s.end(), std::not1(std::ptr_fun<int, int>(std::isspace))));
	return s;
}

// trim from end
static inline std::string &rtrim(std::string &s) {
	s.erase(std::find_if(s.rbegin(), s.rend(), std::not1(std::ptr_fun<int, int>(std::isspace))).base(), s.end());
	return s;
}

// trim from both ends
static inline std::string &trim(std::string &s) {
	return ltrim(rtrim(s));
}

inline bool fileExists (const std::string& name) {
	if (FILE *file = fopen(name.c_str(), "r")) {
		fclose(file);
		return true;
	} else {
		return false;
	}
}

void initMaps() {
	insMap["addi"] = instruction('I', "001000", "");
	insMap["slti"] = instruction('I', "001010", "");
	insMap["bne"]  = instruction('I', "000101", "");
	insMap["beq"]  = instruction('I', "000100", "");
	insMap["sw"]   = instruction('I', "101011", "");
	insMap["lw"]   = instruction('I', "100011", "");
	insMap["lb"]   = instruction('I', "100000", "");
	insMap["sb"]   = instruction('I', "101000", "");
	insMap["lui"]  = instruction('I', "001111", "");
	insMap["andi"] = instruction('I', "001100", "");
	insMap["ori"]  = instruction('I', "001101", "");
	insMap["xori"] = instruction('I', "001110", "");
	insMap["j"]    = instruction('J', "000010", "");
	insMap["jal"]  = instruction('J', "000011", "");
	insMap["mult"] = instruction('R', "000000", "011000");
	insMap["mflo"] = instruction('R', "000000", "010010");
	insMap["jr"]   = instruction('R', "000000", "001000");
	insMap["mfhi"] = instruction('R', "000000", "010000");
	insMap["add"]  = instruction('R', "000000", "100000");//
	insMap["sub"]  = instruction('R', "000000", "100010");//
	insMap["and"]  = instruction('R', "000000", "100100");//
	insMap["div"]  = instruction('R', "000000", "011010");
	insMap["slt"]  = instruction('R', "000000", "101010");//
	insMap["or"]   = instruction('R', "000000", "100101");//
	insMap["nor"]  = instruction('R', "000000", "100111");//
	insMap["xor"]  = instruction('R', "000000", "101000");//
	insMap["sra"]  = instruction('R', "000000", "000011");
	insMap["srl"]  = instruction('R', "000000", "000010");
	insMap["sll"]  = instruction('R', "000000", "000000");
}

bool is_number(const std::string& s) {
	std::string::const_iterator it = s.begin();
	while (it != s.end() && std::isdigit(*it)) ++it;
	return !s.empty() && it == s.end();
}

void commentsAndTags() {
	std::string tempStr;
	std::vector<std::string>::iterator it = inVector.begin();

	//remove comments
	while(it != inVector.end()) {
		//remove stuff after #
		tempStr = (*it).substr(0, (*it).find('#') );

		//trim whitespace
		tempStr = trim(tempStr);

		//remove empty lines
		if(!tempStr.empty()) {
			(*it) = tempStr;
			it++;
		}
		else {
			inVector.erase(it);
			it = inVector.begin();
		}
	}

	//find and remove tags
	std::size_t colon;
	it = inVector.begin();
	int i = 0;
	while(it != inVector.end()) {
		tempStr = (*it);

		//if string contains tag
		colon = tempStr.find_first_of(':');

		//if found colon, there's a tag here
		if(colon != std::string::npos) {
			inTags[ tempStr.substr(0, colon) ] = i * 4;
			tempStr = tempStr.substr(colon + 1);
			//trim whitespace
			tempStr = trim(tempStr);
			(*it) = tempStr;
		}

		it++;
		i++;
	}
}

void checkDependency() {
	unsigned int i = 0;
	schedule[i].independent = 1;

	for(i = 1; i < schedule.size(); i++ ) {
		//mark as independent
		schedule[i].independent = 1;
		//search previous functions
		for(unsigned int j = 0; j < i; j++) {
			//if dependency in between found, break
			for(int k = 0; k < 34; k++) {
				if(schedule[i].depend[k] == 1 && schedule[j].depend[k] == 1) {
					schedule[i].independent = 0;
					schedule[i].dependency.push_back(j);
					break;
				}
			}
		}
	}
}

void reorderInstructions() {
	for(unsigned int i = 1; i < schedule.size(); i++) {
		//if not already scheduled
		if(schedule[i].order >= i) {
			//if dependent on previous instruction
			if(schedule[i].independent == 0 && std::find(schedule[i].dependency.begin(), schedule[i].dependency.end(), (i-1)) != schedule[i].dependency.end()) {

				//search for replacements
				if( (schedule[i].order - schedule[i-1].order ) == 1) {
					//go through next instructions
					for(unsigned int j = i+1; j < schedule.size(); j++) {
						if(schedule[j].order >= j) {
							//if independent or not dependent on the i or i-1 functions, reorder it before i
							if(schedule[j].independent == 1 ||
									(std::find(schedule[j].dependency.begin(), schedule[j].dependency.end(), (i-1)) != schedule[j].dependency.end()
											&& std::find(schedule[j].dependency.begin(), schedule[j].dependency.end(), i) != schedule[j].dependency.end() ) ) {
								schedule[j].order = schedule[i].order;
								for(unsigned int k = i; k < j; k++) {
									if(schedule[k].order >= k)
										schedule[k].order += 1;
								}
								break;
							}
						}
					}
				}
			}
		}
	}
}

bool compareInstrOrder(const schedulingNode &a, const schedulingNode &b) {
	return a.order < b.order;
}

int main ( int argc, char *argv[] ) {
	std::string inFile;

	if(argc == 1) {
		std::cout << "Please enter file name: ";
		std::cin >> inFile;
	}
	else if(argc == 2) {
		inFile = argv[1];
	}
	else {
		std::cout << "Program called with more than 1 argument. Either use 'assembler test.asm' or use 'assembler' and then enter the file name.\n";
		return 0;
	}

	if(fileExists(inFile) == false) {
		std::cout << "File '" << inFile << "' not found!\n";
		return 0;
	}

	//else file exists
	std::cout << "Assembling file '" << inFile << "'...\n";
	initMaps();

	//get all lines
	std::string line;
	std::ifstream inStream(inFile.c_str());
	while (std::getline(inStream, line))
		inVector.push_back( std::string(line) );

	//remove comments
	commentsAndTags();

	//open output file
	FILE * outFile;
	outFile = fopen("Init.dat", "w");

	//parse each line
	int i = 0;
	for (std::vector<std::string>::iterator it = inVector.begin(); it!=inVector.end(); ++it, i++) {
		line = (*it);

		//replace commas with spaces
		std::replace( line.begin(), line.end(), ',', ' ');

		//split line into words
		std::istringstream buf(line);
		std::istream_iterator<std::string> beg(buf), end;
		std::vector<std::string> words(beg, end);

		//if type 'I'
		std::size_t par, dol, par2;
		std::string offset0, offset1, offset2;
		if( insMap[ words[0] ].format == 'I') {
			iType instr;

			instr.op = insMap[ words[0] ].op;


			//if load or store
			if( words[0].compare("lw") == 0 || words[0].compare("sw") == 0 || words[0].compare("lb") == 0 || words[0].compare("sb") == 0 ) {
				par = words[2].find('(');
				dol = words[2].find('$');
				par2 = words[2].find(')');

				offset1 = words[2].substr(0, par);
				offset2 = words[2].substr(dol + 1, par2-dol-1);

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( atoi(offset1.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[ atoi(offset2.c_str()) ] = 1;
				node.depend[ atoi(offset0.c_str()) ] = 1;
				schedule.push_back(node);
			}
			else if( words[0].compare("beq") == 0 || words[0].compare("bne") == 0 ) {
				int of = inTags[ words[3] ];
				of = of/4 - i - 1;

				if(of < 0)
					of += 65536;

				dol = words[2].find('$');
				offset0 = words[2].substr(dol+1);

				dol = words[1].find('$');
				offset1 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( of ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[ atoi(offset0.c_str()) ] = 1;
				node.depend[ atoi(offset1.c_str()) ] = 1;
				schedule.push_back(node);
			}
			else if( words[0].compare("lui") == 0 ) {
				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( 0 ).to_string();
				instr.immed = std::bitset< 16 >( atoi(words[2].c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[ atoi(offset0.c_str()) ] = 1;
				schedule.push_back(node);
			}
			else {
				dol = words[2].find('$');
				offset0 = words[2].substr(dol+1);

				dol = words[1].find('$');
				offset1 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( atoi(words[3].c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[ atoi(offset0.c_str()) ] = 1;
				node.depend[ atoi(offset1.c_str()) ] = 1;
				schedule.push_back(node);
			}

			fprintf(outFile, "%s%s%s%s\n", instr.op.c_str(), instr.rs.c_str(), instr.rt.c_str(), instr.immed.c_str());

		}
		//type R
		else if( insMap[ words[0] ].format == 'R') {
			rType instr;

			instr.op = insMap[ words[0] ].op;
			instr.funct = insMap[ words[0] ].funct;

			if( words[0].compare("mult") == 0 || words[0].compare("div") == 0 ) {
				instr.rd = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[32] = 1;
				node.depend[atoi(offset0.c_str())] = 1;
				node.depend[atoi(offset1.c_str())] = 1;
				if( words[0].compare("div") == 0) {
					node.depend[33] = 1;
				}
				schedule.push_back(node);
			}
			else if( words[0].compare("mflo") == 0 || words[0].compare("mfhi") == 0 ) {
				instr.rt = std::bitset< 5 >( 0 ).to_string();
				instr.rs = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[atoi(offset0.c_str())] = 1;
				if( words[0].compare("mfhi") == 0) {
					node.depend[33] = 1;
				}
				else {
					node.depend[32] = 1;
				}
				schedule.push_back(node);
			}
			else if( words[0].compare("jr") == 0 ) {
				instr.rt = std::bitset< 5 >( 0 ).to_string();
				instr.rd = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[atoi(offset0.c_str())] = 1;
				schedule.push_back(node);
			}
			else if( words[0].compare("sll") == 0 || words[0].compare("srl") == 0 || words[0].compare("sra") == 0 ) {
				instr.rs = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				dol = words[3].find('$');
				offset2 = words[3].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.shamt = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[atoi(offset1.c_str())] = 1;
				node.depend[atoi(offset0.c_str())] = 1;
				schedule.push_back(node);
			}
			else {
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				dol = words[3].find('$');
				offset2 = words[3].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();

				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[atoi(offset1.c_str())] = 1;
				node.depend[atoi(offset2.c_str())] = 1;
				node.depend[atoi(offset0.c_str())] = 1;
				schedule.push_back(node);
			}

			fprintf(outFile, "%s%s%s%s%s%s\n", instr.op.c_str(), instr.rs.c_str(), instr.rt.c_str(),  instr.rd.c_str(), instr.shamt.c_str(), instr.funct.c_str());
		}
		else if( insMap[ words[0] ].format == 'J') {
			jType instr;
			instr.op = insMap[ words[0] ].op;
			instr.address = std::bitset< 26 >( inTags[ words[1] ] / 4 ).to_string();

			if( words[0].compare("jal") == 0) {
				//create the scheduling node
				schedulingNode node = schedulingNode(i);
				node.depend[31] = 1;
				schedule.push_back(node);
			}

			fprintf(outFile, "%s%s\n", instr.op.c_str(), instr.address.c_str());
		}
	}

	fclose(outFile);
	std::cout << "Assembling unscheduled done!\n";

	checkDependency();
	reorderInstructions();
	std::sort(schedule.begin(), schedule.end(), compareInstrOrder);

	outFile = fopen("Init.opt", "w");

	for (i = 0; i < schedule.size(); i++) {
		line = inVector[ schedule[i].original ];

		//replace commas with spaces
		std::replace( line.begin(), line.end(), ',', ' ');

		//split line into words
		std::istringstream buf(line);
		std::istream_iterator<std::string> beg(buf), end;
		std::vector<std::string> words(beg, end);

		//if type 'I'
		std::size_t par, dol, par2;
		std::string offset0, offset1, offset2;
		if( insMap[ words[0] ].format == 'I') {
			iType instr;

			instr.op = insMap[ words[0] ].op;


			//if load or store
			if( words[0].compare("lw") == 0 || words[0].compare("sw") == 0 || words[0].compare("lb") == 0 || words[0].compare("sb") == 0 ) {
				par = words[2].find('(');
				dol = words[2].find('$');
				par2 = words[2].find(')');

				offset1 = words[2].substr(0, par);
				offset2 = words[2].substr(dol + 1, par2-dol-1);

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( atoi(offset1.c_str()) ).to_string();
			}
			else if( words[0].compare("beq") == 0 || words[0].compare("bne") == 0 ) {
				int of = inTags[ words[3] ];
				of = of/4 - i - 1;

				if(of < 0)
					of += 65536;

				dol = words[2].find('$');
				offset0 = words[2].substr(dol+1);

				dol = words[1].find('$');
				offset1 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( of ).to_string();
			}
			else if( words[0].compare("lui") == 0 ) {
				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( 0 ).to_string();
				instr.immed = std::bitset< 16 >( atoi(words[2].c_str()) ).to_string();
			}
			else {
				dol = words[2].find('$');
				offset0 = words[2].substr(dol+1);

				dol = words[1].find('$');
				offset1 = words[1].substr(dol+1);

				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.immed = std::bitset< 16 >( atoi(words[3].c_str()) ).to_string();
			}

			fprintf(outFile, "%s%s%s%s\n", instr.op.c_str(), instr.rs.c_str(), instr.rt.c_str(), instr.immed.c_str());

		}
		//type R
		else if( insMap[ words[0] ].format == 'R') {
			rType instr;

			instr.op = insMap[ words[0] ].op;
			instr.funct = insMap[ words[0] ].funct;

			if( words[0].compare("mult") == 0 || words[0].compare("div") == 0 ) {
				instr.rd = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
			}
			else if( words[0].compare("mflo") == 0 || words[0].compare("mfhi") == 0 ) {
				instr.rt = std::bitset< 5 >( 0 ).to_string();
				instr.rs = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
			}
			else if( words[0].compare("jr") == 0 ) {
				instr.rt = std::bitset< 5 >( 0 ).to_string();
				instr.rd = std::bitset< 5 >( 0 ).to_string();
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				instr.rs = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
			}
			else if( words[0].compare("sll") == 0 || words[0].compare("srl") == 0 || words[0].compare("sra") == 0 ) {
				instr.rs = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				dol = words[3].find('$');
				offset2 = words[3].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.shamt = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();
			}
			else {
				instr.shamt = std::bitset< 5 >( 0 ).to_string();

				dol = words[1].find('$');
				offset0 = words[1].substr(dol+1);

				dol = words[2].find('$');
				offset1 = words[2].substr(dol+1);

				dol = words[3].find('$');
				offset2 = words[3].substr(dol+1);

				instr.rd = std::bitset< 5 >( atoi(offset0.c_str()) ).to_string();
				instr.rs = std::bitset< 5 >( atoi(offset1.c_str()) ).to_string();
				instr.rt = std::bitset< 5 >( atoi(offset2.c_str()) ).to_string();
			}

			fprintf(outFile, "%s%s%s%s%s%s\n", instr.op.c_str(), instr.rs.c_str(), instr.rt.c_str(),  instr.rd.c_str(), instr.shamt.c_str(), instr.funct.c_str());
		}
		else if( insMap[ words[0] ].format == 'J') {
			jType instr;
			instr.op = insMap[ words[0] ].op;
			instr.address = std::bitset< 26 >( inTags[ words[1] ] / 4 ).to_string();

			fprintf(outFile, "%s%s\n", instr.op.c_str(), instr.address.c_str());
		}
	}

	fclose(outFile);
	std::cout << "Assembling scheduled done!\n";

	return 1;
}
