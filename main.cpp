#include <iostream>
#include <vector>
#include <queue>
#include <string>
#include <iomanip>
#include <algorithm>
//#include <limits>

using namespace std;

class Node
{
    string name;
    int distance;
    int index;
    bool solved;
public:
    Node() {name = ""; distance = 0; index = 0; solved = false; }
    Node(string name, int index) { this->name = name; this->index = index; }
    string getName() { return name; }
    void setName(string name) { this->name = name; }
    int getIndex() { return index; }
    void setIndex(int index) { this->index = index; }
    int getDistance() { return distance; }
    void setDistance(int distance) { this->distance = distance; }
    bool getStatus() { return solved; }
    void setStatus(bool x) { solved = x; }
    bool operator<(const Node &RightNode)
    {
        return distance < RightNode.distance;
    }
};

class Graph
{
    int** matrix;
    int size;
    vector<Node> input;
    vector<string> names;
public:
    Graph(vector<Node> input)
    {
        this->input = input;
        size = input.size();
        matrix = new int*[size];
        for(int i=0;i<size;i++)
        {
            names.push_back(input[i].getName());
            matrix[i] = new int[size];
        }
        for(int i=0; i<size; i++)
        {
            for(int j=0; j<size; j++)
            {
                if (i==j) matrix[i][j] = 0;
                else matrix[i][j] = 9999;
            }
        }
    }
    vector<Node>getVector() { return input; }
    void printNodeName()
    {
        for (string name : names)
        {
            cout << name << '\t';
        }
    }
    void insertEdge(int index1, int index2, int edge)
    {
        matrix[index1][index2] = edge;
        matrix[index2][index1] = edge;
    }
    int getEdge(int index1, int index2)
    {
        return matrix[index1][index2];
    }
    int** getMatrix() { return matrix; }
    void printMatrix()
    {
        for(int i=0; i<size; i++)
        {
            for(int j=0; j<size; j++)
            {
                cout << left << setw(6) << matrix[i][j];
            }
            cout << endl;
        }
    }
};

class ShortestPath
{
    int* current;
    int minDistance;
    Node min;
    Node solvedV;
    vector<Node> solved;
public:
    ShortestPath(Graph graph, Node startV, Node endV)
    {
        vector<Node>vertices = graph.getVector();
        int count = vertices.size();
        int** matrix = graph.getMatrix();
        int startV_index = startV.getIndex();
        int endV_index = endV.getIndex();
        current = *(matrix+startV_index);
        for (int i = 0; i<count; i++)
        {
            vertices[i].setDistance(current[vertices[i].getIndex()]);
            vertices[i].setStatus(false);
        }
        vertices[startV_index].setStatus(true);
        vertices[startV_index].setDistance(0);
        solved.push_back(vertices[startV_index]);
        while (vertices[endV_index].getStatus() == false)
        {
            min = findMin(vertices);
            minDistance = min.getDistance();
            current = *(matrix+min.getIndex());
            for (Node &n : vertices)
            {
                if (n.getStatus()==false)
                {
                    int dist = minDistance + current[n.getIndex()];
                    if (dist<n.getDistance())
                    {
                        n.setDistance(dist);
                    }
                }
            }
            solved.push_back(min);
            vertices[min.getIndex()].setStatus(true);
        }
        solvedV = solved.back();
        cout << "Min distance from " << vertices[startV_index].getName() << " to " << vertices[endV_index].getName() << " is ";
        cout << solvedV.getDistance() << endl;
    }
    ShortestPath(Graph graph, Node startV)
    {
        vector<Node>vertices = graph.getVector();
        int count = vertices.size();
        int** matrix = graph.getMatrix();
        int startV_index = startV.getIndex();
        current = *(matrix+startV_index);
        for (int i = 0; i<count; i++)
        {
            vertices[i].setDistance(current[vertices[i].getIndex()]);
            vertices[i].setStatus(false);
        }
        vertices[startV_index].setStatus(true);
        vertices[startV_index].setDistance(0);
        solved.push_back(vertices[startV_index]);
        while (solved.size()<count)
        {
            min = findMin(vertices);
            minDistance = min.getDistance();
            current = *(matrix+min.getIndex());
            for (Node &n : vertices)
            {
                if (n.getStatus()==false)
                {
                    int dist = minDistance + current[n.getIndex()];
                    if (dist<n.getDistance())
                    {
                        n.setDistance(dist);
                    }
                }
            }
            solvedV = min;
            solved.push_back(solvedV);
            vertices[min.getIndex()].setStatus(true);
        }
        cout << "Min distance from one node to all other nodes: " << endl;
        for (Node node: solved)
        {
            cout << '\t' << "Min distance from " << vertices[startV_index].getName() << " to ";
            cout << node.getName() << ": " << node.getDistance() << endl;
        }
    }
    static bool IsSolved(Node n) { return n.getStatus(); }
    Node findMin(vector<Node>vect)
    {
        auto bound = partition(vect.begin(), vect.end(), IsSolved);
        Node min = *bound;
        for (auto it = bound; it!=vect.end(); it++)
        {
            if (*it<min) min = *it;
        }
        return min;
    }
};

int main()
{
    vector<Node> cities = { Node("SFO",0), Node("LAX",1), Node("DFW",2), Node("ORD",3), Node("JFK",4), Node("BOS",5), Node("MIA",6)};
    vector<vector<int>> edges = {   {0,1,337},
                                    {0,2,1464},
                                    {0,3,1846},
                                    {0,5,2704},
                                    {1,2,1235},
                                    {1,6,2342},
                                    {2,3,802},
                                    {2,6,1121},
                                    {3,4,740},
                                    {4,5,187},
                                    {4,6,1090},
                                    {5,0,2704},
                                    {5,6,1258}  };
    Graph graph(cities);
    for (auto vect : edges)
    {
        graph.insertEdge(vect[0], vect[1], vect[2]);
    }
    Node startV = cities[0];
    Node endV = cities[4];
    ShortestPath(graph, startV, endV);
    ShortestPath(graph, startV);
    return 0;
}