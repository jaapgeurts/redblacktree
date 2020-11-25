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

        if (left is null && right is null) {
            if (parent !is null) 
                writeln("  ", value, "->\"", parent.value , "\";");
            return;
        }

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

        if (parent !is null) 
            writeln("  ", value, "->\"", parent.value , "\";");

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

    void rotateRight() {
        Node t = left;
        left = t.right;
        if (left !is null)
            left.parent = this;
        t.right = this;
        t.parent = parent;
        t.link = link;
        link = &t.right;
        *t.link = t;
        parent = t;
    }

    void rotateLeft() {
        Node t = right;
        right = t.left;
        if (right !is null)
            right.parent = this;
        t.left = this;
        t.parent = parent;
        t.link = link;
        link = &t.left;
        *t.link = t;
        parent = t;
    }

    void reorderTreeRight() {
        Node uncle = parent.right == this ? parent.left : parent.right;
        if (uncle !is null && uncle.color == Color.Red) {
            // recolor
            parent.color = Color.Red;
            color = Color.Black;
            uncle.color = Color.Black;
        }
        else {
            // rotate  (two cases)
            if (parent.right == this) {
                // RR case rotation
                parent.rotateLeft();
                //swap colors
                Color t = color;
                color = left.color;
                left.color = t;
            }
            else {
                // LR case rotation
                rotateLeft();
                parent.parent.rotateRight();

            }
            if (parent !is null && parent.parent !is null)
                parent.reorderTreeRight();
        }

    }

    void reorderTreeLeft() {
        Node uncle = parent.left == this ? parent.right : parent.left;
        if (uncle !is null && uncle.color == Color.Red) {
            // recolor
            parent.color = Color.Red;
            color = Color.Black;
            uncle.color = Color.Black;
        }
        else {
            // rotate  (two cases)
            if (parent.left == this) {
                // LL case rotation
                parent.rotateRight();
                //swap colors
                Color t = color;
                color = right.color;
                right.color = t;

            }
            else {
                // RL case rotation
                rotateRight();
                parent.parent.rotateLeft();

            }
            if (parent !is null && parent.parent !is null)
                parent.reorderTreeLeft();
        }
    }

    /// inserts a node recursively
    void insertRec(int val) {
        if (val < value) {
            // insert left
            if (left is null) {
                left = new Node(this, &left, val);
                if (color == Color.Red) {
                    this.reorderTreeLeft();
                }
            }
            else {
                left.insertRec(val);
            }
        }
        else {
            // insert right
            if (right is null) {
                right = new Node(this, &right, val);
                if (color == Color.Red) {
                    this.reorderTreeRight();
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
            root = new Node(null, &root, val, Color.Black);
        else
            root.insertRec(val);
        root.color = Color.Black;
        count++;
    }

    /// traverse the tree InOrder
    void inorder(NodeFunc nodeAction) {
        if (root !is null)
            root.inorder(0, 0, 0, nodeAction);
    }

    void printtree(string caption) {
        writeln(q"EOS
digraph BST {
graph [fontname = "helvetica"];
node [fontname = "helvetica"];
edge [fontname = "helvetica"];
splines=false
nodesep=0.4; //was 0.8
ranksep=0.5;
penwidth=0.1;
node[shape=circle];
labelloc=top;
labeljust=left;
EOS"
        );
        writeln("label=\"",caption,"\"");

        if (root !is null) {
            root.printtree(0, 0, 0);
        }
        writeln("}");
    }

}
