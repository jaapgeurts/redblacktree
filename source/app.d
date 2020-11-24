import std.stdio;
import std.range;
import std.random : uniform;
import std.algorithm;
import std.conv;

import redblack;

int max_depth;
int middle = 40;


void printnum(int depth, int left, int right, int val) {
	if (max_depth < depth)
		max_depth = depth;
		
	write(val);
    write(',');
}


void main(string[] args)
{
	writeln("// Red-Black tree test driver");

	RBTree tree = new RBTree();

	//int[] arr = generate!(() => uniform(0, 1000)).take(20).array;
	int[] arr;
	if (args.length == 1)
		arr = [9,5,15,2,7,10,17,6,8,16];
	else {
        arr = args[1].split(",").map!(to!int).array;
	}
	
	write("// arr:     [");
	foreach(val; arr) {
		write(val,",");
		tree.insert(val);
	}
	writeln("]");

	write("// inorder: [");
	tree.inorder(&printnum);
	writeln("]");
	writeln("// Max depth: ", max_depth);

	tree.printtree();
	writeln();

}
