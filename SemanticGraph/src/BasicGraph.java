import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;



public class BasicGraph {

  private final Collection<Integer> vertices = new HashSet<Integer>();
  private final static HashMap<Integer, HashSet<Integer>> neighborhoods = new HashMap<Integer, HashSet<Integer>>();

  private String name = "";

  public BasicGraph() {
  }

  
  
  public HashSet<Integer> getVertices() {
    HashSet<Integer> s = new HashSet<Integer>();
    for (Integer v : vertices) {
      s.add(v);
    }
    return s;
  }
  

 
  public int order() {
    return vertices.size();
  }

  public boolean addVertex(int v) {
    if (!vertices.contains(v)) {
      vertices.add(v);
      neighborhoods.put(v, new HashSet<Integer>(100));
    }
    return false;
  }
  

  public void addEdge(int a, int b) {
    if (vertices.contains(a) && neighborhoods.get(a).contains(b))
      return;

    if (!vertices.contains(a)) {
      vertices.add(a);
      HashSet<Integer> an = new HashSet<Integer>();
      an.add(b);
      neighborhoods.put(a, an);
    } else {
      neighborhoods.get(a).add(b);
    }

    if (!vertices.contains(b)) {
      vertices.add(b);
      HashSet<Integer> bn = new HashSet<Integer>();
      bn.add(a);
      neighborhoods.put(b, bn);
    } else {
      neighborhoods.get(b).add(a);
    }
  }


  public int hashCode() {
    return neighborhoods.hashCode();
  }

  
  public static HashSet<Integer> getNeighborhood(int v) {
    HashSet<Integer> n = new HashSet<Integer>();
    for (Integer i : neighborhoods.get(v)) {
      n.add(i);
    }
    return n;
  }

  public BasicGraph clone() {
    BasicGraph gc = new BasicGraph();
    for (Integer v : vertices)
      gc.addVertex(v);

    for (Integer v : neighborhoods.keySet()) {
      for (Integer nv : neighborhoods.get(v))
        gc.addEdge(v, nv);
    }

    gc.name = name;
    return gc;
  }
  
  public boolean isChordal() {
	    BasicGraph g = clone();
	    while (!g.vertices.isEmpty()) {
	      int del = -1;
	      for (int i : g.vertices) {
	        if (g.isSimplicial(i)) {
	          del = i;
	          break;
	        }
	      }
	      if (del == -1)
	        return false;
	      if (!g.removeVertex(del)) {
	        System.out.println("Could not delete vertex " + del + " from " + g);
	      }
	    }
	    return true;
	  }
  public boolean isSimplicial(int v) {
	    boolean ret = isClique(getNeighborhood(v));
	    // System.out.println("SimpleGraph.isSimplicial " + v + ": " + ret);
	    return ret;
	  }
  
  public boolean isClique(Collection<Integer> s) {
	    if (s == null)
	      throw new NullPointerException("Clique input was null");
	    if (s.size() <= 1)
	      return true;
	    if (s.size() == 2) {
	      Iterator<Integer> it = s.iterator();
	      int a = it.next();
	      int b = it.next();
	      return isAdjacent(a, b);
	    }

	    Integer[] x = s.toArray(new Integer[s.size()]);
	    for (int i = 0; i < x.length; i++) {
	      for (int j = i + 1; j < x.length; j++) {
	        if (!isAdjacent(x[i], x[j])) {
	          return false;
	        }
	      }
	    }
	    return true;
	  }
  
  public boolean removeVertex(Integer v) {
	    if (!vertices.contains(v))
	      return false;

	    HashSet<Integer> neigh = neighborhoods.get(v);
	    for (Integer nv : neigh) {
	      neighborhoods.get(nv).remove(v);
	    }

	    vertices.remove(v);
	    neighborhoods.remove(v);

	    return true;
	  }
  public boolean isAdjacent(int a, int b) {
	    return neighborhoods.get(a).contains(b);
	  }
}

