module redblack;

import std.stdio;
import std.conv;
import std.random : uniform;

/// Color is the color the redblack nodes
enum Color {
    Black,
    Red
}

alias NodeFunc = void function(int depth, int left, int right, int val);

/// The node is the node in the tree 
class Node {
    /// The left side;
    Node left;
    /// The right side
    Node right;
    // The parent
    Node parent;
    // link to ref
    Node* link;
    /// The color of the node
    Color color;
    /// The value of this node
    int value;

    /// Default constructor
    this(Node par, Node* lnk, int val, Color col = Color.Red) {
        value = val;
        color = col;
        parent = par;
        link = lnk;
    }

    void leaves(const int max_depth, int depth, int l, int r, NodeFunc f) {
        if (depth < max_depth) {
            if (left !is null)
                left.leaves(max_depth, depth + 1, l + 1, r, f);
            if (right !is null)
                right.leaves(max_depth, depth + 1, l, r + 1, f);
        }
        else if (depth > max_depth)
            return;
        else if (depth == max_depth)
            f(depth, l, r, value);
    }

    void printtree(int depth, int l, int r) {
        write("  ", value, " [style=filled fillcolor = ");
        write(color == Color.Red ? "lightcoral" : "gray");
        writeln("];");

        if (left is null && right is null)
            return;

        string nodeName;
        if (left is null) {
            nodeName = to!string(toHash()) ~ "l";
            writeln("  \"", nodeName, "\" [label=\"nil\" color=white];");
        }
        else
            nodeName = to!string(left.value);
        writeln("  ", value, "->\"", nodeName, "\";");
        if (right is null) {
            nodeName = to!string(toHash()) ~ "r";
            writeln("  \"", nodeName, "\" [label=\"nil\" color=white];");
        }
        else
            nodeName = to!string(right.value);
        writeln("  ", value, "->\"", nodeName, "\";");

        if (left !is null)
            left.printtree(depth + 1, l + 1, r);
        if (right !is null)
            right.printtree(depth + 1, l, r + 1);
    }

    void inorder(int depth, int l, int r, NodeFunc f) {
        if (left !is null)
            left.inorder(depth + 1, l + 1, r, f);
        f(depth, l, r, value);
        if (right !is null) {
            right.inorder(depth + 1, l, r + 1, f);
        }
    }

    /// inserts a node recursively
    void insertRec(int val) {
        if (val < value) {
            if (left is null) {
                left = new Node(this,&left,val);
                if (color == Color.Red) {
                    Node uncle = parent.left == this ? parent.right : parent.left;
                    if (uncle !is null && uncle.color == Color.Red) {
                        // recolor
                        parent.color = Color.Red;
                        color = Color.Black;
                        uncle.color = Color.Black;
                    } else {
                        // rotate  (two cases)
                        if (parent.left  == this) {
                            // LL rotation
                        } else {
                            // RL rotation
                        }
                    }
                }
            }
            else {
                left.insertRec(val);
            }
        }
        else {
            if (right is null) {
                right = new Node(this,&right, val);
                if (color == Color.Red) {
                    Node uncle = parent.right == this ? parent.left : parent.right;
                    if (uncle !is null && uncle.color == Color.Red) {
                        // recolor
                        parent.color = Color.Red;
                        color = Color.Black;
                        uncle.color = Color.Black;
                    } else {
                        // rotate  (two cases)
                        if (parent.right == this) {
                            // RR rotation
                            parent.right = left;
                            left = parent;
                            *parent.link = this;
                            //swap colors
                            Color t = color;
                            color = parent.color;
                            parent.color = t;
                        } else {
                            // LR rotation
                        }
                    }
                }
            }
            else {
                right.insertRec(val);
            }
        }

    }
}

/// RBTree provides access to the tree
class RBTree {
    /// The root node
    Node root = null;
    /// count of number of nodes
    int count = 0;

    /// insert and element into the tree
    void insert(int val) {
        if (root is null)
            root = new Node(null,&root, val, Color.Black);
        else
            root.insertRec(val);
        count++;
    }

    /// traverse the tree InOrder
    void inorder(NodeFunc nodeAction) {
        if (root !is null)
            root.inorder(0, 0, 0, nodeAction);
    }

    void printtree() {
        writeln("digraph BST {");
        writeln("graph [fontname = \"helvetica\"];");
        writeln("node [fontname = \"helvetica\"];");
        writeln("edge [fontname = \"helvetica\"];");
        if (root !is null) {
            root.printtree(0, 0, 0);
        }
        writeln("}");
    }

}
