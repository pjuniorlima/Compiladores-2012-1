/*
 * CheckPoint do trabalho de compiladores
 *
 * node.h: especificacao da EDados Node usada para contrucao da arvore semantica
 *
 * Aluno:Bruno dos Reis Calcado
 * Matricula: 080196
 */
#ifndef CEZINHO_NODE
#define CEZINHO_NODE

#ifndef null
#define null NULL
#endif

enum node_type {
  cLEAF,
	cINT,
	cID,
	cARRAY,
	cARRAYPOS,
	cCHAR,
	cVAR,
	cFUNCTION,
	cDECLS,
	cVARDECL,
	cFUNCDECL,
	cPARAMDECLLISTTAIL,
	cSTMTLIST,
	cVARDECLLIST,
	cRETURN,
	cREAD,
	cWRITE,
	cSTRING,
	cBREAK,
	cIF,
	cWHILE,
	cEXPR,
	cBINEXPR,
	cUNAEXPR,
	cPOSTFIXEXPR,
	cARGUMENTLIST,
	cMENOS,
	cEXCLAMACAO,
	cMAIS,
	cESTRELA,
	cBARRA,
	cIGUALA,
	cDIFERENTEDE,
	cMENOR,
	cMENORIGUAL,
	cMAIOR,
	cMAIORIGUAL,
	cELOGICO,
	cOULOGICO,
	cBLOCK
};

typedef struct _Node {
	unsigned long value;
	enum node_type type;
	
	union { struct _Node *node; } n1;
	union { struct _Node *node; } n2;
	union { struct _Node *node; } n3;
} Node;

Node* create_node(enum node_type, Node*, Node*, Node*);
void type_to_string(char*, enum node_type);

#define n1(n) ((n)->n1.node)
#define n2(n) ((n)->n2.node)
#define n3(n) ((n)->n3.node)

#define new_node(t, a, b, c) create_node((t), (Node*)(a), (Node*)(b), (Node*)(c))

#define new_var_node(a, b) new_node(cVAR, a, b, null)
#define new_decls_node(a, b, c) create_node(cDECLS, a, b, c)
#define new_function_node(a, b) new_node(cFUNCTION, a, b, null)
#define new_vardecl_node(a, b) new_node(cVARDECL, a, b, null)
#define new_funcdecl(a, b) new_node(cFUNCDECL, a, b, null)
#define new_paramdecllisttail_node(a, b) new_node(cPARAMDECLLISTTAIL, a, b, null)
#define new_block_node(a, b) new_node(cBLOCK, a, b, null)
#define new_vardecllist_node(a, b, c) new_node(cVARDECLLIST, a, b, c)
#define new_stmtlist_node(a, b) new_node(cSTMTLIST, a, b, null)
#define new_return_node(a) new_node(cRETURN, a, null, null)
#define new_read_node(a) new_node(cREAD, a, null, null)
#define new_write_node(a) new_node(cWRITE, a, null, null)
#define new_string_node() new_leaf_type(cSTRING)
#define new_break_node() new_leaf_type(cBREAK)
#define new_if_node(a, b, c) new_node(cIF, a, b, c)
#define new_while_node(a, b) new_node(cWHILE, a, b, null)
#define new_expr_node(a, b) new_node(cEXPR, a, b, null)
#define new_binaryexpr_node(a, b, c) new_node(cBINEXPR, a, b, c)
#define new_unaryexpr_node(a, b) new_node(cUNAEXPR, a, b, null)
#define new_postfixexpr_node(a, b) new_node(cPOSTFIXEXPR, a, b, null)
#define new_argumentlist_node(a, b) new_node(cARGUMENTLIST, a, b, null)

#define new_leaf() new_node(cLEAF, null, null, null)
#define new_leaf_type(t) new_node(t, null, null, null)

#endif
