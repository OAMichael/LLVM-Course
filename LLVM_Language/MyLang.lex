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
  yylval = strdup(yytext);
  return IntType;
}

{VoidType} {
  yylval = strdup(yytext);
  return VoidType;
}

{IfKeyword} {
  yylval = strdup(yytext);
  return IfKeyword;
}

{ElseKeyword} {
  yylval = strdup(yytext);
  return ElseKeyword;
}

{ForKeyword} {
  yylval = strdup(yytext);
  return ForKeyword;
}

{WhileKeyword} {
  yylval = strdup(yytext);
  return WhileKeyword;
}

{ReturnKeyword} {
  yylval = strdup(yytext);
  return ReturnKeyword;
}

{FunctionKeyword} {
  yylval = strdup(yytext);
  return FunctionKeyword;
}

{IntLiteral} {
  yylval = strdup(yytext);
  return IntLiteral;
}

{Identifier} {
  yylval = strdup(yytext);
  return Identifier;
}

{ShiftLeft} {
  yylval = strdup(yytext);
  return ShiftLeft;
}

{ShiftRight} {
  yylval = strdup(yytext);
  return ShiftRight;
}

{LessOrEq} {
  yylval = strdup(yytext);
  return LessOrEq;
}

{GreaterOrEq} {
  yylval = strdup(yytext);
  return GreaterOrEq;
}

{NotEqual} {
  yylval = strdup(yytext);
  return NotEqual;
}

{LogicAnd} {
  yylval = strdup(yytext);
  return LogicAnd;
}

{LogicOr} {
  yylval = strdup(yytext);
  return LogicOr;
}

{Mul} {
  yylval = strdup(yytext);
  return Mul;
}

{Div} {
  yylval = strdup(yytext);
  return Div;
}

{Rem} {
  yylval = strdup(yytext);
  return Rem;
}

{Add} {
  yylval = strdup(yytext);
  return Add;
}

{Sub} {
  yylval = strdup(yytext);
  return Sub;
}

{Equal} {
  yylval = strdup(yytext);
  return Equal;
}

{Less} {
  yylval = strdup(yytext);
  return Less;
}

{Greater} {
  yylval = strdup(yytext);
  return Greater;
}

{Assignment} {
  yylval = strdup(yytext);
  return Assignment;
}

{BitwiseAnd} {
  yylval = strdup(yytext);
  return BitwiseAnd;
}

{BitwiseOr} {
  yylval = strdup(yytext);
  return BitwiseOr;
}

{LeftBracket} {
  yylval = strdup(yytext);
  return LeftBracket;
}

{RightBracket} {
  yylval = strdup(yytext);
  return RightBracket;
}

{LeftParent} {
  yylval = strdup(yytext);
  return LeftParent;
}

{RightParent} {
  yylval = strdup(yytext);
  return RightParent;
}

{LeftBrace} {
  yylval = strdup(yytext);
  return LeftBrace;
}

{RightBrace} {
  yylval = strdup(yytext);
  return RightBrace;
}

{Semicolon} {
  yylval = strdup(yytext);
  return Semicolon;
}

{Comma} {
  yylval = strdup(yytext);
  return Comma;
}

. {
  return *yytext;
}

%%