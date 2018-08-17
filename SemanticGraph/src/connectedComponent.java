// Java implementation of Kosaraju's algorithm to print all SCCs
import java.io.*;
import java.util.*;
 
// This class represents a directed graph using adjacency list
// representation
 class connectedComponent
{
	public static ArrayList <Integer> node=new ArrayList<Integer>();
	public static HashMap<Integer, ArrayList<Integer>> componenet = new HashMap<Integer, ArrayList<Integer>>();
    private int V;   // No. of vertices
    private LinkedList<Integer> adj[]; //Adjacency List
   
    
    
 
    //Constructor
    connectedComponent(int v)
    {
        V = v;
        adj = new LinkedList[v];
        for (int i=0; i<v; ++i)
            adj[i] = new LinkedList();
    }
 
    //Function to add an edge into the graph
    void addEdge(int v, int w)  { 
    	adj[v].add(w); adj[w].add(v);
//    	 Graph g1 = new Graph(Main.unioned.size());
//         adj=g1.adj;
    	
    }
    
   
 
    // A recursive function to print DFS starting from v
    void DFSUtil(int v,boolean visited[])
    {
        // Mark the current node as visited and print it
        visited[v] = true;
        //System.out.print(v + " ");
        
        node.add(v);
 
        int n;
 
        // Recur for all the vertices adjacent to this vertex
      
        Iterator<Integer> i =adj[v].iterator();
        while (i.hasNext())
        {
            n = i.next();
            if (!visited[n])
                DFSUtil(n,visited);
        }
    }
 
    // Function that returns reverse (or transpose) of this graph
    connectedComponent getTranspose()
    {
    	connectedComponent g = new connectedComponent(V);
        for (int v = 0; v < V; v++)
        {
            // Recur for all the vertices adjacent to this vertex
            Iterator<Integer> i =adj[v].listIterator();
            while(i.hasNext())
                g.adj[i.next()].add(v);
        }
        return g;
    }
 
    void fillOrder(int v, boolean visited[], Stack stack)
    {
        // Mark the current node as visited and print it
        visited[v] = true;
 
        // Recur for all the vertices adjacent to this vertex
        Iterator<Integer> i = adj[v].iterator();
        while (i.hasNext())
        {
            int n = i.next();
            if(!visited[n])
                fillOrder(n, visited, stack);
        }
 
        // All vertices reachable from v are processed by now,
        // push v to Stack
        stack.push(new Integer(v));
    }
 
    // The main function that finds and prints all strongly
    // connected components
    void printSCCs()
    {
        Stack stack = new Stack();
 
        // Mark all the vertices as not visited (For first DFS)
        boolean visited[] = new boolean[V];
        for(int i = 0; i < V; i++)
            visited[i] = false;
 
        // Fill vertices in stack according to their finishing
        // times
        for (int i = 0; i < V; i++)
            if (visited[i] == false)
                fillOrder(i, visited, stack);
 
        // Create a reversed graph
        connectedComponent gr = getTranspose();
 
        // Mark all the vertices as not visited (For second DFS)
        for (int i = 0; i < V; i++)
            visited[i] = false;
 
        // Now process all vertices in order defined by Stack
        int i=0;
        while (stack.empty() == false)
        {
            // Pop a vertex from stack
            int v = (int)stack.pop();
            
            // Print Strongly connected component of the popped vertex
            if (visited[v] == false)
            {
                gr.DFSUtil(v, visited);
            
                componenet.put(i, node);
                i++;
                node=new ArrayList<Integer>();
               // System.out.println();
            }
        }
    }
}