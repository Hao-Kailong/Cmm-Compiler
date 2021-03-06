%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"lex.yy.c"
int hasError=0;
%}

%{
struct Node{
	union{
		int valInt;
		float valFloat;
		double valDouble;
	};
	int line;
	char type[64];
	char name[64];
	struct Node *child;
	struct Node *next;
};
%}

%union{
struct Node* NodeStar;
};

%locations

%token <NodeStar> INT FLOAT PLUS MINUS STAR DIV AND OR NOT
%token <NodeStar> LP RP LB RB LC RC
%token <NodeStar> STRUCT RETURN IF ELSE WHILE
%token <NodeStar> ID ASSIGNOP RELOP DOT TYPE SEMI COMMA

%type <NodeStar> Program ExtDefList ExtDef ExtDecList
%type <NodeStar> Specifier StructSpecifier OptTag Tag
%type <NodeStar> VarDec FunDec VarList ParamDec
%type <NodeStar> CompSt StmtList Stmt
%type <NodeStar> DefList Def DecList Dec
%type <NodeStar> Exp Args

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT 
%left LP RP LB RB DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
Program: ExtDefList {
	$$=generateNode(0,$1->line,"Program","",$1,NULL);
	if(!hasError)	
		show($$,0);
};
ExtDefList: ExtDef ExtDefList {
	$$=generateNode(0,$1->line,"ExtDefList","",$1,NULL); 
	addNext($1,$2);
}
| /*empty*/ {
	$$=generateNode(0,0,"","",NULL,NULL); 
};
ExtDef: Specifier ExtDecList SEMI {
	$$=generateNode(0,$1->line,"ExtDef","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Specifier SEMI {
	$$=generateNode(0,$1->line,"ExtDef","",$1,NULL);
	addNext($1,$2);
}
| Specifier FunDec CompSt {
	$$=generateNode(0,$1->line,"ExtDef","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
};
ExtDecList: VarDec {
	$$=generateNode(0,$1->line,"ExtDecList","",$1,NULL); 
}
| VarDec COMMA ExtDecList {
	$$=generateNode(0,$1->line,"ExtDecList","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| error COMMA ExtDecList {hasError=1;}
| VarDec COMMA error {hasError=1;};

Specifier: TYPE {
	$$=generateNode(0,$1->line,"Specifier","",$1,NULL); 
}
| StructSpecifier {
	$$=generateNode(0,$1->line,"Specifier","",$1,NULL); 
};
StructSpecifier: STRUCT OptTag LC DefList RC {
	$$=generateNode(0,$1->line,"StructSpecifier","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
	addNext($4,$5);
}
| STRUCT Tag {
	$$=generateNode(0,$1->line,"StructSpecifier","",$1,NULL); 
	addNext($1,$2);
}
| STRUCT OptTag LC error RC {hasError=1;};
OptTag: ID {
	$$=generateNode(0,$1->line,"OptTag","",$1,NULL); 
}
| /*empty*/ {
	$$=generateNode(0,0,"","",NULL,NULL); 
};
Tag: ID {
	$$=generateNode(0,$1->line,"Tag","",$1,NULL); 
};

VarDec: ID {
	$$=generateNode(0,$1->line,"VarDec","",$1,NULL); 
}
| VarDec LB INT RB {
	$$=generateNode(0,$1->line,"VarDec","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
};
FunDec: ID LP VarList RP {
	$$=generateNode(0,$1->line,"FunDec","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
}
| ID LP RP {
	$$=generateNode(0,$1->line,"FunDec","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| ID LP error RP {hasError=1;};
VarList: ParamDec COMMA VarList {
	$$=generateNode(0,$1->line,"VarList","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| ParamDec {
	$$=generateNode(0,$1->line,"VarList","",$1,NULL); 
};
ParamDec: Specifier VarDec {
	$$=generateNode(0,$1->line,"ParamDec","",$1,NULL); 
	addNext($1,$2);
};

CompSt: LC DefList StmtList RC {
	$$=generateNode(0,$1->line,"CompSt","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
};
StmtList: Stmt StmtList {
	$$=generateNode(0,$1->line,"StmtList","",$1,NULL); 
	addNext($1,$2);
}
| /*empty*/ {
	$$=generateNode(0,0,"","",NULL,NULL); 
};
Stmt: Exp SEMI {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
	addNext($1,$2);
}
| CompSt {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
}
| RETURN Exp SEMI {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
	addNext($4,$5);
}
| IF LP Exp RP Stmt ELSE Stmt {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
	addNext($4,$5);
	addNext($5,$6);
	addNext($6,$7);
}
| WHILE LP Exp RP Stmt {
	$$=generateNode(0,$1->line,"Stmt","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
	addNext($4,$5);
}
| error SEMI {hasError=1;}
| Exp error {hasError=1;}
| RETURN Exp error {hasError=1;}
| IF LP error RP Stmt {hasError=1;}
| IF LP error RP Stmt ELSE Stmt {hasError=1;}
| WHILE LP error RP Stmt {hasError=1;};

DefList: Def DefList {
	$$=generateNode(0,$1->line,"DefList","",$1,NULL); 
	addNext($1,$2);
}
| /*empty*/ {
	$$=generateNode(0,0,"","",NULL,NULL); 
};
Def: Specifier DecList SEMI {
	$$=generateNode(0,$1->line,"Def","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Specifier error SEMI {hasError=1;}
| Specifier DecList error {hasError=1;};
DecList: Dec {
	$$=generateNode(0,$1->line,"DecList","",$1,NULL); 
}
| Dec COMMA DecList {
	$$=generateNode(0,$1->line,"DecList","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
};
Dec: VarDec {
	$$=generateNode(0,$1->line,"Dec","",$1,NULL); 
}
| VarDec ASSIGNOP Exp {
	$$=generateNode(0,$1->line,"Dec","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
};

Exp: Exp ASSIGNOP Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp AND Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp OR Exp {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
} 
| Exp RELOP Exp {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp PLUS Exp {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp MINUS Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp STAR Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp DIV Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| LP Exp RP { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| MINUS Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
}
| NOT Exp { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
}
| ID LP Args RP { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
}
| ID LP RP { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp LB Exp RB {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
	addNext($3,$4);
}
| Exp DOT ID {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| ID { 
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
}
| INT {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
}
| FLOAT {
	$$=generateNode(0,$1->line,"Exp","",$1,NULL); 
}
| Exp LB error RB {hasError=1;} 
| ID LP error RP {hasError=1;}
| Exp error ID {hasError=1;};
Args: Exp COMMA Args {
	$$=generateNode(0,$1->line,"Args","",$1,NULL); 
	addNext($1,$2);
	addNext($2,$3);
}
| Exp {
	$$=generateNode(0,$1->line,"Args","",$1,NULL); 
};
%%
#define spaceSize 2

void yyerror(char *msg)
{
	printf("Error type B at Line %d\n",yylineno);
}

void addChild(struct Node *f, struct Node *s)
{
	f->child=s;
}

void addNext(struct Node *a, struct Node *b)
{
	a->next=b;	
} 

struct Node* generateNode(double val,int line,char *type,char *name,struct Node *child,struct Node *next)
{
	struct Node *node=(struct Node*)malloc(sizeof(struct Node));
	if(type!=NULL)
	{
		if(strcmp(type,"INT")==0) node->valInt=(int)val;
		else if(strcmp(type,"FLOAT")==0) node->valFloat=(float)val;
		else node->valDouble=val;
	}
	node->line=line;	
	strcpy(node->type,type);
	strcpy(node->name,name);
	node->child=child;
	node->next=next;	
	return node;
}

void visit(struct Node *node,int rank)
{
	if(!strcmp(node->type,""))//空串
		return;
	for(int i=0;i<rank*spaceSize;++i)
		printf(" ");
	//特殊词法单元
	if(!strcmp(node->type,"ID"))
		printf("%s: %s\n",node->type,node->name);
	else if(!strcmp(node->type,"TYPE"))
		printf("%s: %s\n",node->type,node->name);
	else if(!strcmp(node->type,"INT"))
		printf("%s: %d\n",node->type,node->valInt);	
	else if(!strcmp(node->type,"FLOAT"))
		printf("%s: %f\n",node->type,node->valFloat);	
	else if(node->child==NULL)//词法单元无需输出行号
		printf("%s\n",node->type);
	//语法单元
	else
		printf("%s (%d)\n",node->type,node->line);
}

void show(struct Node *node,int rank)
{
	if(!node)
		return;
	visit(node,rank);
	struct Node *child=node->child;	
	while(child)
	{
		show(child,rank+1);
		child=child->next;
	}
}
