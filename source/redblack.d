module redblack;

import std.stdio;
import std.conv;
import std.random : uniform;

/// Color is the color the redblack nodes
enum Color { Black, Red }

alias NodeFunc = void function(int depth, int left, int right, int val);

/// The node is the node in the tree 
class Node {
    /// The left side;
    Node left;
    /// The right side
    Node right;
    /// The color of the node
    Color color;
    /// The value of this node
    int value;

    /// Default constructor
    this(int val, Color col = Color.Red) {
        value = val;
        color = col;
    }

        /// inserts a node recursively
    void insertRec(Node parent, Node* refToParentLink, int val) {
        if (val < value) {
            if (left is null) {
                left = new Node(val);
                if (color == Color.Red) {
                    Node uncle = parent.left == this ? parent.right : parent.left;
                    if (uncle !is null) {
                        if (uncle.color == Color.Red) {
                            uncle.color = Color.Black;
                            color = Color.Black;
                            parent.color = Color.Red;
                        } else {
                          // uncle is black
                          if (parent.left == this) {
                              // inserting left => LL rotation
                              parent.left = right;
                              right = parent;
                              *refToParentLink = this;
                          }
                          else if (parent.right == this) {
                              // inserting left RL rotation
                              Node newNode = left;
                              newNode.left = right;
                              newNode.right = this;
                              parent.right = left;
                              left = newNode.left;
                              
                              parent.right = newNode.left;
                              *refToParentLink = newNode;
                              newNode.left = parent;
                          }
                        }
                    }
                }
            } else {
                left.insertRec(this,&left, val);
            }
        } else {
            if (right is null) {
                right = new Node(val);
                if (color == Color.Red) {
                    Node uncle = parent.left == this ? parent.right : parent.left;
                    if (uncle !is null) {
                        if (uncle.color == Color.Red) {
                            uncle.color = Color.Black;
                            color = Color.Black;
                            parent.color = Color.Red;
                        } else {
                          // uncle is black
                          if (parent.right == this) {
                              // inserting left RR rotation
                              parent.right = left;
                              left = parent;
                              *refToParentLink = this;
                          }  else if (parent.left == this) {
                              // inserting left LR rotation
                              Node newNode = right;
                              newNode.right = left;
                              newNode.left = this;
                              parent.left = right;
                              right = newNode.right;
                              
                              parent.left = newNode.right;
                              *refToParentLink = newNode;
                              newNode.right = parent;
                          }
                        }
                    }
                }
            } else {
                right.insertRec(this, &right, val);
            }
        }
    }

    void leaves(const int max_depth, int depth,int l, int r,  NodeFunc f) {
        if (depth < max_depth) {
            if (left !is null)
                left.leaves(max_depth,depth+1,l+1,r,f);
            if (right !is null)
                right.leaves(max_depth,depth+1,l,r+1,f);
        }
        else if (depth > max_depth)
            return;
        else if (depth == max_depth)
            f(depth, l,r,value);
    }

    void printtree(int depth, int l, int r) {
        write("  ",value," [fontcolor = ");
        write(color == Color.Red ? "red" : "black" );
        writeln("];");

        if (left is null && right is null)
            return;

        string nodeName;
        if (left is null) {
          nodeName = to!string(toHash()) ~  "l";
          writeln("  \"", nodeName, "\" [label=\"nil\" fontcolor=gray color=gray];");
        }
        else
          nodeName = to!string(left.value);
        writeln("  ", value,"->\"",nodeName,"\";" );              
        if (right is null) {
           nodeName = to!string(toHash()) ~  "r";
           writeln("  \"", nodeName,"\" [label=\"nil\" fontcolor=gray color=gray];");
        }
        else
          nodeName = to!string(right.value);
        writeln("  ", value,"->\"",nodeName,"\";" );


        if (left !is null)
            left.printtree(depth+1,l+1,r);
        if (right !is null)
            right.printtree(depth+1,l,r+1);
    }

    void inorder(int depth, int l, int r, NodeFunc f) {
        if (left !is null)
            left.inorder(depth+1,l+1,r,f);
        f(depth, l, r, value);
        if (right !is null) {
            right.inorder(depth+1,l,r+1,f);
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
            root = new Node(val, Color.Black);
        else
            root.insertRec(null,&root, val);
        if (root.color == Color.Red)
            root.color = Color.Black;
        count++;
    }

    /// traverse the tree InOrder
    void inorder(NodeFunc nodeAction) {
        if (root !is null)
          root.inorder(0,0,0,nodeAction);
    }

    void printtree() {
        writeln("digraph BST {");
        if (root !is null) {
            root.printtree(0,0,0);
        }
        writeln("}");
    }



}
