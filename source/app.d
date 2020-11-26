import std.stdio;
import std.range;
import std.random;
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

	int[] arr;
	if (args.length == 1)
		arr =  1000.iota.randomCover.take(60).array;
	else {
        arr = args[1].split(",").map!(to!int).array;
	}
	
    foreach(val; arr) {
		tree.insert(val);
	}
	string caption = "[";
    caption ~= arr.map!(to!string).join(",");
	caption ~= "]";
    writeln("// arr: ", caption);

	write("// inorder: [");
	tree.inorder(&printnum);
	writeln("]");
	writeln("// Max depth: ", max_depth);

	tree.printtree(caption);
	writeln();

}
