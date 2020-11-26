module redblack;

/*
 * Redblack tree implementation
 * 2020-11-26 Jaap Geurts <jaap.geurts@fontys.nl>
 */


import std.stdio;
import std.conv;
import std.random : uniform;

/// Color is the color the redblack nodes
enum Color {
    Black,
    Red
}

// Callback for traversal. Depth is the current depth, left and right indicate how many left and right turns have been taken.
// value is value of the node
alias NodeFunc = void function(int depth, int left, int right, int val);

/// The node is the node in the tree 
/// The nodes keep a left, right and parent reference.
class Node {
    /// The left side;
    Node left;
    /// The right side
    Node right;
    
    // The parent
    Node parent;
    
    // Pointer to the parent reference(either left or right or root) to itself.
    // This is used when rotating so the incoming link from the parent to the current node can change 
    // to the new node after rotation. (This is required so we can change the root reference in case of a root rotation)
    Node* link;
    /// The color of the node
    Color color;
    /// The value of this node
    int value;

    bool printparents = false;

    /// Default constructor
    this(Node par, Node* lnk, int val, Color col = Color.Red) {
        value = val;
        color = col;
        parent = par;
        link = lnk;
    }

    // Prints out the tree nodes in graphviz format
    void printtree(int depth, int l, int r) {
        write("  ", value, " [style=filled fillcolor = ");
        write(color == Color.Red ? "lightcoral" : "gray");
        writeln("];");

        if (left is null && right is null) {
             // printing parents confuses the tree.gv script
            if (printparents) {
                if (parent !is null) 
                    writeln("  ", value, "->\"", parent.value , "\";");
                }
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

        // printing parents confuses the tree.gv script
        if (printparents) {
            if (parent !is null) 
                writeln("  ", value, "->\"", parent.value , "\";");
        }

        if (left !is null)
            left.printtree(depth + 1, l + 1, r);
        if (right !is null)
            right.printtree(depth + 1, l, r + 1);
    }

    // traverses the tree in-order
    void inorder(int depth, int l, int r, NodeFunc f) {
        if (left !is null)
            left.inorder(depth + 1, l + 1, r, f);
        f(depth, l, r, value);
        if (right !is null) {
            right.inorder(depth + 1, l, r + 1, f);
        }
    }

    // rotates the node to the right
    void rotateRight() {
        Node t = left;
        left = t.right;
        if (left !is null) {
            left.parent = this;
            left.link = &left;
        }
        t.right = this;
        t.parent = parent;
        *link = t;
        t.link = link;
        link = &t.right;
        parent = t;
    }

    // rotates the node to the left
    void rotateLeft() {
        Node t = right;
        right = t.left;
        if (right !is null) {
            right.parent = this;
            right.link = &right;
        }
        t.left = this;
        t.parent = parent;
        *link = t;
        t.link = link;
        link = &t.left;
        parent = t;
    }

    // move up the tree to restore color and balance
    void reorderTree(Node newNode) {
        if (parent is null)
            return; // we're at the root;

        if (color == Color.Black)
            return; // nothing to do

        if (parent.right == this) {
            // left case
            Node uncle = parent.left;
            if (uncle !is null && uncle.color == Color.Red) {
                // recolor
                parent.color = Color.Red;
                color = Color.Black;
                uncle.color = Color.Black;
                if (parent.parent !is null)
                    parent.parent.reorderTree(parent);
            }
            else {
                // rotate  (two cases)
                if (right == newNode) {
                    // RR case rotation
                    parent.rotateLeft();
                    //swap colors
                    Color t = color;
                    color = left.color;
                    left.color = t;
                }
                else {
                    // RL case rotation
                    rotateRight();
                    parent.reorderTree(this);
                }
            }
        }
        else {
            // uncle is on the right
            Node uncle = parent.right;
            if (uncle !is null && uncle.color == Color.Red) {
                // recolor
                parent.color = Color.Red;
                color = Color.Black;
                uncle.color = Color.Black;
                if (parent.parent !is null)
                    parent.parent.reorderTree(parent);
            }
            else {
                // rotate  (two cases)
                if (left == newNode) {
                    // LL case rotation
                    parent.rotateRight();
                    //swap colors
                    Color t = color;
                    color = right.color;
                    right.color = t;
                }
                else {
                    // LR case rotation
                    rotateLeft();
                    parent.reorderTree(this);
                }
            }
        }
    }

    /// inserts a node recursively
    void insertRec(int val) {
        if (val < value) {
            // insert left
            if (left is null) {
                left = new Node(this, &left, val);
                if (color == Color.Red) {
                    reorderTree(left);
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
                    reorderTree(right);
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
//nodesep=0.4; //was 0.8
//ranksep=0.5;
//penwidth=0.1;
node[shape=circle];
labelloc=top;
labeljust=left;
EOS");
        writeln("label=\"", caption, "\"");

        if (root !is null) {
            root.printtree(0, 0, 0);
        }
        writeln("}");
    }

}
