%{
#include <stdio.h>
#include <stdlib.h>


int regs[26];
int var[10];
int varCurrent=0;
double current=0;
int yylex();
int yyerror(char *s);
int yywrap();
%}

%start list
%union { 
  double a; 
  char c; 
}
%type <a> expr number DIGIT
%type <c> LETTER
%token DIGIT LETTER
%token EXIT
%token VARS
%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS

%%

list: /* empty */
    | list stat '\n'
    | list error '\n' {
      yyerrok;
    };

stat: expr {
        printf("%f\n\n", $1);
      }
    | LETTER '=' expr {
      regs[$1] = $3;
    };

expr: '(' expr ')' {
        $$ = $2;
        current = $$;
      }
    | expr '*' expr {
        $$ = $1 * $3;
        current = $$;
      }
    |
      '*' expr {
        $$ = current * $2;
        current = $$;
      }
    | expr '/' expr {
        $$ = $1 / $3;
        current = $$;
      }
    | '/' expr{
        $$ = current / $2;
        current = $$;
      }
   
    | expr '+' expr {
        $$ = $1 + $3;
        current = $$;
      }
    | '+' expr{
      $$ = current + $2;
      current = $$;
    }
    | expr '-' expr {
        $$ = $1 - $3;
        current = $$;
      }
    | '-' expr{
      $$ = current - $2;
      current = $$;
    }
  
    | '-' expr %prec UMINUS {
        $$ = -$2;
      }
    | LETTER {
        $$ = regs[$1];
      }
    | number;
    | EXIT {
      return EXIT_SUCCESS;
    }
    | VARS{
      
    }

number: DIGIT {
          $$ = $1;
        };

%%

int main() {
  return yyparse();
}

int yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
  return 1;
}

int yywrap() {
  return 1;
}
