%{
#define YYSTYPE void*
#include "MyLang.tab.h"
extern "C" int yylex();
%}

%option yylineno
%option noyywrap

IntLiteral                  [-]?[1-9]+[0-9]*|[0]

Identifier                  [A-Za-z_]+[A-Za-z_0-9]*

Mul                         [*]
Div                         [/]
Rem                         [%]
Add                         [+]
Sub                         [-]
ShiftLeft                   [<][<]
ShiftRight                  [>][>]

Less                        [<]
LessOrEq                    [<][=]
Greater                     [>]
GreaterOrEq                 [>][=]
Equal                       [=][=]
NotEqual                    [!][=]
Assignment                  [=]

LogicAnd                    [&][&]
LogicOr                     [|][|]
BitwiseAnd                  [&]
BitwiseOr                   [|]

LeftParent                  "("
RightParent                 ")"
LeftBracket                 "["
RightBracket                "]"
LeftBrace                   "{"
RightBrace                  "}"
Semicolon                   [;]
Comma                       [,]
Comment                     [/][/].*\n
Whitespace                  [ \t\r\n]

IntType                     [i][n][t]
VoidType                    [v][o][i][d]

IfKeyword                   [i][f]
ElseKeyword                 [e][l][s][e]
ForKeyword                  [f][o][r]
WhileKeyword                [w][h][i][l][e]
FunctionKeyword             [f][u][n][c][t][i][o][n]
ReturnKeyword               [r][e][t][u][r][n]

%%

{Whitespace}
{Comment}


{IntType} {
  printf("IntType %s\n", yytext);
  yylval = strdup(yytext);
  return IntType;
}

{VoidType} {
  printf("VoidType %s\n", yytext);
  yylval = strdup(yytext);
  return VoidType;
}

{IfKeyword} {
  printf("IfKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return IfKeyword;
}

{ElseKeyword} {
  printf("ElseKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return ElseKeyword;
}

{ForKeyword} {
  printf("ForKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return ForKeyword;
}

{WhileKeyword} {
  printf("WhileKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return WhileKeyword;
}

{ReturnKeyword} {
  printf("ReturnKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return ReturnKeyword;
}

{FunctionKeyword} {
  printf("FunctionKeyword %s\n", yytext);
  yylval = strdup(yytext);
  return FunctionKeyword;
}

{IntLiteral} {
  printf("IntLiteral %s\n", yytext);
  yylval = strdup(yytext);
  return IntLiteral;
}

{Identifier} {
  printf("Identifier %s\n", yytext);
  yylval = strdup(yytext);
  return Identifier;
}

{ShiftLeft} {
  printf("ShiftLeft %s\n", yytext);
  yylval = strdup(yytext);
  return ShiftLeft;
}

{ShiftRight} {
  printf("ShiftRight %s\n", yytext);
  yylval = strdup(yytext);
  return ShiftRight;
}

{LessOrEq} {
  printf("LessOrEq %s\n", yytext);
  yylval = strdup(yytext);
  return LessOrEq;
}

{GreaterOrEq} {
  printf("GreaterOrEq %s\n", yytext);
  yylval = strdup(yytext);
  return GreaterOrEq;
}

{NotEqual} {
  printf("NotEqual %s\n", yytext);
  yylval = strdup(yytext);
  return NotEqual;
}

{LogicAnd} {
  printf("LogicAnd %s\n", yytext);
  yylval = strdup(yytext);
  return LogicAnd;
}

{LogicOr} {
  printf("LogicOr %s\n", yytext);
  yylval = strdup(yytext);
  return LogicOr;
}

{Mul} {
  printf("Mul %s\n", yytext);
  yylval = strdup(yytext);
  return Mul;
}

{Div} {
  printf("Div %s\n", yytext);
  yylval = strdup(yytext);
  return Div;
}

{Rem} {
  printf("Rem %s\n", yytext);
  yylval = strdup(yytext);
  return Rem;
}

{Add} {
  printf("Add %s\n", yytext);
  yylval = strdup(yytext);
  return Add;
}

{Sub} {
  printf("Sub %s\n", yytext);
  yylval = strdup(yytext);
  return Sub;
}

{Equal} {
  printf("Equal %s\n", yytext);
  yylval = strdup(yytext);
  return Equal;
}

{Less} {
  printf("Less %s\n", yytext);
  yylval = strdup(yytext);
  return Less;
}

{Greater} {
  printf("Greater %s\n", yytext);
  yylval = strdup(yytext);
  return Greater;
}

{Assignment} {
  printf("Assignment %s\n", yytext);
  yylval = strdup(yytext);
  return Assignment;
}

{BitwiseAnd} {
  printf("BitwiseAnd %s\n", yytext);
  yylval = strdup(yytext);
  return BitwiseAnd;
}

{BitwiseOr} {
  printf("BitwiseOr %s\n", yytext);
  yylval = strdup(yytext);
  return BitwiseOr;
}

{LeftBracket} {
  printf("LeftBracket %s\n", yytext);
  yylval = strdup(yytext);
  return LeftBracket;
}

{RightBracket} {
  printf("RightBracket %s\n", yytext);
  yylval = strdup(yytext);
  return RightBracket;
}

{LeftParent} {
  printf("LeftParent %s\n", yytext);
  yylval = strdup(yytext);
  return LeftParent;
}

{RightParent} {
  printf("RightParent %s\n", yytext);
  yylval = strdup(yytext);
  return RightParent;
}

{LeftBrace} {
  printf("LeftBrace %s\n", yytext);
  yylval = strdup(yytext);
  return LeftBrace;
}

{RightBrace} {
  printf("RightBrace %s\n", yytext);
  yylval = strdup(yytext);
  return RightBrace;
}

{Semicolon} {
  printf("Semicolon %s\n", yytext);
  yylval = strdup(yytext);
  return Semicolon;
}

{Comma} {
  printf("Comma %s\n", yytext);
  yylval = strdup(yytext);
  return Comma;
}

. {
  return *yytext;
}

%%