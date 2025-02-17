%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}


char* subVar(char* var){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return varTable.word[i];
        }
    }
    return var;

}
bool isVar(char* var) {
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return true;
        }
    }
    return false;
}




int counter = 0;


%}
%array
%option noyywrap
%x string_condition
%x var_condition
%x var_string_condition


CHAR            [.A-Za-z0-9!:\/_-][.A-Za-z0-9!:\/_-]*
ANYCHAR            [)(*&%#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%#@!`;,\.a-zA-Z0-9'/*_=~ -]*
VARSTART        \$\{
META            [|&]
IO              <|>|>>

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL); counter++;}
<string_condition>{VARSTART}     {BEGIN(var_string_condition);}


<var_condition>{CHAR}+       {if(isVar(yytext)) {
                                    
                                    //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                                    char *yycopy = strdup( subVar(yytext) );
                                    
                                        for ( int i = strlen(subVar(yytext)) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                         
                                        free( yycopy );

                                        


                                    } else {
                                        
                                        yylval.string = strdup(yytext);
                                        return STRING;
                                    };
                                }

<var_condition>[\}]           {BEGIN(INITIAL); }


<var_string_condition>{CHAR}+       {if(isVar(yytext)) {

                                        char *yycopy = strdup( subVar(yytext) );

                                        for ( int i = strlen(subVar(yytext)) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                         
                                        free( yycopy );

                                        
                                        


                                    } else {   
                                       ;                              
                                        
                                    };
                                }
                                

<var_string_condition>[\}]           {BEGIN(string_condition); }





[ ]		            { }
bye                 { counter++; return BYE; }
cd		            { counter++; return CD;}
alias		        { counter++; return ALIAS; }
unalias             { counter++; return UNALIAS; }
setenv              { counter++; return SETENV; }
unsetenv            { counter++; return UNSETENV;}
printenv            { counter++; return PRINTENV; }
"\n"		        { counter = 0; return END; }
{VARSTART}          { BEGIN(var_condition); }
{META}              { return META;}
{IO}                { yylval.string = strdup(yytext);  return IO;}
[\"]                 { BEGIN(string_condition); }
{CHAR}+              {if(counter == 0) {


                        if(ifAlias(yytext)) {
                    
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                        } else {       
                            counter++;         
                            yylval.string = strdup(yytext);
                            return STRING;
                        };
                    } else {
                            counter++;                     
                            yylval.string = strdup(yytext);
                            return STRING;
                     }
                    }
%%