# A quick start for using gnuplot/me

This is a bash script to use gnuplot, to output a simple graph and output to a PDF file.

<img width="480" height="1125" alt="image" src="https://github.com/user-attachments/assets/faaa4e88-e158-4008-9992-65e813244639" />

## Usage

Change Space:
~~~
me -space 1,0
~~~
Change Size:
~~~
me -size 200,125
~~~ 
Change Caption of Figure (a):
~~~
me -a -ic '{//d}..=..10'
~~~
Change Axis of Figure (b) and (c):
~~~
me -b -yl '{s//r}_{(0,A)}({//E})'
me -c -xl '{//E}'
~~~
Plot graph and output to a PDF file:
~~~
me -gp
~~~
Help:
~~~
me -help
~~~
