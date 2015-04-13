#ifndef __ASSEMBLER_HPP
#define __ASSEMBLER_HPP

struct instruction {
	char format;
	std::string op;
	std::string funct;

	instruction() {
		format = 0;
		op = "";
		funct = "";
	}
	instruction(char a, std::string b, std::string c) {
		format = a;
		op = b;
		funct = c;
	}
};
struct rType {
	std::string op;
	std::string rs;
	std::string rt;
	std::string rd;
	std::string shamt;
	std::string funct;

	rType(){
		op = "";
		rs = "";
		rt = "";
		rd = "";
		shamt = "";
		funct = "";
	};
};
struct iType {
	std::string op;
	std::string rs;
	std::string rt;
	std::string immed;

	iType(){
		op = "";
		rs = "";
		rt = "";
		immed = "";
	};
};
struct jType {
	std::string op;
	std::string address;

	jType(){
		op = "";
		address = "";
	};
};

struct schedulingNode {
	int order;
	int original;
	int independent;
	int depend[34];
	std::vector<int> dependency;

	schedulingNode(){
		order = 0;
		original = 0;
		independent = 0;
		for(int i = 0; i < 34; i++) {
			depend[i] = 0;
		}
		dependency = std::vector<int>();
	}

	schedulingNode(int o){
		order = o;
		original = o;
		independent = 0;
		for(int i = 0; i < 34; i++) {
			depend[i] = 0;
		}
		dependency = std::vector<int>();
	}
};

std::unordered_map<std::string,instruction> insMap;
std::vector<std::string> inVector;
std::unordered_map<std::string, int> inTags;
std::vector<schedulingNode> schedule;

#endif
