#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int term(char *s, int *i);
int expression(char *s, int *i)
{
    long result = term(s, i);

    while (s[*i] == '+' || s[*i] == '-')
    {
        printf("EXPRESSION: %ld\n", result);
        char a = s[*i];
        *i = *i + 1;
        int next_value = term(s, i);
        if (a == '+')
        {
            result += next_value;
        }
        else
        {
            result -= next_value;
        }
    }
    return result;
}

int factor(char *s, int *i)
{
    long result = 0;
    if (s[*i] == '(')
    {
        *i = *i + 1;
        result = expression(s, i);
        *i = *i + 1;
    }
    else
    {
        char *delim = "*/-+)";
        while (*i != (strlen(s)))
        {
            if (strchr(delim, s[*i]))
            {
                break;
            }
            result = result * 10 + s[*i] - '0';
            (*i)++;
        }
    }
    return result;
}

int term(char *s, int *i)
{
    long result = factor(s, i);
    printf("TERM: %ld\n", result);
    while (s[*i] == '*' || s[*i] == '/')
    {
        char a = s[*i];
        *i = *i + 1;
        int next_value = factor(s, i);
        if (a == '*')
        {
            result *= next_value;
        }
        if (a == '/')
        {
            result /= next_value;
        }
    }

    return result;
}

int main()
{
    char s[100000] = "(11+2)*3-7*7";
    int i = 0;
    printf("R: %d\n", expression(s, &i));
}