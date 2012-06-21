int data_offset = 0;

int data_location(){
	return data_offset++;
}

int code_offset = 0;

int gen_label(){
	return code_offset;
}

int reserve_loc(){
	return code_offset++;
}

void gen_code(enum code_ops operation, int arg){
	code[code_offset].op = operation;
	code[code_offset].arg = arg;
}

void back_patch( int addr, enum code_ops operation, int arg){
	code[addr].op = operation;
	code[addr].arg = arg;
}

void print_code(){
	int i = 0;
	while(i < code_offset){
		printf("%3ld: %-10s%4ld\n",i,op_name[(int) code[i].op], code[i].arg);
		i++;
	}
}
